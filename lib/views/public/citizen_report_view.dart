import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive.dart';
import '../../models/citizen_report.dart';
import '../../providers/request_provider.dart';

class CitizenReportView extends StatefulWidget {
  final VoidCallback onCancel;

  const CitizenReportView({super.key, required this.onCancel});

  @override
  State<CitizenReportView> createState() => _CitizenReportViewState();
}

class _CitizenReportViewState extends State<CitizenReportView> {
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

  String? _generatedReportCode;
  bool _submitted = false;

  @override
  void dispose() {
    _districtController.dispose();
    _thanaController.dispose();
    _spotLocationController.dispose();
    _descriptionController.dispose();
    _conditionController.dispose();
    _reporterNameController.dispose();
    _reporterPhoneController.dispose();
    _reporterNidController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final code =
          'CIT-REP-2026-${(1000 + DateTime.now().millisecond).toString()}';
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
    final textPri = isLight
        ? AppColors.lightTextPrimary
        : AppColors.darkTextPrimary;
    final textSec = isLight
        ? AppColors.lightTextSecondary
        : AppColors.darkTextSecondary;

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
              : _buildFormCard(
                  isDesktop,
                  isLight,
                  cardBg,
                  borderColor,
                  textPri,
                  textSec,
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

          const SizedBox(height: 24),

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
}
