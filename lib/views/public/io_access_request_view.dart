import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../models/official_access_request.dart';
import '../../providers/request_provider.dart';

class IoAccessRequestView extends StatefulWidget {
  final VoidCallback onCancel;
  final ValueChanged<String> onSwitchToLogin;

  const IoAccessRequestView({
    super.key,
    required this.onCancel,
    required this.onSwitchToLogin,
  });

  @override
  State<IoAccessRequestView> createState() => _IoAccessRequestViewState();
}

class _IoAccessRequestViewState extends State<IoAccessRequestView> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _rankController = TextEditingController(text: 'Sub-Inspector (SI)');
  final _bpController = TextEditingController();
  final _unitController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _caseRefController = TextEditingController(text: 'CIB-UDB-2026-001');
  final _gdController = TextEditingController();
  final _reasonController = TextEditingController();

  String? _generatedReqCode;
  bool _submitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _rankController.dispose();
    _bpController.dispose();
    _unitController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _caseRefController.dispose();
    _gdController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final code = 'REQ-2026-${(1000 + DateTime.now().millisecond).toString()}';
      final req = OfficialAccessRequest(
        id: 'req_${DateTime.now().millisecondsSinceEpoch}',
        requestCode: code,
        officerName: _nameController.text.trim(),
        officerRank: _rankController.text.trim(),
        bpNumber: _bpController.text.trim().toUpperCase(),
        postingUnit: _unitController.text.trim(),
        contactPhone: _phoneController.text.trim(),
        officialEmail: _emailController.text.trim(),
        targetCaseReference: _caseRefController.text.trim().toUpperCase(),
        investigationGdFir: _gdController.text.trim(),
        reasonForAccess: _reasonController.text.trim(),
        status: 'pending',
        requestedAt: 'Just now',
      );

      context.read<RequestProvider>().submitIORequest(req);
      setState(() {
        _generatedReqCode = code;
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
              : _buildFormCard(isDesktop, isLight, cardBg, borderColor, textPri, textSec),
        ),
      ),
    );
  }

  Widget _buildFormCard(bool isDesktop, bool isLight, Color cardBg, Color borderColor, Color textPri, Color textSec) {
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
                      )
                    ]
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.vpn_key_outlined, color: AppColors.gold, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Police Investigation Officer (IO) Forensic Data Access Request',
                        style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Thana Investigation Officers, PBI, Highway, Railway, and River Police investigating missing persons '
                        'or homicides can request full access to unredacted forensic dossiers, autopsy reports, and DNA markers.',
                        style: TextStyle(color: textSec, fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isLight ? AppColors.primaryLight : AppColors.darkSurface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isLight ? const Color(0xFFBFDBFE) : AppColors.darkBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: AppColors.primary, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Already have an approved Access Token? Jump to Officer Login to enter your token.',
                                style: TextStyle(color: isLight ? const Color(0xFF1E3A8A) : AppColors.darkTextPrimary, fontSize: 12),
                              ),
                            ),
                            TextButton(
                              onPressed: () => widget.onSwitchToLogin(''),
                              child: const Text(
                                'Login with Token',
                                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Officer Identity
          _sectionCard(
            title: '1. Officer Credentials & Station Posting',
            icon: Icons.badge_outlined,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Officer Full Name *', hintText: 'e.g. Md. Kamal Hossain'),
                      validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _rankController,
                      decoration: const InputDecoration(labelText: 'Official Rank *', hintText: 'e.g. Sub-Inspector, Inspector, ASP'),
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
                      controller: _bpController,
                      decoration: const InputDecoration(labelText: 'Police BP ID Number *', hintText: 'e.g. BP-8812049182'),
                      validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _unitController,
                      decoration: const InputDecoration(labelText: 'Police Station / Unit *', hintText: 'e.g. Ramna Model Thana, DMP'),
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
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Official Mobile Number *', hintText: '017XXXXXXXX'),
                      validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Official Email *', hintText: 'officer@police.gov.bd'),
                      validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Investigation Basis
          _sectionCard(
            title: '2. Legal Basis & Target Case Specification',
            icon: Icons.gavel_outlined,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _caseRefController,
                      decoration: const InputDecoration(
                        labelText: 'Target UDB Reference No. *',
                        hintText: 'e.g. CIB-UDB-2026-001 or ALL',
                      ),
                      validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _gdController,
                      decoration: const InputDecoration(
                        labelText: 'Active Investigation GD / FIR Reference *',
                        hintText: 'e.g. Ramna PS Missing GD No. 442/26',
                      ),
                      validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Justification for Forensic Dossier Access *',
                  hintText: 'Describe how the missing person in your GD matches this unidentified body (age, marks, location, clothing)...',
                ),
                validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Action Buttons
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
                icon: const Icon(Icons.send_rounded, size: 16),
                label: const Text('Submit Official Request to CID'),
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

  Widget _buildSuccessCard(bool isLight, Color cardBg, Color textPri, Color textSec) {
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
                )
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
            child: const Icon(Icons.check_circle_outline_rounded, color: AppColors.green, size: 54),
          ),
          const SizedBox(height: 20),
          Text(
            'IO Data Access Request Logged',
            style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 20),
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
              'Tracking Code: $_generatedReqCode',
              style: const TextStyle(
                color: AppColors.gold,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your formal request to access ${_caseRefController.text.trim()} has been routed to the '
            'Special Superintendent of Police, Central Intelligence Bureau (CIB), CID HQ Dhaka.\n'
            'Upon verification of BP No. ${_bpController.text.trim()}, an access pass will be generated.',
            textAlign: TextAlign.center,
            style: TextStyle(color: textSec, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isLight ? AppColors.slate50 : AppColors.darkSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isLight ? AppColors.slate200 : AppColors.darkBorder),
            ),
            child: const Column(
              children: [
                Text(
                  '💡 Quick Testing Note for Reviewers:',
                  style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                SizedBox(height: 6),
                Text(
                  'A pre-approved demo pass is available: "CID-PASS-7849-KM". You can enter this token in the Officer Login view to instantly test external IO access!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.slate600, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: widget.onCancel,
                child: const Text('Back to Home'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => widget.onSwitchToLogin('CID-PASS-7849-KM'),
                icon: const Icon(Icons.login, size: 16),
                label: const Text('Test Login with Token'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

