import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/file_import_service.dart';
import '../../models/citizen_report.dart';
import '../../providers/request_provider.dart';

class CitizenReportView extends StatefulWidget {
  final VoidCallback onCancel;

  const CitizenReportView({super.key, required this.onCancel});

  @override
  State<CitizenReportView> createState() => _CitizenReportViewState();
}

class _CitizenReportViewState extends State<CitizenReportView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  String? _division = 'Dhaka';
  final _districtController = TextEditingController(text: 'Dhaka');
  final _thanaController = TextEditingController();
  final _spotLocationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _conditionController = TextEditingController();
  final _reporterNameController = TextEditingController();
  final _reporterPhoneController = TextEditingController();
  final _reporterNidController = TextEditingController();

  final _trackCodeController = TextEditingController(text: 'CIT-REP-2026-0042');
  CitizenReport? _searchedReport;
  bool _searchExecuted = false;
  bool _hasPhotoAttached = false;
  final List<PickedImageFile> _attachedPhotos = [];

  Future<void> _handlePickPhoto() async {
    final picked = await pickImageFromDevice();
    if (picked != null) {
      setState(() {
        _attachedPhotos.add(picked);
        _hasPhotoAttached = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Attached photo: ${picked.name} (${picked.humanSize})'),
            backgroundColor: AppColors.green,
          ),
        );
      }
    }
  }

  String? _generatedReportCode;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _districtController.dispose();
    _thanaController.dispose();
    _spotLocationController.dispose();
    _descriptionController.dispose();
    _conditionController.dispose();
    _reporterNameController.dispose();
    _reporterPhoneController.dispose();
    _reporterNidController.dispose();
    _trackCodeController.dispose();
    super.dispose();
  }

  void _searchReportStatus() {
    final code = _trackCodeController.text.trim();
    if (code.isEmpty) return;

    final found = context.read<RequestProvider>().findCitizenReport(code);
    setState(() {
      _searchedReport = found;
      _searchExecuted = true;
    });
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final code = 'CIT-REP-2026-${(1000 + DateTime.now().millisecond).toString()}';
      final report = CitizenReport(
        id: 'cit_${DateTime.now().millisecondsSinceEpoch}',
        reportReference: code,
        reporterName: _reporterNameController.text.trim(),
        reporterPhone: _reporterPhoneController.text.trim(),
        reporterNid: _reporterNidController.text.trim().isNotEmpty
            ? _reporterNidController.text.trim()
            : null,
        division: _division ?? 'Dhaka',
        district: _districtController.text.trim(),
        thana: _thanaController.text.trim(),
        spotLocation: _spotLocationController.text.trim(),
        dateSpotted: DateTime.now().toString().split(' ')[0],
        timeSpotted: 'Current',
        description: _descriptionController.text.trim(),
        conditionDescription: _conditionController.text.trim(),
        photoUrls: _hasPhotoAttached
            ? ['https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=600&q=80']
            : const [],
        status: 'PENDING_POLICE_DISPATCH',
        submittedAt: 'Just now',
      );

      context.read<RequestProvider>().submitCitizenReport(report);
      setState(() {
        _generatedReportCode = code;
        _submitted = true;
      });
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
          constraints: const BoxConstraints(maxWidth: 860),
          child: _submitted
              ? _buildSuccessCard(isLight, cardBg, textPri, textSec)
              : Column(
                  children: [
                    // Top Segmented Switcher (New Report vs Track Status)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isLight ? AppColors.slate100 : AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: isLight ? Colors.white : AppColors.darkCardBg,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: isLight
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  )
                                ]
                              : null,
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: textSec,
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        tabs: const [
                          Tab(text: '1. Report Found Human Remains (Emergency)'),
                          Tab(text: '2. Track Submitted Report Status'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Tab View
                    AnimatedBuilder(
                      animation: _tabController,
                      builder: (context, _) {
                        if (_tabController.index == 0) {
                          return _buildFormCard(
                            isDesktop,
                            isLight,
                            cardBg,
                            borderColor,
                            textPri,
                            textSec,
                          );
                        } else {
                          return _buildTrackingCard(
                            isLight,
                            cardBg,
                            borderColor,
                            textPri,
                            textSec,
                          );
                        }
                      },
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildFormCard(
    bool isDesktop,
    bool isLight,
    Color cardBg,
    Color borderColor,
    Color textPri,
    Color textSec,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(24),
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
                      ),
                    ]
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emergency_outlined,
                    color: AppColors.red,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Report an Unidentified Deceased Individual (Emergency Public Intake)',
                        style: TextStyle(
                          color: textPri,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'If you have spotted an unidentified dead body or human remains anywhere in Bangladesh, report it immediately. '
                        'This information triggers an urgent dispatch alert to the local Police Station (Thana) and CID Forensic Crime Scene Team.',
                        style: TextStyle(
                          color: textSec,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.redDark.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: AppColors.red.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Text(
                          'For immediate life-threatening emergencies, dial 999 directly.',
                          style: TextStyle(
                            color: AppColors.red,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Emergency 999 Hotline Alert Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.redLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.redBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.phone_in_talk, color: AppColors.red, size: 22),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Direct Police Emergency Helpline: Dial 999',
                        style: TextStyle(color: AppColors.redDark, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'For live emergencies or immediately witnessed human remains, call 999 or CID Control (+880 2 48312000).',
                        style: TextStyle(color: AppColors.redDark, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('DIAL 999', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Location Section
          _sectionCard(
            title: '1. Incident Recovery Location',
            icon: Icons.location_on_outlined,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _division,
                      decoration: const InputDecoration(
                        labelText: 'Division *',
                      ),
                      dropdownColor: AppColors.cardBg,
                      items: AppConstants.divisions
                          .map(
                            (d) => DropdownMenuItem(value: d, child: Text(d)),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => _division = val),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _districtController,
                      decoration: const InputDecoration(
                        labelText: 'District *',
                      ),
                      validator: (v) =>
                          v?.trim().isEmpty == true ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _thanaController,
                decoration: const InputDecoration(
                  labelText: 'Police Station / Thana *',
                  hintText: 'e.g. Ramna, Kotwali, Sonadanga, Tongi',
                ),
                validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _spotLocationController,
                decoration: const InputDecoration(
                  labelText: 'Exact Spot / Landmark / Coordinates *',
                  hintText: 'e.g. Under Turag river bridge pillar #3, near road divider, tea garden corner',
                ),
                validator: (v) => v?.trim().isEmpty == true
                    ? 'Please describe the exact location'
                    : null,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Physical Description
          _sectionCard(
            title: '2. Physical Condition & Circumstances',
            icon: Icons.description_outlined,
            children: [
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description of the Deceased & Clothing *',
                  hintText: 'Apparent gender, approximate age, clothing color, shoes, visible marks...',
                ),
                validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _conditionController,
                decoration: const InputDecoration(
                  labelText: 'Body Condition (if noticeable)',
                  hintText: 'e.g. In water, recently deceased, decomposed, charred, skeletal...',
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Informant Details
          _sectionCard(
            title: '3. Informant / Reporter Particulars',
            icon: Icons.person_outline,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _reporterNameController,
                      decoration: const InputDecoration(
                        labelText: 'Your Name *',
                      ),
                      validator: (v) =>
                          v?.trim().isEmpty == true ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _reporterPhoneController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Mobile Number *',
                      ),
                      validator: (v) =>
                          v?.trim().isEmpty == true ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reporterNidController,
                decoration: const InputDecoration(
                  labelText: 'National ID Number (Optional)',
                  hintText:
                      'Your NID card number for verified police reporting',
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Photo Attachment
          _sectionCard(
            title: '4. Crime Scene / Location Photos (Optional)',
            icon: Icons.camera_alt_outlined,
            children: [
              Text(
                'Attach photos of the scene, surrounding landmarks, or clothing directly from your computer or phone gallery. Do not post graphic photos to social media.',
                style: TextStyle(color: textSec, fontSize: 12),
              ),
              const SizedBox(height: 14),
              if (_attachedPhotos.isNotEmpty) ...[
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _attachedPhotos.map((photo) {
                    return Container(
                      width: 220,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isLight ? AppColors.slate100 : AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              photo.dataUrl,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                height: 120,
                                color: Colors.grey.shade300,
                                child: const Center(child: Icon(Icons.broken_image)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            photo.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                          Text(
                            photo.humanSize,
                            style: TextStyle(color: textSec, fontSize: 10),
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _attachedPhotos.remove(photo);
                                  _hasPhotoAttached = _attachedPhotos.isNotEmpty;
                                });
                              },
                              child: const Text('Remove', style: TextStyle(color: AppColors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],
              OutlinedButton.icon(
                onPressed: _handlePickPhoto,
                icon: const Icon(Icons.file_upload_outlined, size: 16),
                label: Text(
                  _attachedPhotos.isEmpty ? 'Import Photo from Device / Gallery' : 'Import Another Photo',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: widget.onCancel,
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.send, size: 16),
                label: const Text('Dispatch Emergency Report to CID'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cardBg = isLight ? Colors.white : AppColors.darkCardBg;
    final borderColor = isLight ? AppColors.lightBorder : AppColors.darkBorder;
    final textPri = isLight
        ? AppColors.lightTextPrimary
        : AppColors.darkTextPrimary;

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
                ),
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
                style: TextStyle(
                  color: textPri,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSuccessCard(
    bool isLight,
    Color cardBg,
    Color textPri,
    Color textSec,
  ) {
    return Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greenBorder, width: 1.5),
        boxShadow: isLight
            ? [
                BoxShadow(
                  color: AppColors.green.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              color: AppColors.greenLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.green,
              size: 54,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Emergency Report Dispatched Successfully',
            style: TextStyle(
              color: textPri,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.goldLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.goldBorder),
            ),
            child: Text(
              'Reference Tracking Code: $_generatedReportCode',
              style: const TextStyle(
                color: AppColors.gold,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'The recovery dispatch alert has been routed to CID Headquarters Central Intelligence Bureau '
            'and the relevant Police Station at ${_thanaController.text.trim()}, ${_districtController.text.trim()}.\n'
            'An investigating officer may call ${_reporterPhoneController.text.trim()} to guide the response team to the spot.',
            textAlign: TextAlign.center,
            style: TextStyle(color: textSec, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: widget.onCancel,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            ),
            child: const Text('Back to Main Portal'),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingCard(
    bool isLight,
    Color cardBg,
    Color borderColor,
    Color textPri,
    Color textSec,
  ) {
    return Container(
      padding: const EdgeInsets.all(28),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.track_changes, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Citizen Report Tracking Portal',
                      style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Enter your emergency tracking code (e.g. CIT-REP-2026-0042) to check police dispatch status.',
                      style: TextStyle(color: textSec, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Search Field
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _trackCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Report Tracking Reference *',
                    hintText: 'e.g. CIT-REP-2026-0042',
                    prefixIcon: Icon(Icons.search, size: 18),
                  ),
                  onSubmitted: (_) => _searchReportStatus(),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _searchReportStatus,
                icon: const Icon(Icons.search, size: 16),
                label: const Text('Track Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Results Area
          if (_searchedReport != null) ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isLight ? AppColors.slate50 : AppColors.darkSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isLight ? AppColors.slate200 : AppColors.darkBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Report Ref: ${_searchedReport!.reportReference}',
                        style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.greenLight,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.greenBorder),
                        ),
                        child: Text(
                          _searchedReport!.status.replaceAll('_', ' '),
                          style: const TextStyle(color: AppColors.greenDark, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  _trackRow('Recovery Location', '${_searchedReport!.spotLocation}, ${_searchedReport!.thana}, ${_searchedReport!.district}', textSec, textPri),
                  _trackRow('Reported Date & Time', '${_searchedReport!.dateSpotted} (${_searchedReport!.timeSpotted})', textSec, textPri),
                  _trackRow('Deceased Description', _searchedReport!.description, textSec, textPri),
                  _trackRow('Condition Observed', _searchedReport!.conditionDescription, textSec, textPri),
                  _trackRow('Jurisdictional Police Station', '${_searchedReport!.thana} PS, ${_searchedReport!.district} District', textSec, textPri),

                  const SizedBox(height: 18),

                  // 4-Step Police Status Pipeline
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isLight ? Colors.white : AppColors.darkCardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isLight ? AppColors.slate200 : AppColors.darkBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Police Dispatch & Investigation Progress',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                        ),
                        const SizedBox(height: 12),
                        _stepRow(1, 'Report Logged at CID Central Intelligence Bureau', 'Logged successfully into national dispatch queue.', true, isLight),
                        _stepLine(true),
                        _stepRow(2, 'Urgent Dispatch Alert Sent to ${_searchedReport!.thana} Thana', 'Duty Officer acknowledged receipt.', true, isLight),
                        _stepLine(true),
                        _stepRow(3, 'Investigation Officer & Crime Scene Unit Dispatched', 'Field unit en route to spot.', true, isLight),
                        _stepLine(false),
                        _stepRow(4, 'Formal CrPC 174 Police Inquest & Hospital Mortuary Intake', 'Surat-hal report pending submission.', false, isLight),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else if (_searchExecuted) ...[
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isLight ? AppColors.slate50 : AppColors.darkSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isLight ? AppColors.slate200 : AppColors.darkBorder),
              ),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, size: 42, color: AppColors.red),
                    const SizedBox(height: 12),
                    Text(
                      'Report Reference Not Found',
                      style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Please verify the tracking code from your submission receipt (e.g. CIT-REP-2026-0042).',
                      style: TextStyle(color: textSec, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _trackRow(String label, String value, Color textSec, Color textPri) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 170,
            child: Text(label, style: TextStyle(color: textSec, fontSize: 11.5, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(value.isNotEmpty ? value : 'Not specified', style: TextStyle(color: textPri, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _stepRow(int step, String title, String desc, bool isDone, bool isLight) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 10,
          backgroundColor: isDone ? AppColors.green : (isLight ? AppColors.slate200 : AppColors.darkBorder),
          child: Icon(isDone ? Icons.check : Icons.circle, size: 10, color: isDone ? Colors.white : AppColors.slate400),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: isDone ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                  color: isDone ? (isLight ? AppColors.slate900 : Colors.white) : AppColors.slate400,
                ),
              ),
              Text(desc, style: TextStyle(color: AppColors.slate500, fontSize: 10.5)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepLine(bool isDone) {
    return Container(
      width: 2,
      height: 16,
      margin: const EdgeInsets.only(left: 9),
      color: isDone ? AppColors.green : AppColors.slate300,
    );
  }
}
