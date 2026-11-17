import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive.dart';
import '../../models/udb_record.dart';
import '../../models/forensic_photo.dart';
import '../../models/forensic_document.dart';
import '../../providers/udb_provider.dart';
import '../../providers/auth_provider.dart';

class CaseRegistrationView extends StatefulWidget {
  final VoidCallback onSuccess;

  const CaseRegistrationView({super.key, required this.onSuccess});

  @override
  State<CaseRegistrationView> createState() => _CaseRegistrationViewState();
}

class _CaseRegistrationViewState extends State<CaseRegistrationView> {
  final _formKey = GlobalKey<FormState>();

  String _inputTeam = AppConstants.inputTeams.first;
  final _referenceController = TextEditingController(text: 'CIB-UDB-2026-025');
  final _gdController = TextEditingController();
  final _recoveryOfficerController = TextEditingController();
  final _placeFoundController = TextEditingController();
  final _locationDetailsController = TextEditingController();
  String _division = 'Dhaka';
  final _districtController = TextEditingController(text: 'Dhaka');
  final _thanaController = TextEditingController();

  String _gender = 'Male';
  final _ageController = TextEditingController(text: '32');
  String _ageGroup = '26-35 (Adult)';
  final _heightController = TextEditingController(text: '170');
  final _weightController = TextEditingController(text: '65');
  String _bodyCondition = AppConstants.bodyConditions.first;
  final _complexionController = TextEditingController(text: 'Wheatish');
  final _hairController = TextEditingController(text: 'Short black');
  final _facialHairController = TextEditingController(text: 'Clean shaven');

  final _marksController = TextEditingController();
  final _scarsController = TextEditingController();
  final _tattoosController = TextEditingController();
  final _dentalController = TextEditingController();

  final _clothingController = TextEditingController();
  final _belongingsController = TextEditingController();

  String _fingerprint = 'Fingerprint collected (10-Print AFIS card filed)';
  String _dna = 'DNA sample pending lab analysis';
  final _postmortemRefController = TextEditingController();
  final _narrativeController = TextEditingController();
  final _remarksController = TextEditingController();

  final List<ForensicPhoto> _photos = [];

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _recoveryOfficerController.text = '${auth.session.rank} ${auth.session.fullName}, ${auth.session.unitThana}';
    _photos.add(const ForensicPhoto(
      id: 'p_reg_1',
      category: 'face',
      caption: 'Frontal identification photo',
      previewUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=600&q=80',
      isPrimary: true,
      savingsPercentage: '82%',
    ));
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _gdController.dispose();
    _recoveryOfficerController.dispose();
    _placeFoundController.dispose();
    _locationDetailsController.dispose();
    _districtController.dispose();
    _thanaController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _complexionController.dispose();
    _hairController.dispose();
    _facialHairController.dispose();
    _marksController.dispose();
    _scarsController.dispose();
    _tattoosController.dispose();
    _dentalController.dispose();
    _clothingController.dispose();
    _belongingsController.dispose();
    _postmortemRefController.dispose();
    _narrativeController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final newRecord = UdbRecord(
        id: 'rec_${DateTime.now().millisecondsSinceEpoch}',
        referenceNo: _referenceController.text.trim().toUpperCase(),
        inputTeam: _inputTeam,
        dateFound: DateTime.now().toString().split(' ')[0],
        timeFound: '09:00 AM',
        division: _division,
        district: _districtController.text.trim(),
        thana: _thanaController.text.trim(),
        placeFound: _placeFoundController.text.trim(),
        locationFound: _locationDetailsController.text.trim(),
        gdCaseReference: _gdController.text.trim(),
        recoveryOfficerUnit: _recoveryOfficerController.text.trim(),
        gender: _gender,
        estimatedAge: int.tryParse(_ageController.text.trim()) ?? 30,
        ageGroup: _ageGroup,
        heightCm: int.tryParse(_heightController.text.trim()) ?? 170,
        weightKg: int.tryParse(_weightController.text.trim()) ?? 65,
        bodyCondition: _bodyCondition,
        complexion: _complexionController.text.trim(),
        hair: _hairController.text.trim(),
        facialHair: _facialHairController.text.trim(),
        identificationMarks: _marksController.text.trim(),
        scars: _scarsController.text.trim(),
        tattoos: _tattoosController.text.trim(),
        dentalCharacteristics: _dentalController.text.trim(),
        clothing: _clothingController.text.trim(),
        personalBelongings: _belongingsController.text.trim(),
        fingerprintAvailability: _fingerprint,
        dnaProfileAvailability: _dna,
        postmortemReference: _postmortemRefController.text.trim().isNotEmpty
            ? _postmortemRefController.text.trim()
            : 'Pending mortuary report',
        description: _narrativeController.text.trim(),
        remarks: _remarksController.text.trim(),
        status: 'Unidentified - new entry',
        photos: _photos,
        documents: [
          ForensicDocument(
            id: 'doc_${DateTime.now().millisecondsSinceEpoch}',
            type: 'inquest_report',
            title: 'Police Inquest Report',
            referenceNumber: _gdController.text.trim(),
            originalName: 'Inquest_Field_Scan.pdf',
            sizeHuman: '1.9 MB',
            fileUrl: '#',
            sha256Hash: '9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d3e2f1a0b9c8d7e6f5a4b3c2d1e0f9a8b',
            uploadedAt: 'Just now',
          ),
        ],
      );

