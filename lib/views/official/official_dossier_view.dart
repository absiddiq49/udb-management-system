import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../models/udb_record.dart';
import '../../models/forensic_document.dart';
import '../../providers/auth_provider.dart';
import '../../providers/udb_provider.dart';

class OfficialDossierView extends StatefulWidget {
  final UdbRecord record;
  final VoidCallback onBack;

  const OfficialDossierView({
    super.key,
    required this.record,
    required this.onBack,
  });

  @override
  State<OfficialDossierView> createState() => _OfficialDossierViewState();
}

class _OfficialDossierViewState extends State<OfficialDossierView> {
  int _activePhotoIndex = 0;
  bool _blurPhotos = false;

  void _updateStatus(String newStatus) {
    final updated = widget.record.copyWith(status: newStatus);
    context.read<UdbProvider>().updateRecord(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Case status updated to "$newStatus"'),
        backgroundColor: AppColors.primary,
      ),
    );
    setState(() {});
  }

  void _simulateDownload(ForensicDocument doc) {
    final auth = context.read<AuthProvider>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Downloading ${doc.originalName} • Cryptographically watermarked with [${auth.session.bpNumber}] for legal chain of custody.',
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDesktop = Responsive.isDesktop(context);
    final record = widget.record;

    final isLight = Theme.of(context).brightness == Brightness.light;
    final cardBg = isLight ? Colors.white : AppColors.darkCardBg;
    final borderColor = isLight ? AppColors.lightBorder : AppColors.darkBorder;
    final textPri = isLight ? AppColors.lightTextPrimary : AppColors.darkTextPrimary;
    final textSec = isLight ? AppColors.lightTextSecondary : AppColors.darkTextSecondary;

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
              // Header Nav & Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back_rounded, size: 16),
                    label: const Text('Back to Management Console'),
                    style: TextButton.styleFrom(foregroundColor: textSec),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 15),
                            const SizedBox(width: 6),
                            Text(
                              'Authorized: ${auth.session.rank} ${auth.session.fullName}',
                              style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Preparing official police print layout with watermark...'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        },
                        icon: const Icon(Icons.print_rounded, size: 15),
                        label: const Text('Print Official Dossier'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: isLight ? AppColors.slate300 : AppColors.darkBorder),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Top Title & Case Status Bar
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                  boxShadow: isLight
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.purpleLight,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.purpleBorder),
                          ),
                          child: const Text(
                            'INTERPOL DVI POST-MORTEM (PINK FORM) STANDARD DOSSIER',
                            style: TextStyle(color: AppColors.purple, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: _updateStatus,
                          color: cardBg,
                          itemBuilder: (context) => [
                            'Unidentified - active matching',
                            'Unidentified - under verification',
                            'Probable match found',
                            'Identified and closed',
                          ].map((s) => PopupMenuItem(value: s, child: Text(s, style: TextStyle(color: textPri, fontSize: 12)))).toList(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.goldLight,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.goldBorder),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Status: ${record.status}',
                                  style: const TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_drop_down, color: AppColors.gold, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      record.referenceNo,
                      style: TextStyle(color: textPri, fontSize: 28, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Originating Team: ${record.inputTeam} • GD/FIR Ref: ${record.gdCaseReference} • Post-Mortem Mortuary Ref: ${record.postmortemReference}',
                      style: TextStyle(color: textSec, fontSize: 13),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Attached Official Reports & Legal Documents
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                  boxShadow: isLight
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.attach_file_rounded, color: AppColors.primary, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Legal & Forensic Document Vault (সুরতহাল ও ময়নাতদন্ত প্রতিবেদন)',
                          style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.greenLight,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.greenBorder),
                          ),
                          child: const Text('SHA-256 Validated', style: TextStyle(color: AppColors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(),
                    const SizedBox(height: 14),

                    // Grid of 3 core legal documents
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final double width = constraints.maxWidth;
                        final int count = width > 900 ? 3 : width > 600 ? 2 : 1;

                        return GridView.count(
                          crossAxisCount: count,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: width > 900 ? 1.6 : 1.8,
                          children: [
                            _buildDocCard(
                              title: 'Police Inquest Report (সুরতহাল)',
                              subtitle: 'CrPC Section 174 Executive / Magistrate Inquest',
                              isLight: isLight,
                              textPri: textPri,
                              textSec: textSec,
                              doc: record.documents.firstWhere((d) => d.type == 'inquest_report',
                                  orElse: () => const ForensicDocument(
                                        id: 'd_def1',
                                        type: 'inquest_report',
                                        title: 'Inquest Report',
                                        referenceNumber: 'INQ-PLT-118/26',
                                        originalName: 'Inquest_Scan.pdf',
                                        sizeHuman: '2.1 MB',
                                        fileUrl: '#',
                                        sha256Hash: 'a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8',
                                        uploadedAt: 'Verified',
                                      )),
                            ),
                            _buildDocCard(
                              title: 'Post-Mortem Autopsy Report (ময়নাতদন্ত)',
                              subtitle: 'Govt. Medical College Forensic Mortuary',
                              isLight: isLight,
                              textPri: textPri,
                              textSec: textSec,
                              doc: record.documents.firstWhere((d) => d.type == 'postmortem_report',
                                  orElse: () => ForensicDocument(
                                        id: 'd_def2',
                                        type: 'postmortem_report',
                                        title: 'Post-Mortem Autopsy Report',
                                        referenceNumber: record.postmortemReference,
                                        originalName: 'Mortuary_Autopsy_Report.pdf',
                                        sizeHuman: '3.4 MB',
                                        fileUrl: '#',
                                        sha256Hash: 'c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2',
                                        uploadedAt: 'Verified',
                                      )),
                            ),
                            _buildDocCard(
                              title: 'Forensic DNA & AFIS Dossier',
                              subtitle: 'CID National DNA Profiling Laboratory',
                              isLight: isLight,
                              textPri: textPri,
                              textSec: textSec,
                              doc: record.documents.firstWhere((d) => d.type == 'dna_report',
                                  orElse: () => ForensicDocument(
                                        id: 'd_def3',
                                        type: 'dna_report',
                                        title: 'DNA Profiling & STR Analysis',
                                        referenceNumber: record.linkedForensicRecord,
                                        originalName: 'CID_DNA_Profiling_Report.pdf',
                                        sizeHuman: '1.8 MB',
                                        fileUrl: '#',
                                        sha256Hash: 'e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4',
                                        uploadedAt: 'Verified',
                                      )),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Forensic Photographic Evidence Gallery (Unblurred HD Officer View)
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                  boxShadow: isLight
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
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
                        Text(
                          'Photographic Catalog (High-Resolution Archive)',
                          style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        IconButton(
                          icon: Icon(_blurPhotos ? Icons.visibility_off : Icons.visibility, color: AppColors.primary, size: 20),
                          tooltip: 'Toggle Officer Blur Filter',
                          onPressed: () => setState(() => _blurPhotos = !_blurPhotos),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    if (activePhoto != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          activePhoto.previewUrl,
                          height: 400,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            height: 300,
                            color: isLight ? AppColors.slate100 : AppColors.darkSurface,
                            child: Center(child: Icon(Icons.broken_image, size: 40, color: textSec)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Category: ${activePhoto.category.toUpperCase()} • Caption: ${activePhoto.caption}',
                        style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
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
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected ? AppColors.primary : (isLight ? AppColors.slate200 : AppColors.darkBorder),
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Image.network(p.previewUrl, fit: BoxFit.cover),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 7 Interpol DVI Sections
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildSection1(record, cardBg, borderColor, textPri, textSec)),
                    const SizedBox(width: 20),
                    Expanded(child: _buildSection2(record, cardBg, borderColor, textPri, textSec)),
                  ],
                )
              else ...[
                _buildSection1(record, cardBg, borderColor, textPri, textSec),
                const SizedBox(height: 20),
                _buildSection2(record, cardBg, borderColor, textPri, textSec),
              ],

              const SizedBox(height: 20),

              _buildSection3(record, cardBg, borderColor, textPri, textSec),

              const SizedBox(height: 20),

              _buildSection4(record, cardBg, borderColor, textPri, textSec),

              const SizedBox(height: 20),

              _buildSection5(record, cardBg, borderColor, textPri, textSec),

              const SizedBox(height: 20),

              // Section 6: Officer Narrative & Confidential Intelligence Remarks
              _buildSection6(record, cardBg, borderColor, textPri, textSec),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocCard({
    required String title,
    required String subtitle,
    required ForensicDocument doc,
    required bool isLight,
    required Color textPri,
    required Color textSec,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isLight ? AppColors.slate50 : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isLight ? AppColors.slate200 : AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: isLight ? AppColors.slate400 : AppColors.darkTextMuted, fontSize: 11)),
          const SizedBox(height: 4),
          Text('Ref: ${doc.referenceNumber} (${doc.sizeHuman})', style: TextStyle(color: textSec, fontSize: 11)),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _simulateDownload(doc),
              icon: const Icon(Icons.download_rounded, size: 14),
              label: const Text('Download Official Scan', style: TextStyle(fontSize: 11)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: isLight ? AppColors.slate300 : AppColors.darkBorder),
                padding: const EdgeInsets.symmetric(vertical: 6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection1(UdbRecord record, Color cardBg, Color borderColor, Color textPri, Color textSec) {
    return _panel('Section 1: Administrative & Recovery Particulars', Icons.folder_shared_outlined, cardBg, borderColor, textPri, textSec, [
      _row('Date & Time Found', '${record.dateFound} • ${record.timeFound}', textPri, textSec),
      _row('General Recovery Location', record.placeFound, textPri, textSec),
      _row('Detailed Coordinates / Spot', record.locationFound, textPri, textSec),
      _row('Police Station (Thana)', record.thana, textPri, textSec),
      _row('District & Division', '${record.district}, ${record.division}', textPri, textSec),
      _row('Recovery Officer / Unit', record.recoveryOfficerUnit, textPri, textSec),
      _row('GD / FIR Case Reference', record.gdCaseReference, textPri, textSec),
      _row('Originating Intake Unit', record.inputTeam, textPri, textSec),
    ]);
  }

  Widget _buildSection2(UdbRecord record, Color cardBg, Color borderColor, Color textPri, Color textSec) {
    return _panel('Section 2: Anthropological & Biometric Descriptors', Icons.accessibility_new_outlined, cardBg, borderColor, textPri, textSec, [
      _row('Biological Sex', record.gender, textPri, textSec),
      _row('Estimated Age', '~${record.estimatedAge} Years (Bracket: ${record.ageGroup})', textPri, textSec),
      _row('Height & Weight', '${record.heightCm} cm • ${record.weightKg} kg', textPri, textSec),
      _row('Body Condition', record.bodyCondition, textPri, textSec),
      _row('Est. Post-Mortem Interval', record.estimatedDeathTime, textPri, textSec),
      _row('Complexion / Tone', record.complexion, textPri, textSec),
      _row('Hair & Facial Hair', '${record.hair} • ${record.facialHair}', textPri, textSec),
    ]);
  }

  Widget _buildSection3(UdbRecord record, Color cardBg, Color borderColor, Color textPri, Color textSec) {
    return _panel('Section 3: Identifying Marks, Scars, Tattoos & Dental Charting', Icons.fingerprint_rounded, cardBg, borderColor, textPri, textSec, [
      _row('Distinctive Identification Marks', record.identificationMarks, textPri, textSec),
      _row('Scars & Surgeries', record.scars, textPri, textSec),
      _row('Tattoos & Body Art', record.tattoos, textPri, textSec),
      _row('Birthmarks', record.birthmarks, textPri, textSec),
      _row('Dental Charting & Tooth Alignment', record.dentalCharacteristics, textPri, textSec),
    ]);
  }

  Widget _buildSection4(UdbRecord record, Color cardBg, Color borderColor, Color textPri, Color textSec) {
    return _panel('Section 4: Clothing, Apparel & Personal Effects', Icons.checkroom_outlined, cardBg, borderColor, textPri, textSec, [
      _row('Clothing & Footwear Description', record.clothing, textPri, textSec),
      _row('Jewellery, Valuables & Pockets', record.personalBelongings, textPri, textSec),
    ]);
  }

  Widget _buildSection5(UdbRecord record, Color cardBg, Color borderColor, Color textPri, Color textSec) {
    return _panel('Section 5: Forensic Identifiers & Lab Status', Icons.biotech_outlined, cardBg, borderColor, textPri, textSec, [
      _row('AFIS Fingerprint 10-Print Status', record.fingerprintAvailability, textPri, textSec),
      _row('DNA Profiling & STR Loci Status', record.dnaProfileAvailability, textPri, textSec),
      _row('Post-Mortem Autopsy Reference', record.postmortemReference, textPri, textSec),
      _row('Linked Forensic Records', record.linkedForensicRecord, textPri, textSec),
    ]);
  }

  Widget _buildSection6(UdbRecord record, Color cardBg, Color borderColor, Color textPri, Color textSec) {
    return _panel('Section 6 & 7: Case Narrative & Confidential Intelligence Remarks', Icons.security_rounded, cardBg, borderColor, textPri, textSec, [
      _row('Case Circumstances & Narrative', record.description, textPri, textSec),
      _row('Confidential Officer Remarks', record.remarks.isNotEmpty ? record.remarks : 'No internal intelligence remarks logged.', textPri, textSec),
    ]);
  }

  Widget _panel(String title, IconData icon, Color cardBg, Color borderColor, Color textPri, Color textSec, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Text(title, style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String value, Color textPri, Color textSec) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 170,
            child: Text(label, style: TextStyle(color: textSec, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: textPri, fontSize: 13, height: 1.4)),
          ),
        ],
      ),
    );
  }
}
