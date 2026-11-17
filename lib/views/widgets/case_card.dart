import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/udb_record.dart';
import 'sensitive_image_card.dart';
import 'gazette_notice_dialog.dart';

class CaseCard extends StatelessWidget {
  final UdbRecord record;
  final bool blurSensitive;
  final VoidCallback onTap;

  const CaseCard({
    super.key,
    required this.record,
    required this.blurSensitive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cardBgColor = isLight ? Colors.white : AppColors.darkCardBg;
    final borderColor = isLight ? AppColors.lightBorder : AppColors.darkBorder;
    final specBg = isLight ? const Color(0xFFF8FAFC) : AppColors.darkInputBg;
    final specBorder = isLight ? const Color(0xFFE2E8F0) : AppColors.darkBorder;
    final textPri = isLight ? AppColors.slate900 : AppColors.darkTextPrimary;
    final textSec = isLight ? AppColors.slate600 : AppColors.darkTextSecondary;
    final textMut = isLight ? AppColors.slate400 : AppColors.darkTextMuted;

    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: isLight
            ? const [
                BoxShadow(
                  color: Color(0x060F172A),
                  blurRadius: 12,
                  offset: Offset(0, 3),
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            // Media Header
            if (record.primaryPhoto != null)
              SensitiveImageCard(
                imageUrl: record.primaryPhoto!.previewUrl,
                caption: record.primaryPhoto!.caption,
                category: record.primaryPhoto!.category,
                initialBlur: blurSensitive,
                height: 155,
              )
            else
              Container(
                height: 155, // same as the photo header so every card lines up
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isLight
                        ? [const Color(0xFFF8FAFC), const Color(0xFFF1F5F9)]
                        : [const Color(0xFF131A29), const Color(0xFF0F172A)],
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: isLight ? Colors.white : AppColors.darkBorder,
                        child: Text(
                          record.gender.isNotEmpty ? record.gender[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        record.gender,
                        style: TextStyle(color: textSec, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),

            // Content Body
            Expanded(
              child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Reference & Status Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          record.referenceNo,
                          style: TextStyle(
                            color: isLight ? AppColors.primary : AppColors.primaryLight,
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                            letterSpacing: -0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildStatusChip(record.status),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Anthropological specs grid
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: specBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: specBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _bioItem('Sex', record.gender, textMut, textPri),
                        _divider(specBorder),
                        _bioItem('Age', '~${record.estimatedAge}y', textMut, textPri),
                        _divider(specBorder),
                        _bioItem('Height', '${record.heightCm}cm', textMut, textPri),
                        _divider(specBorder),
                        _bioItem('Weight', '${record.weightKg}kg', textMut, textPri),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Location & Date
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: AppColors.slate400),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${record.thana}, ${record.district}',
                          style: TextStyle(color: textSec, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.slate400),
                      const SizedBox(width: 4),
                      Text(
                        record.dateFound,
                        style: TextStyle(color: textMut, fontSize: 11),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Distinguishing Marks Summary
                  Text(
                    'Marks: ${record.identificationMarks}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: textPri, fontSize: 12, height: 1.35),
                  ),

                  const SizedBox(height: 10),

                  // Forensic Badges Row
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (record.hasDna)
                        _featureTag('DNA Ready', AppColors.purple, AppColors.purpleLight, AppColors.purpleBorder, Icons.biotech_outlined),
                      if (record.hasFingerprint)
                        _featureTag('AFIS 10-Print', AppColors.cyan, AppColors.cyanLight, AppColors.cyanBorder, Icons.fingerprint_outlined),
                      if (record.documents.any((d) => d.type == 'inquest_report'))
                        _featureTag('Inquest', AppColors.blue, AppColors.blueLight, AppColors.blueBorder, Icons.description_outlined),
                      if (record.documents.any((d) => d.type == 'postmortem_report'))
                        _featureTag('Autopsy', AppColors.green, AppColors.greenLight, AppColors.greenBorder, Icons.medical_services_outlined),
                    ],
                  ),

                  const Spacer(), // pushes the buttons to the bottom edge
                  const SizedBox(height: 10),

                  // Action Buttons Row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onTap,
                          icon: const Icon(Icons.open_in_new, size: 13),
                          label: const Text('Dossier', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isLight ? AppColors.slate800 : Colors.white,
                            side: BorderSide(color: isLight ? AppColors.slate300 : AppColors.darkBorder),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => GazetteNoticeDialog(record: record),
                          );
                        },
                        icon: const Icon(Icons.menu_book_outlined, size: 13),
                        label: const Text('Gazette (গেজেট)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.goldLight,
                          foregroundColor: AppColors.goldDark,
                          side: const BorderSide(color: AppColors.goldBorder),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bioItem(String label, String value, Color labelColor, Color valColor) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: labelColor, fontSize: 10)),
        const SizedBox(height: 1),
        Text(value, style: TextStyle(color: valColor, fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _divider(Color color) {
    return Container(
      height: 16,
      width: 1,
      color: color,
    );
  }

  Widget _featureTag(String text, Color fgColor, Color bgColor, Color borderColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: fgColor),
          const SizedBox(width: 3),
          Text(text, style: TextStyle(color: fgColor, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bg = const Color(0xFFF1F5F9);
    Color fg = AppColors.slate700;
    Color border = const Color(0xFFE2E8F0);

    final lower = status.toLowerCase();
    if (lower.contains('active') || lower.contains('probable')) {
      bg = AppColors.greenLight;
      fg = AppColors.green;
      border = AppColors.greenBorder;
    } else if (lower.contains('verification') || lower.contains('pending')) {
      bg = AppColors.amberLight;
      fg = AppColors.goldDark;
      border = AppColors.goldBorder;
    } else if (lower.contains('dna')) {
      bg = AppColors.purpleLight;
      fg = AppColors.purple;
      border = AppColors.purpleBorder;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Text(
        status.split('-').last.trim(),
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }
}
