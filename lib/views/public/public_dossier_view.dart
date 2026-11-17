import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../models/udb_record.dart';
import '../../providers/udb_provider.dart';
import '../../providers/auth_provider.dart';
import '../widgets/sensitive_image_card.dart';
import '../widgets/gazette_notice_dialog.dart';
import '../widgets/photo_lightbox_dialog.dart';
import 'citizen_tip_dialog.dart';

class PublicDossierView extends StatefulWidget {
  final UdbRecord record;
  final VoidCallback onBack;
  final VoidCallback onOpenOfficialDossier;
  final VoidCallback onRequestIoAccess;

  const PublicDossierView({
    super.key,
    required this.record,
    required this.onBack,
    required this.onOpenOfficialDossier,
    required this.onRequestIoAccess,
  });

  @override
  State<PublicDossierView> createState() => _PublicDossierViewState();
}

class _PublicDossierViewState extends State<PublicDossierView> {
  int _activePhotoIndex = 0;

  @override
  Widget build(BuildContext context) {
    final udb = context.watch<UdbProvider>();
    final auth = context.watch<AuthProvider>();
    final isDesktop = Responsive.isDesktop(context);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cardBg = isLight ? Colors.white : AppColors.darkCardBg;
    final borderColor = isLight ? AppColors.lightBorder : AppColors.darkBorder;
    final textPri = isLight ? AppColors.lightTextPrimary : AppColors.darkTextPrimary;
    final textSec = isLight ? AppColors.lightTextSecondary : AppColors.darkTextSecondary;
    final textMut = isLight ? AppColors.lightTextMuted : AppColors.darkTextMuted;
    final record = widget.record;

    final photos = record.photos;
    final activePhoto = photos.isNotEmpty && _activePhotoIndex < photos.length
        ? photos[_activePhotoIndex]
        : null;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 48 : 16,
        vertical: 24,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Navigation Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: widget.onBack,
                        icon: const Icon(Icons.arrow_back, size: 16),
                        label: const Text('Back to Deceased Index'),
                        style: TextButton.styleFrom(foregroundColor: textSec),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.share_outlined, size: 18, color: AppColors.primary),
                        tooltip: 'Copy Case Reference & Share Link',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: 'CID UDB Case Ref: ${record.referenceNo} (${record.thana}, ${record.district}) - GD: ${record.gdCaseReference}'));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Case Reference ${record.referenceNo} copied to clipboard.'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => GazetteNoticeDialog(record: record),
                          );
                        },
                        icon: const Icon(Icons.menu_book_outlined, size: 15),
                        label: const Text('Gazette Notice (গেজেট)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.goldLight,
                          foregroundColor: AppColors.goldDark,
                          side: const BorderSide(color: AppColors.goldBorder),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => CitizenTipDialog(bodyReference: record.referenceNo),
                          );
                        },
                        icon: const Icon(Icons.record_voice_over_outlined, size: 15),
                        label: const Text('Submit Relative Match Lead'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (auth.isAuthenticated)
                        OutlinedButton.icon(
                          onPressed: widget.onOpenOfficialDossier,
                          icon: const Icon(Icons.admin_panel_settings, size: 15),
                          label: const Text('Official Dossier (CIB)'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary),
                            foregroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        )
                      else
                        OutlinedButton.icon(
                          onPressed: widget.onRequestIoAccess,
                          icon: const Icon(Icons.vpn_key_outlined, size: 15),
                          label: const Text('Request IO Unredacted File'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.slate300),
                            foregroundColor: AppColors.slate800,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Title & Case Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                  boxShadow: isLight
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CID Central Intelligence Bureau • Forensic Deceased Notice',
                            style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            record.referenceNo,
                            style: TextStyle(
                              color: textPri,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Recovered on ${record.dateFound} at ${record.thana}, ${record.district} • Case/GD: ${record.gdCaseReference}',
                            style: TextStyle(color: textSec, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.green.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            record.status,
                            style: const TextStyle(color: AppColors.green, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Public Citizen View (Redacted)',
                          style: TextStyle(color: textMut, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Case Verification Milestone Stepper
              _buildCaseMilestoneTracker(record, isLight, cardBg, borderColor, textPri, textSec),

              const SizedBox(height: 20),

              // Forensic Photographic Evidence Gallery
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                  boxShadow: isLight
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Visual Evidence & Forensic Photographic Catalog',
                              style: TextStyle(color: textPri, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${photos.length} Photo(s) Catalogued • Sensitive content blurred by default for public respect',
                              style: TextStyle(color: textSec, fontSize: 12),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            if (photos.isNotEmpty) ...[
                              OutlinedButton.icon(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => PhotoLightboxDialog(
                                      photos: photos,
                                      initialIndex: _activePhotoIndex,
                                      initialBlur: udb.blurSensitive,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.fullscreen_rounded, size: 16),
                                label: const Text('Full-Screen Lightbox'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(color: AppColors.primaryBorder),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            OutlinedButton.icon(
                              onPressed: () => udb.toggleBlur(),
                              icon: Icon(udb.blurSensitive ? Icons.visibility_off : Icons.visibility, size: 14),
                              label: Text(udb.blurSensitive ? 'Reveal All Photos' : 'Blur Sensitive Photos'),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: udb.blurSensitive ? AppColors.amber : AppColors.gold),
                                foregroundColor: udb.blurSensitive ? AppColors.amber : AppColors.gold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    if (activePhoto != null) ...[
                      // Active Main View
                      SensitiveImageCard(
                        imageUrl: activePhoto.previewUrl,
                        caption: activePhoto.caption,
                        category: activePhoto.category,
                        initialBlur: udb.blurSensitive,
                        height: 380,
                      ),
                      const SizedBox(height: 12),
                      // Thumbnails Row
                      if (photos.length > 1)
                        SizedBox(
                          height: 70,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: photos.length,
                            separatorBuilder: (_, _) => const SizedBox(width: 10),
                            itemBuilder: (context, idx) {
                              final p = photos[idx];
                              final isSelected = idx == _activePhotoIndex;
                              return InkWell(
                                onTap: () => setState(() => _activePhotoIndex = idx),
                                child: Container(
                                  width: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isSelected ? AppColors.gold : borderColor,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Image.network(
                                    p.previewUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => const Center(child: Icon(Icons.image, size: 18)),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isLight ? AppColors.slate100 : AppColors.darkSurface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderColor),
                        ),
                        child: Center(
                          child: Text(
                            'No external photographs published for this entry. Forensic profile maintained under restricted police archival.',
                            style: TextStyle(color: textSec, fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 4 Structured Sections (Interpol DVI Standard)
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildSection1Recovery(record, isLight, cardBg, borderColor, textPri, textSec, textMut)),
                    const SizedBox(width: 20),
                    Expanded(child: _buildSection2Anthropology(record, isLight, cardBg, borderColor, textPri, textSec, textMut)),
                  ],
                )
              else ...[
                _buildSection1Recovery(record, isLight, cardBg, borderColor, textPri, textSec, textMut),
                const SizedBox(height: 20),
                _buildSection2Anthropology(record, isLight, cardBg, borderColor, textPri, textSec, textMut),
              ],

              const SizedBox(height: 20),

              _buildSection3Marks(record, isLight, cardBg, borderColor, textPri, textSec, textMut),

              const SizedBox(height: 20),

              _buildSection4Clothing(record, isLight, cardBg, borderColor, textPri, textSec, textMut),

              const SizedBox(height: 20),

              // Forensic Availability & Next Steps Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isLight ? AppColors.blueLight : AppColors.darkCardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isLight ? AppColors.blueBorder : AppColors.darkBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.fingerprint, color: AppColors.primary, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Official Biometric & Forensic Records Maintained by CID',
                            style: TextStyle(
                              color: isLight ? AppColors.slate900 : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Fingerprint: ${record.fingerprintAvailability} • DNA: ${record.dnaProfileAvailability} • Mortuary Ref: ${record.postmortemReference}',
                            style: TextStyle(color: isLight ? AppColors.slate600 : AppColors.darkTextSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => CitizenTipDialog(bodyReference: record.referenceNo),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Provide Information to CID'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection1Recovery(UdbRecord record, bool isLight, Color cardBg, Color border, Color textPri, Color textSec, Color textMut) {
    return _panel(
      title: '1. Discovery & Recovery Circumstances',
      icon: Icons.place_outlined,
      isLight: isLight,
      cardBg: cardBg,
      border: border,
      textPri: textPri,
      children: [
        _row('Date & Time Found', '${record.dateFound} • ${record.timeFound}', textMut, textPri),
        _row('Recovery Location', record.placeFound, textMut, textPri),
        _row('Specific Spot / Coordinates', record.locationFound, textMut, textPri),
        _row('Police Station (Thana)', record.thana, textMut, textPri),
        _row('District & Division', '${record.district}, ${record.division}', textMut, textPri),
        _row('GD / FIR Case Reference', record.gdCaseReference, textMut, textPri),
        _row('Recovery Unit', record.recoveryOfficerUnit, textMut, textPri),
      ],
    );
  }

  Widget _buildSection2Anthropology(UdbRecord record, bool isLight, Color cardBg, Color border, Color textPri, Color textSec, Color textMut) {
    return _panel(
      title: '2. Anthropological Profile',
      icon: Icons.person_outline,
      isLight: isLight,
      cardBg: cardBg,
      border: border,
      textPri: textPri,
      children: [
        _row('Biological Sex', record.gender, textMut, textPri),
        _row('Estimated Age', '~${record.estimatedAge} Years (${record.ageGroup})', textMut, textPri),
        _row('Approximate Height', '${record.heightCm} cm', textMut, textPri),
        _row('Approximate Weight', '${record.weightKg} kg', textMut, textPri),
        _row('Body Condition', record.bodyCondition, textMut, textPri),
        _row('Complexion / Tone', record.complexion, textMut, textPri),
        _row('Hair', record.hair, textMut, textPri),
        _row('Facial Hair', record.facialHair, textMut, textPri),
      ],
    );
  }

  Widget _buildSection3Marks(UdbRecord record, bool isLight, Color cardBg, Color border, Color textPri, Color textSec, Color textMut) {
    return _panel(
      title: '3. Identifying Marks, Scars, Tattoos & Dental Charting',
      icon: Icons.fingerprint,
      isLight: isLight,
      cardBg: cardBg,
      border: border,
      textPri: textPri,
      children: [
        _row('Distinctive Marks', record.identificationMarks, textMut, textPri),
        _row('Scars & Surgeries', record.scars, textMut, textPri),
        _row('Tattoos & Body Art', record.tattoos, textMut, textPri),
        _row('Birthmarks', record.birthmarks, textMut, textPri),
        _row('Dental Characteristics', record.dentalCharacteristics, textMut, textPri),
      ],
    );
  }

  Widget _buildSection4Clothing(UdbRecord record, bool isLight, Color cardBg, Color border, Color textPri, Color textSec, Color textMut) {
    return _panel(
      title: '4. Clothing, Footwear & Personal Effects',
      icon: Icons.checkroom_outlined,
      isLight: isLight,
      cardBg: cardBg,
      border: border,
      textPri: textPri,
      children: [
        _row('Clothing Description', record.clothing, textMut, textPri),
        _row('Jewellery & Personal Belongings', record.personalBelongings, textMut, textPri),
      ],
    );
  }

  Widget _panel({
    required String title,
    required IconData icon,
    required bool isLight,
    required Color cardBg,
    required Color border,
    required Color textPri,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
        boxShadow: isLight
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.gold, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: isLight ? AppColors.lightDivider : AppColors.darkDivider),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String value, Color textMut, Color textPri) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: TextStyle(color: textMut, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Not recorded',
              style: TextStyle(color: textPri, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaseMilestoneTracker(
    UdbRecord record,
    bool isLight,
    Color cardBg,
    Color border,
    Color textPri,
    Color textSec,
  ) {
    final hasInquest = record.documents.any((d) => d.type == 'inquest_report');
    final hasAutopsy = record.documents.any((d) => d.type == 'postmortem_report');
    final hasBio = record.hasDna || record.hasFingerprint;
    final isGazetted = record.isPublicPublished;
    final isIdentified = record.status.toLowerCase().contains('identified');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timeline_rounded, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'CrPC & Interpol DVI Legal Case Progression Timeline',
                style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _milestoneItem('1. Inquest Filed', 'CrPC §174', hasInquest || record.gdCaseReference.isNotEmpty, AppColors.blue, isLight),
                _milestoneConnector(true, AppColors.blue),
                _milestoneItem('2. Autopsy Done', record.postmortemReference, hasAutopsy, AppColors.green, isLight),
                _milestoneConnector(hasAutopsy, AppColors.green),
                _milestoneItem('3. Biometrics DNA/AFIS', record.hasDna ? 'DNA Profiled' : 'Pending', hasBio, AppColors.purple, isLight),
                _milestoneConnector(hasBio, AppColors.purple),
                _milestoneItem('4. Gazette Published', 'Public Notice', isGazetted, AppColors.gold, isLight),
                _milestoneConnector(isGazetted, AppColors.gold),
                _milestoneItem('5. Identification', record.status, isIdentified, AppColors.green, isLight),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _milestoneItem(String title, String subtitle, bool isDone, Color accentColor, bool isLight) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: isDone ? accentColor : (isLight ? AppColors.slate200 : AppColors.darkBorder),
          child: Icon(
            isDone ? Icons.check : Icons.circle,
            size: 13,
            color: isDone ? Colors.white : AppColors.slate400,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isDone ? FontWeight.bold : FontWeight.w500,
                color: isDone ? (isLight ? AppColors.slate900 : Colors.white) : AppColors.slate400,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 9.5,
                color: isDone ? accentColor : AppColors.slate400,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _milestoneConnector(bool isDone, Color color) {
    return Container(
      width: 28,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: isDone ? color : AppColors.slate300,
    );
  }
}
