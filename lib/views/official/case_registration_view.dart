import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/file_import_service.dart';
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
  int _currentStep = 0;

  // Step 1: Administrative & Recovery
  String _inputTeam = AppConstants.inputTeams.first;
  final _referenceController = TextEditingController(text: 'CIB-UDB-2026-025');
  final _gdController = TextEditingController(text: 'GD No. 1042/26, Ramna PS');
  final _recoveryOfficerController = TextEditingController();
  final _placeFoundController = TextEditingController(text: 'Under overpass near railway divider');
  final _locationDetailsController = TextEditingController(text: 'GPS: 23.7289 N, 90.3982 E • Near Gate 2');
  String _division = 'Dhaka';
  final _districtController = TextEditingController(text: 'Dhaka');
  final _thanaController = TextEditingController(text: 'Ramna');

  // Step 2: Physical & Anthropological
  String _gender = 'Male';
  final _ageController = TextEditingController(text: '32');
  String _ageGroup = '26-35 (Adult)';
  final _heightController = TextEditingController(text: '170');
  final _weightController = TextEditingController(text: '65');
  String _bodyCondition = AppConstants.bodyConditions.first;
  final _complexionController = TextEditingController(text: 'Wheatish');
  final _hairController = TextEditingController(text: 'Short black');
  final _facialHairController = TextEditingController(text: 'Clean shaven');

  // Step 3: Marks, Scars & Dental
  final _marksController = TextEditingController(text: '3cm linear scar across right forearm, circular burn mark near left shoulder.');
  final _scarsController = TextEditingController(text: 'Appendectomy scar in right lower abdomen.');
  final _tattoosController = TextEditingController(text: 'Faded anchor symbol tattooed on inner left wrist.');
  final _dentalController = TextEditingController(text: 'Upper right lateral incisor missing with healed socket.');

  // Step 4: Clothing & Belongings
  final _clothingController = TextEditingController(text: 'Navy blue polyester polo shirt with collar, dark denim jeans, black leather belt with silver buckle.');
  final _belongingsController = TextEditingController(text: 'Steel wristwatch (Titan), copper amulet on black cord around neck, key ring with 3 brass keys.');

  // Step 5: Biometrics, Forensic & Photos
  String _fingerprint = 'Fingerprint collected (10-Print AFIS card filed)';
  String _dna = 'DNA sample pending lab analysis';
  final _postmortemRefController = TextEditingController(text: 'PM-DMC-842/26');
  final _narrativeController = TextEditingController(text: 'Unidentified male recovered unresponsive by morning patrol. No external fatal blunt trauma visible. Handed over to Dhaka Medical College Mortuary for statutory post-mortem under CrPC 174.');
  final _remarksController = TextEditingController(text: 'Investigating missing person reports from Ramna and Shahbagh thanas.');

  final List<ForensicPhoto> _photos = [];

  final List<String> _stepTitles = [
    'Recovery & Jurisdiction',
    'Physical Descriptors',
    'Marks, Scars & Dental',
    'Clothing & Belongings',
    'Biometrics & Review',
  ];

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _recoveryOfficerController.text = '${auth.session.rank} ${auth.session.fullName}, ${auth.session.unitThana}';
    _photos.add(const ForensicPhoto(
      id: 'p_reg_1',
      category: 'face',
      caption: 'Frontal identification portrait (Mortuary)',
      previewUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=600&q=80',
      isPrimary: true,
      savingsPercentage: '82%',
    ));
    _photos.add(const ForensicPhoto(
      id: 'p_reg_2',
      category: 'belongings',
      caption: 'Steel wristwatch and recovered key ring',
      previewUrl: 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&w=600&q=80',
      isSensitive: false,
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

  void _nextStep() {
    if (_currentStep < _stepTitles.length - 1) {
      setState(() => _currentStep++);
    } else {
      _submit();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
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

  Future<void> _importPhotoDirect() async {
    final picked = await pickImageFromDevice();
    if (picked != null) {
      _promptPhotoDetails(picked);
    }
  }

  void _promptPhotoDetails(PickedImageFile picked) {
    final captionCtrl = TextEditingController(text: picked.name);
    String category = 'scene';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: AppColors.green, size: 20),
              SizedBox(width: 8),
              Text('Categorize Imported Photo'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    picked.dataUrl,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 140,
                      color: Colors.grey.shade200,
                      child: const Center(child: Icon(Icons.photo)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text('File: ${picked.name} (${picked.humanSize})', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Photo Category *'),
                  items: const [
                    DropdownMenuItem(value: 'face', child: Text('Facial Portrait (Sensitive)')),
                    DropdownMenuItem(value: 'scene', child: Text('Recovery Crime Scene')),
                    DropdownMenuItem(value: 'marks', child: Text('Marks / Tattoos / Scars')),
                    DropdownMenuItem(value: 'belongings', child: Text('Belongings & Clothing')),
                    DropdownMenuItem(value: 'dental', child: Text('Dental / X-Ray')),
                  ],
                  onChanged: (v) => setDlgState(() => category = v!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: captionCtrl,
                  decoration: const InputDecoration(labelText: 'Photo Caption / Anatomical Description *'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _photos.add(ForensicPhoto(
                    id: 'p_${DateTime.now().millisecondsSinceEpoch}',
                    category: category,
                    caption: captionCtrl.text.trim().isNotEmpty ? captionCtrl.text.trim() : picked.name,
                    previewUrl: picked.dataUrl,
                    isSensitive: category == 'face' || category == 'scene',
                  ));
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added "${picked.name}" to case photos.'),
                    backgroundColor: AppColors.green,
                  ),
                );
              },
              icon: const Icon(Icons.add_photo_alternate, size: 16),
              label: const Text('Add to Dossier'),
            ),
          ],
        ),
      ),
    );
  }

  void _addPhotoDialog() {
    final captionCtrl = TextEditingController();
    final urlCtrl = TextEditingController(text: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=600&q=80');
    String category = 'scene';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: const Text('Add Forensic Photo to Dossier'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await _importPhotoDirect();
                  },
                  icon: const Icon(Icons.file_upload_outlined, size: 18),
                  label: const Text('Pick Image from Desktop / Gallery'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('OR USE IMAGE URL', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Photo Category'),
                  items: const [
                    DropdownMenuItem(value: 'face', child: Text('Facial Portrait (Sensitive)')),
                    DropdownMenuItem(value: 'scene', child: Text('Recovery Crime Scene')),
                    DropdownMenuItem(value: 'marks', child: Text('Marks / Tattoos / Scars')),
                    DropdownMenuItem(value: 'belongings', child: Text('Belongings & Clothing')),
                    DropdownMenuItem(value: 'dental', child: Text('Dental / X-Ray')),
                  ],
                  onChanged: (v) => setDlgState(() => category = v!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: captionCtrl,
                  decoration: const InputDecoration(labelText: 'Photo Caption / Anatomical Description'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlCtrl,
                  decoration: const InputDecoration(labelText: 'Image Resource URL'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (captionCtrl.text.trim().isNotEmpty && urlCtrl.text.trim().isNotEmpty) {
                  setState(() {
                    _photos.add(ForensicPhoto(
                      id: 'p_${DateTime.now().millisecondsSinceEpoch}',
                      category: category,
                      caption: captionCtrl.text.trim(),
                      previewUrl: urlCtrl.text.trim(),
                      isSensitive: category == 'face' || category == 'scene',
                    ));
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Attach Photo'),
            ),
          ],
        ),
      ),
    );
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
                // Top Header Banner
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
                              'Register Unidentified Deceased Record (Interpol DVI Intake)',
                              style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Standardized 5-step intake wizard compliant with Interpol Pink Form (PM Form) & NamUs standards.',
                              style: TextStyle(color: textSec, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Stepper Progress Header
                _buildStepProgressIndicator(isLight, cardBg, borderColor, textPri, textSec),

                const SizedBox(height: 24),

                // Step Content
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _buildCurrentStepContent(isLight, cardBg, borderColor, textPri, textSec),
                ),

                const SizedBox(height: 24),

                // Navigation Controls (Back / Next / Submit)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      if (_currentStep > 0)
                        OutlinedButton.icon(
                          onPressed: _prevStep,
                          icon: const Icon(Icons.arrow_back_rounded, size: 16),
                          label: Text('Back: ${_stepTitles[_currentStep - 1]}'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          ),
                        )
                      else
                        OutlinedButton(
                          onPressed: widget.onSuccess,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          ),
                          child: const Text('Cancel Intake'),
                        ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: _nextStep,
                        icon: Icon(
                          _currentStep == _stepTitles.length - 1 ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
                          size: 18,
                        ),
                        label: Text(
                          _currentStep == _stepTitles.length - 1
                              ? 'Complete Intake & Save to CIB'
                              : 'Next: ${_stepTitles[_currentStep + 1]}',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _currentStep == _stepTitles.length - 1 ? AppColors.green : AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepProgressIndicator(
    bool isLight,
    Color cardBg,
    Color borderColor,
    Color textPri,
    Color textSec,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: List.generate(_stepTitles.length, (idx) {
          final isCompleted = idx < _currentStep;
          final isCurrent = idx == _currentStep;

          return Expanded(
            child: InkWell(
              onTap: () => setState(() => _currentStep = idx),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.green
                            : (isCurrent ? AppColors.primary : (isLight ? AppColors.slate200 : AppColors.darkSurface)),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : Text(
                                '${idx + 1}',
                                style: TextStyle(
                                  color: isCurrent ? Colors.white : textSec,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _stepTitles[idx],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isCurrent ? (isLight ? AppColors.primary : Colors.white) : textSec,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (idx < _stepTitles.length - 1)
                      Icon(Icons.chevron_right, size: 16, color: textSec.withValues(alpha: 0.5)),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStepContent(
    bool isLight,
    Color cardBg,
    Color borderColor,
    Color textPri,
    Color textSec,
  ) {
    switch (_currentStep) {
      case 0:
        return _buildStep1(isLight, cardBg, borderColor, textPri, textSec);
      case 1:
        return _buildStep2(isLight, cardBg, borderColor, textPri, textSec);
      case 2:
        return _buildStep3(isLight, cardBg, borderColor, textPri, textSec);
      case 3:
        return _buildStep4(isLight, cardBg, borderColor, textPri, textSec);
      case 4:
        return _buildStep5(isLight, cardBg, borderColor, textPri, textSec);
      default:
        return const SizedBox();
    }
  }

  // Step 1: Jurisdictional & Administrative
  Widget _buildStep1(bool isLight, Color cardBg, Color borderColor, Color textPri, Color textSec) {
    return _sectionCard(
      title: 'Step 1: Recovery Jurisdiction & Administrative Particulars',
      subtitle: 'Specify the recovery unit, Thana General Diary (GD) number, and geographical spot landmarks.',
      icon: Icons.folder_shared_outlined,
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _inputTeam,
                decoration: const InputDecoration(labelText: 'Intake Section / Unit *'),
                dropdownColor: AppColors.cardBg,
                items: AppConstants.inputTeams
                    .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12))))
                    .toList(),
                onChanged: (v) => setState(() => _inputTeam = v!),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _referenceController,
                decoration: const InputDecoration(labelText: 'CIB Reference Number *', hintText: 'CIB-UDB-2026-025'),
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
                value: _division,
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
          decoration: const InputDecoration(labelText: 'Place Found (General Area) *', hintText: 'e.g. Under overpass near railway divider'),
          validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _locationDetailsController,
          decoration: const InputDecoration(
            labelText: 'Detailed Coordinates / Spot Landmarks',
            hintText: 'GPS coordinates, railway pole number, bridge pillar, riverbank location...',
          ),
        ),
      ],
    );
  }

  // Step 2: Physical & Anthropological
  Widget _buildStep2(bool isLight, Color cardBg, Color borderColor, Color textPri, Color textSec) {
    return _sectionCard(
      title: 'Step 2: Physical & Anthropological Descriptors',
      subtitle: 'Interpol standard biological parameters used for multi-vector algorithmic matching.',
      icon: Icons.accessibility_new_outlined,
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _gender,
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
                value: _ageGroup,
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
                decoration: const InputDecoration(labelText: 'Height (cm) *', hintText: '170'),
                validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Weight (kg) *', hintText: '65'),
                validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _bodyCondition,
                decoration: const InputDecoration(labelText: 'Body Condition *'),
                dropdownColor: AppColors.cardBg,
                items: AppConstants.bodyConditions
                    .map((b) => DropdownMenuItem(value: b, child: Text(b, style: const TextStyle(fontSize: 12))))
                    .toList(),
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
            Expanded(child: TextFormField(controller: _hairController, decoration: const InputDecoration(labelText: 'Hair Description'))),
            const SizedBox(width: 16),
            Expanded(child: TextFormField(controller: _facialHairController, decoration: const InputDecoration(labelText: 'Facial Hair'))),
          ],
        ),
      ],
    );
  }

  // Step 3: Marks, Scars, Tattoos & Dental
  Widget _buildStep3(bool isLight, Color cardBg, Color borderColor, Color textPri, Color textSec) {
    return _sectionCard(
      title: 'Step 3: Marks, Scars, Tattoos & Dental Charting',
      subtitle: 'Crucial unique biometric signifiers with high forensic discriminative weighting.',
      icon: Icons.fingerprint,
      children: [
        TextFormField(
          controller: _marksController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Distinctive Identification Marks *',
            hintText: 'Cut marks, burn scars, moles, birthmarks, physical deformities, amputations...',
          ),
          validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _scarsController,
                decoration: const InputDecoration(
                  labelText: 'Surgical Scars',
                  hintText: 'e.g. Appendectomy, cesarean, orthopaedic surgical plates...',
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _tattoosController,
                decoration: const InputDecoration(
                  labelText: 'Tattoos & Body Art',
                  hintText: 'e.g. Names, religious symbols, motifs, anatomical location...',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _dentalController,
          decoration: const InputDecoration(
            labelText: 'Dental Characteristics (Interpol Odontology Spec)',
            hintText: 'Missing teeth, gold crowns, dentures, braces, diastema, extractions...',
          ),
        ),
      ],
    );
  }

  // Step 4: Clothing & Belongings
  Widget _buildStep4(bool isLight, Color cardBg, Color borderColor, Color textPri, Color textSec) {
    return _sectionCard(
      title: 'Step 4: Clothing, Footwear & Personal Effects',
      subtitle: 'Fabrics, brands, recovered accessories, and pocket items used for public recognition.',
      icon: Icons.checkroom_outlined,
      children: [
        TextFormField(
          controller: _clothingController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Clothing & Footwear Description *',
            hintText: 'Upper garment, lower garment, color, brand label, shoe type and size...',
          ),
          validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _belongingsController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Jewellery, Valuables & Belongings',
            hintText: 'Amulets, watches, rings, lockets, key rings, coins, recovered tokens...',
          ),
        ),
      ],
    );
  }

  // Step 5: Biometrics, Documents & Photos
  Widget _buildStep5(bool isLight, Color cardBg, Color borderColor, Color textPri, Color textSec) {
    return Column(
      children: [
        _sectionCard(
          title: 'Step 5: Biometrics, Forensic Laboratory & Narrative Summary',
          subtitle: 'AFIS Fingerprint status, DNA sample archiving, mortuary autopsy reference, and photos.',
          icon: Icons.biotech_outlined,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _fingerprint,
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
                    value: _dna,
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
            const SizedBox(height: 20),

            // Attached Photos Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Attached Forensic Photos (${_photos.length}):',
                  style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _importPhotoDirect,
                      icon: const Icon(Icons.file_upload_outlined, size: 15),
                      label: const Text('Import from Desktop / Gallery', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: _addPhotoDialog,
                      icon: const Icon(Icons.link, size: 15),
                      label: const Text('Add via URL', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _photos.map((photo) {
                return Container(
                  width: 200,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isLight ? AppColors.slate100 : AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          photo.previewUrl,
                          height: 110,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            height: 110,
                            color: Colors.grey.shade300,
                            child: const Center(child: Icon(Icons.broken_image)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        photo.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                      Text(
                        'Category: ${photo.category.toUpperCase()}',
                        style: TextStyle(color: textSec, fontSize: 10),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Review Summary Card before final save
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isLight ? const Color(0xFFEFF6FF) : const Color(0xFF1E3A8A).withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF93C5FD)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.fact_check_rounded, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Pre-Registration Verification Summary',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _summaryItem('Case Reference', _referenceController.text, textPri, textSec)),
                  Expanded(child: _summaryItem('GD Reference', _gdController.text, textPri, textSec)),
                  Expanded(child: _summaryItem('Demographics', '$_gender, ${_ageController.text} yrs, ${_heightController.text}cm', textPri, textSec)),
                  Expanded(child: _summaryItem('Location', '${_thanaController.text}, ${_districtController.text}', textPri, textSec)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryItem(String label, String value, Color textPri, Color textSec) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: textSec, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(
          value.isEmpty ? '—' : value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: textPri, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _sectionCard({
    required String title,
    String? subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cardBg = isLight ? Colors.white : AppColors.darkCardBg;
    final borderColor = isLight ? AppColors.lightBorder : AppColors.darkBorder;
    final textPri = isLight ? AppColors.lightTextPrimary : AppColors.darkTextPrimary;
    final textSec = isLight ? AppColors.lightTextSecondary : AppColors.darkTextSecondary;

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
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle, style: TextStyle(color: textSec, fontSize: 12)),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}
