import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/link_service.dart';
import '../../models/udb_record.dart';
import '../../models/user_session.dart';

class OfficialDossierPrintDialog extends StatelessWidget {
  final UdbRecord record;
  final UserSession session;

  const OfficialDossierPrintDialog({
    super.key,
    required this.record,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkCardBg : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920, maxHeight: 920),
        child: Column(
          children: [
            // Action Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                border: Border(bottom: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.print_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'OFFICIAL FORENSIC CASE DOSSIER • PRINT & ARCHIVE SHEET',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.slate900,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () {
                      LinkService.printOfficialDossier(record, session);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Printing dossier ${record.referenceNo} with cryptographic watermark [${session.bpNumber}].',
                          ),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    icon: const Icon(Icons.print, size: 15),
                    label: const Text('Print Document (A4)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.close, color: isDark ? AppColors.slate400 : AppColors.slate600),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Printable Paper Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(36),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x10000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Header with CID Logo
                      Image.asset(
                        'assets/images/cid-logo-blue.png',
                        height: 64,
                        errorBuilder: (_, _, _) => const Icon(Icons.shield_outlined, color: AppColors.primary, size: 54),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'CRIMINAL INVESTIGATION DEPARTMENT (CID)',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const Text(
                        'CENTRAL INTELLIGENCE BUREAU (CIB) • BANGLADESH POLICE',
                        style: TextStyle(
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'National Forensic Portal for Unidentified Dead Body Identification (Interpol DVI Standards)',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                      ),

                      const SizedBox(height: 14),

                      // Document Title & Barcode Box
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          border: Border.all(color: const Color(0xFF94A3B8)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CASE REFERENCE: ${record.referenceNo}',
                                  style: const TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'GD/FIR No: ${record.gdCaseReference} • Thana: ${record.thana}, ${record.district}',
                                  style: const TextStyle(color: Color(0xFF475569), fontSize: 11),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2E8F0),
                                border: Border.all(color: const Color(0xFF94A3B8)),
                              ),
                              child: Text(
                                'STATUS: ${record.status.toUpperCase()}',
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Cryptographic Watermark Notice
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        color: const Color(0xFFFFFBEB),
                        child: Text(
                          'SECURITY NOTICE: Generated for official police use by [${session.rank} ${session.fullName}, BP: ${session.bpNumber}]. '
                          'Cryptographic audit fingerprint embedded. Unauthorized dissemination is punishable under Section 29 of the Police Act.',
                          style: const TextStyle(color: Color(0xFF92400E), fontSize: 9.5, fontStyle: FontStyle.italic),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 1. Recovery Particulars
                      _sectionHeader('1. RECOVERY & JURISDICTIONAL PARTICULARS'),
                      _infoTable([
                        ['Discovery Date & Time', '${record.dateFound} at ${record.timeFound}'],
                        ['Recovery Spot Location', record.locationFound],
                        ['General Area / Landmark', record.placeFound],
                        ['Jurisdictional Thana & District', '${record.thana} PS, ${record.district} District (${record.division} Division)'],
                        ['Recovery Officer & Team', record.recoveryOfficerUnit],
                        ['Inquest Legal Basis', 'CrPC Section 174 & PRB Regulation 299'],
                      ]),

                      const SizedBox(height: 16),

                      // 2. Anthropological Profile
                      _sectionHeader('2. ANTHROPOLOGICAL PROFILE (INTERPOL DVI PM-FORM)'),
                      _infoTable([
                        ['Biological Sex', record.gender],
                        ['Estimated Age & Bracket', '~${record.estimatedAge} Years (${record.ageGroup})'],
                        ['Stature / Height', '${record.heightCm} cm'],
                        ['Approximate Weight', '${record.weightKg} kg'],
                        ['Body Decomposition State', record.bodyCondition],
                        ['Estimated Time Since Death', record.estimatedDeathTime],
                        ['Complexion & Tone', record.complexion],
                        ['Hair Characteristics', record.hair],
                        ['Facial Hair', record.facialHair],
                      ]),

                      const SizedBox(height: 16),

                      // 3. Marks, Scars & Dental
                      _sectionHeader('3. IDENTIFYING MARKS, SCARS, TATTOOS & DENTAL CHARTING'),
                      _infoTable([
                        ['Distinctive Identification Marks', record.identificationMarks],
                        ['Surgical Scars & Trauma Scars', record.scars],
                        ['Tattoos & Body Art', record.tattoos],
                        ['Dental Characteristics', record.dentalCharacteristics],
                        ['Birthmarks', record.birthmarks],
                      ]),

                      const SizedBox(height: 16),

                      // 4. Clothing & Personal Effects
                      _sectionHeader('4. CLOTHING, FOOTWEAR & PERSONAL EFFECTS'),
                      _infoTable([
                        ['Clothing Description', record.clothing],
                        ['Jewellery & Personal Belongings', record.personalBelongings],
                      ]),

                      const SizedBox(height: 16),

                      // 5. Biometric Identifiers & Forensic Labs
                      _sectionHeader('5. FORENSIC LAB BIOMETRICS & DOCUMENT REGISTRY'),
                      _infoTable([
                        ['AFIS 10-Print Fingerprint Status', record.fingerprintAvailability],
                        ['DNA Profile Lab Availability', record.dnaProfileAvailability],
                        ['Post-Mortem Autopsy Reference', record.postmortemReference],
                        ['Forensic Lab Reference', record.linkedForensicRecord],
                      ]),

                      const SizedBox(height: 16),

                      // 6. Investigative Narrative
                      _sectionHeader('6. INVESTIGATIVE CIRCUMSTANCES & RECOVERY SUMMARY'),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Text(
                          record.description,
                          style: const TextStyle(color: Color(0xFF1E293B), fontSize: 11, height: 1.5),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Signature Block
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _signatureBox('Investigation Officer (IO)', 'Sub-Inspector of Police\nJurisdictional Thana'),
                          _signatureBox('Forensic Medical Examiner', 'Medical Officer / Mortuary\nPost-Mortem Examiner'),
                          _signatureBox('Superintendent of Police', 'CID Central Intelligence Bureau\nDhaka Headquarters'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF1E293B),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 10.5,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _infoTable(List<List<String>> rows) {
    return Table(
      border: TableBorder.all(color: const Color(0xFFCBD5E1)),
      columnWidths: const {
        0: FlexColumnWidth(2.2),
        1: FlexColumnWidth(4.5),
      },
      children: rows.map((r) {
        return TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Text(
                r[0],
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.bold,
                  fontSize: 10.5,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Text(
                r[1].isNotEmpty ? r[1] : 'Not recorded',
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 10.5,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _signatureBox(String role, String sub) {
    return Column(
      children: [
        Container(
          width: 180,
          height: 48,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFF475569), width: 1.2)),
          ),
        ),
        const SizedBox(height: 6),
        Text(role, style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 11)),
        Text(sub, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF64748B), fontSize: 9.5)),
      ],
    );
  }
}