      context.read<UdbProvider>().addRecord(newRecord);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deceased record ${newRecord.referenceNo} registered in CIB database!'),
          backgroundColor: AppColors.green,
        ),
      );
      widget.onSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cardBg = isLight ? Colors.white : AppColors.darkCardBg;
    final borderColor = isLight ? AppColors.lightBorder : AppColors.darkBorder;
    final textPri = isLight ? AppColors.lightTextPrimary : AppColors.darkTextPrimary;
    final textSec = isLight ? AppColors.lightTextSecondary : AppColors.darkTextSecondary;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 16,
        vertical: 32,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner
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
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.note_add_rounded, color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Register Unidentified Deceased Record (Interpol DVI Standard Intake)',
                              style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Standardized protocol compliant with Interpol Pink Form (PM Form) & NamUs. '
                              'All fields are catalogued for automated cross-matching against missing persons.',
                              style: TextStyle(color: textSec, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Section 1
                _sectionCard(
                  title: '1. Administrative & Recovery Particulars (প্রশাসনিক ও উদ্ধারের তথ্য)',
                  icon: Icons.folder_shared_outlined,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _inputTeam,
                            decoration: const InputDecoration(labelText: 'Intake Section / Unit *'),
                            dropdownColor: AppColors.cardBg,
                            items: AppConstants.inputTeams.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12)))).toList(),
                            onChanged: (v) => setState(() => _inputTeam = v!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _referenceController,
                            decoration: const InputDecoration(labelText: 'CIB Reference Number *'),
                            validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _gdController,
                            decoration: const InputDecoration(labelText: 'Thana GD / FIR Reference *', hintText: 'GD No. 1042/26, Ramna PS'),
                            validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _recoveryOfficerController,
                            decoration: const InputDecoration(labelText: 'Recovery Officer & Unit *'),
                            validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _division,
                            decoration: const InputDecoration(labelText: 'Division *'),
                            dropdownColor: AppColors.cardBg,
                            items: AppConstants.divisions.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                            onChanged: (v) => setState(() => _division = v!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _districtController,
                            decoration: const InputDecoration(labelText: 'District *'),
                            validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _thanaController,
                            decoration: const InputDecoration(labelText: 'Police Station (Thana) *'),
                            validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _placeFoundController,
                      decoration: const InputDecoration(labelText: 'Place Found (General Area) *', hintText: 'Under overpass near railway road divider'),
                      validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationDetailsController,
                      decoration: const InputDecoration(labelText: 'Detailed Coordinates / Spot Landmarks', hintText: 'GPS: 23.7289 N, 90.3982 E • Near Gate 2'),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Section 2
                _sectionCard(
                  title: '2. Physical & Biometric Descriptors (শারীরিক ও জৈবিক বিবরণ)',
                  icon: Icons.accessibility_new_outlined,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _gender,
                            decoration: const InputDecoration(labelText: 'Biological Sex *'),
                            dropdownColor: AppColors.cardBg,
                            items: AppConstants.genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                            onChanged: (v) => setState(() => _gender = v!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Estimated Age (Years) *'),
                            validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _ageGroup,
                            decoration: const InputDecoration(labelText: 'Age Bracket *'),
                            dropdownColor: AppColors.cardBg,
                            items: AppConstants.ageGroups.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
                            onChanged: (v) => setState(() => _ageGroup = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _heightController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Height (cm) *'),
                            validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _weightController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Weight (kg) *'),
                            validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _bodyCondition,
                            decoration: const InputDecoration(labelText: 'Body Condition *'),
                            dropdownColor: AppColors.cardBg,
                            items: AppConstants.bodyConditions.map((b) => DropdownMenuItem(value: b, child: Text(b, style: const TextStyle(fontSize: 12)))).toList(),
                            onChanged: (v) => setState(() => _bodyCondition = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: _complexionController, decoration: const InputDecoration(labelText: 'Complexion'))),
                        const SizedBox(width: 16),
                        Expanded(child: TextFormField(controller: _hairController, decoration: const InputDecoration(labelText: 'Hair'))),
                        const SizedBox(width: 16),
                        Expanded(child: TextFormField(controller: _facialHairController, decoration: const InputDecoration(labelText: 'Facial Hair'))),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Section 3
                _sectionCard(
                  title: '3. Identifying Marks, Scars, Tattoos & Dental (চিহ্ন, দাগ ও দাঁত)',
                  icon: Icons.fingerprint,
                  children: [
                    TextFormField(
                      controller: _marksController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Distinctive Identification Marks *',
                        hintText: 'Cut scars, moles, deformities, amputations...',
                      ),
                      validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: _scarsController, decoration: const InputDecoration(labelText: 'Surgical Scars'))),
                        const SizedBox(width: 16),
                        Expanded(child: TextFormField(controller: _tattoosController, decoration: const InputDecoration(labelText: 'Tattoos & Body Art'))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dentalController,
                      decoration: const InputDecoration(labelText: 'Dental Characteristics', hintText: 'Missing teeth, crowns, bridges, dentures...'),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Section 4
                _sectionCard(
                  title: '4. Clothing, Apparel & Personal Effects (পোশাক ও সামগ্রী)',
                  icon: Icons.checkroom_outlined,
                  children: [
                    TextFormField(
                      controller: _clothingController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Clothing & Footwear Description *',
                        hintText: 'Color, fabric, pattern, brand, shoes, slippers...',
                      ),
                      validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _belongingsController,
                      decoration: const InputDecoration(
                        labelText: 'Jewellery, Valuables & Belongings',
                        hintText: 'Rings, amulets, keys, watch, wallet contents...',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Section 5
                _sectionCard(
                  title: '5. Biometric AFIS & Forensic Lab References (ফরেনসিক অবস্থা)',
                  icon: Icons.biotech_outlined,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _fingerprint,
                            decoration: const InputDecoration(labelText: 'AFIS Fingerprint Status *'),
                            dropdownColor: AppColors.cardBg,
                            items: [
                              'Fingerprint collected (10-Print AFIS card filed)',
                              'Fingerprint partial',
                              'Fingerprint unavailable',
                            ].map((f) => DropdownMenuItem(value: f, child: Text(f, style: const TextStyle(fontSize: 12)))).toList(),
                            onChanged: (v) => setState(() => _fingerprint = v!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _dna,
                            decoration: const InputDecoration(labelText: 'DNA Profile Status *'),
                            dropdownColor: AppColors.cardBg,
                            items: [
                              'DNA profile available (Archived at CID Lab)',
                              'DNA sample pending lab analysis',
                              'DNA unavailable',
                            ].map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 12)))).toList(),
                            onChanged: (v) => setState(() => _dna = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _postmortemRefController,
                      decoration: const InputDecoration(labelText: 'Post-Mortem Autopsy Reference No.', hintText: 'PM-DMC-842/26'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _narrativeController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Case Circumstances & Narrative Summary *',
                        hintText: 'Detailed recovery circumstances, wounds, preliminary observations...',
                      ),
                      validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _remarksController,
                      decoration: const InputDecoration(
                        labelText: 'Confidential Officer Remarks',
                        hintText: 'Internal intelligence notes, suspects, cross-reference leads...',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: widget.onSuccess,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Register Deceased Record in CIB Database'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required IconData icon, required List<Widget> children}) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cardBg = isLight ? Colors.white : AppColors.darkCardBg;
    final borderColor = isLight ? AppColors.lightBorder : AppColors.darkBorder;
    final textPri = isLight ? AppColors.lightTextPrimary : AppColors.darkTextPrimary;

    return Container(
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}
