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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: isLight
            ? const [
                BoxShadow(
                  color: Color(0x080F172A),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media Header (Consistent 160px height for all cards)
            if (record.primaryPhoto != null)
              SensitiveImageCard(
                imageUrl: record.primaryPhoto!.previewUrl,
                caption: record.primaryPhoto!.caption,
                category: record.primaryPhoto!.category,
                initialBlur: blurSensitive,
                height: 155,
                width: double.infinity,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
              )
            else
              _buildForensicProfilePlaceholder(isLight, textPri, textSec, textMut),

            // Content Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reference & Status Row
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.tag_rounded, size: 14, color: AppColors.primary),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  record.referenceNo,
                                  style: TextStyle(
                                    color: isLight ? AppColors.primary : AppColors.primaryLight,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    letterSpacing: -0.2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildStatusChip(record.status),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Compact 4-Column Anthropological Specs Matrix
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: specBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: specBorder, width: 0.8),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: _bioColumn('SEX', record.gender, textMut, textPri)),
                          _divider(specBorder),
                          Expanded(child: _bioColumn('EST. AGE', '~${record.estimatedAge}y', textMut, textPri)),
                          _divider(specBorder),
                          Expanded(child: _bioColumn('HEIGHT', '${record.heightCm} cm', textMut, textPri)),
                          _divider(specBorder),
                          Expanded(child: _bioColumn('WEIGHT', '${record.weightKg} kg', textMut, textPri)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Location & Date Found
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 13, color: AppColors.slate500),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${record.thana}, ${record.district}',
                            style: TextStyle(color: textSec, fontSize: 11.5, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.slate400),
                        const SizedBox(width: 4),
                        Text(
                          record.dateFound,
                          style: TextStyle(color: textMut, fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),

                    const SizedBox(height: 7),

                    // Identifying Marks Highlight Block
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: isLight ? const Color(0xFFF1F5F9) : AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border(
                          left: BorderSide(color: AppColors.primary.withValues(alpha: 0.7), width: 3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.fingerprint_rounded, size: 13, color: AppColors.slate500),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              record.identificationMarks.isNotEmpty ? record.identificationMarks : 'No distinct marks cataloged',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: textPri,
                                fontSize: 11,
                                height: 1.3,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 7),

                    // Forensic Tags Row
                    Wrap(
                      spacing: 5,
                      runSpacing: 4,
                      children: [
                        if (record.hasDna)
                          _featureTag('DNA Ready', AppColors.purple, AppColors.purpleLight, AppColors.purpleBorder, Icons.biotech_outlined),
                        if (record.hasFingerprint)
                          _featureTag('AFIS 10-Print', AppColors.cyan, AppColors.cyanLight, AppColors.cyanBorder, Icons.fingerprint_rounded),
                        if (record.documents.any((d) => d.type == 'inquest_report'))
                          _featureTag('Inquest §174', AppColors.blue, AppColors.blueLight, AppColors.blueBorder, Icons.article_outlined),
                        if (record.documents.any((d) => d.type == 'postmortem_report'))
                          _featureTag('Autopsy', AppColors.green, AppColors.greenLight, AppColors.greenBorder, Icons.medical_services_outlined),
                      ],
                    ),

                    const Spacer(),

                    // Action Buttons Row
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 33,
                            child: OutlinedButton.icon(
                              onPressed: onTap,
                              icon: const Icon(Icons.folder_shared_outlined, size: 13),
                              label: const Text('Dossier', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isLight ? AppColors.slate800 : Colors.white,
                                side: BorderSide(color: isLight ? AppColors.slate300 : AppColors.darkBorder),
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 33,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => GazetteNoticeDialog(record: record),
                              );
                            },
                            icon: const Icon(Icons.newspaper_rounded, size: 13),
                            label: const Text('Gazette (গেজেট)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.goldLight,
                              foregroundColor: AppColors.goldDark,
                              side: const BorderSide(color: AppColors.goldBorder, width: 0.9),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
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

  // Consistent 155px tall placeholder for cases without crime scene photo
  Widget _buildForensicProfilePlaceholder(bool isLight, Color textPri, Color textSec, Color textMut) {
    return Container(
      height: 155,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isLight
              ? [const Color(0xFFF1F5F9), const Color(0xFFE2E8F0)]
              : [const Color(0xFF1E293B), const Color(0xFF0F172A)],
        ),
      ),
      child: Stack(
        children: [
          // Background Watermark Emblem
          Positioned(
            right: -10,
            bottom: -15,
            child: Icon(
              Icons.fingerprint_rounded,
              size: 110,
              color: isLight ? Colors.black.withValues(alpha: 0.04) : Colors.white.withValues(alpha: 0.03),
            ),
          ),

          // Top Header Tag
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: isLight ? Colors.white.withValues(alpha: 0.85) : Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: isLight ? AppColors.slate200 : AppColors.darkBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield_outlined, size: 10, color: textSec),
                  const SizedBox(width: 4),
                  Text(
                    'FORENSIC INQUEST FILE',
                    style: TextStyle(
                      color: textSec,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Center Silhouette & Identity Badge
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: isLight ? Colors.white : AppColors.darkCardBg,
                  child: Icon(
                    record.gender.toLowerCase() == 'female'
                        ? Icons.female_rounded
                        : Icons.male_rounded,
                    color: AppColors.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${record.gender.toUpperCase()} DECEASED',
                  style: TextStyle(
                    color: textPri,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  'Physical Traits & Biometrics Cataloged',
                  style: TextStyle(color: textMut, fontSize: 9.5, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bioColumn(String label, String value, Color labelColor, Color valColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(color: labelColor, fontSize: 8.5, fontWeight: FontWeight.w700, letterSpacing: 0.4),
        ),
        const SizedBox(height: 1.5),
        Text(
          value,
          style: TextStyle(color: valColor, fontSize: 11.5, fontWeight: FontWeight.w700),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _divider(Color color) {
    return Container(
      height: 18,
      width: 1,
      color: color,
    );
  }

  Widget _featureTag(String text, Color fgColor, Color bgColor, Color borderColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: fgColor),
          const SizedBox(width: 3),
          Text(text, style: TextStyle(color: fgColor, fontSize: 9.5, fontWeight: FontWeight.w700)),
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
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            status.split('-').last.trim(),
            style: TextStyle(color: fg, fontSize: 9.5, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
