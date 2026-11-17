import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
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
  int _selectedTab = 0; // 0: Submit Request, 1: Track / Retrieve Token

  // Form State
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

  // Track State
  final _lookupController = TextEditingController();
  OfficialAccessRequest? _foundRequest;
  bool _hasSearched = false;

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
    _lookupController.dispose();
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

  void _searchRequest([String? directCode]) {
    final query = (directCode ?? _lookupController.text).trim();
    if (query.isEmpty) return;

    if (directCode != null) {
      _lookupController.text = directCode;
    }

    final req = context.read<RequestProvider>().findAccessRequest(query);
    setState(() {
      _foundRequest = req;
      _hasSearched = true;
    });
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Segmented Switcher
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isLight ? AppColors.slate100 : AppColors.darkCardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTabButton(
                        index: 0,
                        icon: Icons.assignment_outlined,
                        label: '1. Submit Official IO Access Request',
                        isSelected: _selectedTab == 0,
                        isLight: isLight,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTabButton(
                        index: 1,
                        icon: Icons.verified_user_outlined,
                        label: '2. Track Request Status & Retrieve Pass',
                        isSelected: _selectedTab == 1,
                        isLight: isLight,
                      ),
                    ),
                  ],
                ),
              ),

              if (_selectedTab == 0) ...[
                if (_submitted)
                  _buildSuccessCard(isLight, cardBg, textPri, textSec)
                else
                  _buildFormCard(isDesktop, isLight, cardBg, borderColor, textPri, textSec),
              ] else ...[
                _buildTrackingView(isLight, cardBg, borderColor, textPri, textSec),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
    required bool isLight,
  }) {
    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? (isLight ? Colors.white : AppColors.primary)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected && isLight
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? (isLight ? AppColors.primary : Colors.white)
                  : (isLight ? AppColors.slate600 : AppColors.darkTextSecondary),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected
                      ? (isLight ? AppColors.primary : Colors.white)
                      : (isLight ? AppColors.slate600 : AppColors.darkTextSecondary),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          ],
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
                                'Already submitted? Track your request status or retrieve your temporary access pass.',
                                style: TextStyle(color: isLight ? const Color(0xFF1E3A8A) : AppColors.darkTextPrimary, fontSize: 12),
                              ),
                            ),
                            TextButton(
                              onPressed: () => setState(() => _selectedTab = 1),
                              child: const Text(
                                'Track Request',
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

  Widget _buildTrackingView(bool isLight, Color cardBg, Color borderColor, Color textPri, Color textSec) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tracking Input Box
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
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'IO Request Status & Pass Retrieval',
                        style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Enter your CID request reference code (e.g. REQ-2026-0012) to check verification progress.',
                        style: TextStyle(color: textSec, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _lookupController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: 'Enter Request Code (e.g. REQ-2026-0012)',
                        prefixIcon: const Icon(Icons.vpn_key_outlined, size: 20),
                        suffixIcon: _lookupController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _lookupController.clear();
                                  setState(() {
                                    _foundRequest = null;
                                    _hasSearched = false;
                                  });
                                },
                              )
                            : null,
                      ),
                      onSubmitted: (_) => _searchRequest(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _searchRequest(),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                    label: const Text('Track Request'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('Quick Demo Codes:', style: TextStyle(color: textSec, fontSize: 12, fontWeight: FontWeight.bold)),
                  ActionChip(
                    avatar: const Icon(Icons.check_circle, size: 14, color: AppColors.green),
                    label: const Text('REQ-2026-0012 (Approved SI Kamal)'),
                    backgroundColor: isLight ? AppColors.greenLight : AppColors.darkSurface,
                    labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.green),
                    onPressed: () => _searchRequest('REQ-2026-0012'),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.hourglass_empty, size: 14, color: AppColors.gold),
                    label: const Text('REQ-2026-0013 (Pending Insp. Shamsul)'),
                    backgroundColor: isLight ? AppColors.goldLight : AppColors.darkSurface,
                    labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.gold),
                    onPressed: () => _searchRequest('REQ-2026-0013'),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Result Details
        if (_hasSearched) ...[
          if (_foundRequest == null) ...[
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.search_off_rounded, size: 48, color: textSec.withValues(alpha: 0.6)),
                    const SizedBox(height: 12),
                    Text(
                      'No Request Found matching "${_lookupController.text.trim()}"',
                      style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Please verify the tracking code provided upon form submission or contact CID CIB Liaison.',
                      style: TextStyle(color: textSec, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            _buildFoundRequestCard(_foundRequest!, isLight, cardBg, borderColor, textPri, textSec),
          ],
        ],
      ],
    );
  }

  Widget _buildFoundRequestCard(
    OfficialAccessRequest req,
    bool isLight,
    Color cardBg,
    Color borderColor,
    Color textPri,
    Color textSec,
  ) {
    Color statusBg;
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    if (req.isApproved) {
      statusBg = AppColors.greenLight;
      statusColor = AppColors.green;
      statusLabel = 'APPROVED - ACCESS GRANTED';
      statusIcon = Icons.check_circle_rounded;
    } else if (req.isRejected) {
      statusBg = AppColors.redLight;
      statusColor = AppColors.red;
      statusLabel = 'REQUEST DECLINED';
      statusIcon = Icons.cancel_rounded;
    } else {
      statusBg = AppColors.goldLight;
      statusColor = AppColors.gold;
      statusLabel = 'PENDING VERIFICATION';
      statusIcon = Icons.hourglass_top_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: req.isApproved ? AppColors.greenBorder : borderColor, width: req.isApproved ? 1.5 : 1),
        boxShadow: isLight
            ? [
                BoxShadow(
                  color: (req.isApproved ? AppColors.green : Colors.black).withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isLight ? AppColors.slate100 : AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.tag_rounded, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      req.requestCode,
                      style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 6),
                    Text(
                      statusLabel,
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.w800, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'Submitted: ${req.requestedAt}',
                style: TextStyle(color: textSec, fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Officer Particulars
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isLight ? AppColors.slate50 : AppColors.darkSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isLight ? AppColors.slate200 : AppColors.darkBorder),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _infoRow('Applicant IO', '${req.officerName} (${req.officerRank})', textPri, textSec),
                    ),
                    Expanded(
                      child: _infoRow('Police BP Number', req.bpNumber, textPri, textSec, isBold: true),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _infoRow('Posting Unit / Thana', req.postingUnit, textPri, textSec),
                    ),
                    Expanded(
                      child: _infoRow('Official Contact', '${req.contactPhone} | ${req.officialEmail}', textPri, textSec),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _infoRow('Target UDB Reference', req.targetCaseReference, textPri, textSec, isBold: true),
                    ),
                    Expanded(
                      child: _infoRow('Investigation GD / FIR', req.investigationGdFir, textPri, textSec),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Text(
            'Stated Purpose / Case Nexus:',
            style: TextStyle(color: textSec, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            req.reasonForAccess,
            style: TextStyle(color: textPri, fontSize: 13, height: 1.4),
          ),

          const SizedBox(height: 20),

          // Approved Token Card
          if (req.isApproved) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isLight ? const Color(0xFFF0FDF4) : const Color(0xFF064E3B).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.greenBorder, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.vpn_key_rounded, color: AppColors.green, size: 24),
                      const SizedBox(width: 10),
                      Text(
                        'Authorized Forensic Access Token Pass',
                        style: TextStyle(
                          color: isLight ? const Color(0xFF14532D) : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Valid: ${req.tokenExpiresAt ?? '14 Days'}',
                          style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isLight ? Colors.white : AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.greenBorder),
                    ),
                    child: Row(
                      children: [
                        SelectableText(
                          req.accessToken ?? 'CID-PASS-7849-KM',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: 1.2,
                            color: AppColors.primary,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, size: 18, color: AppColors.primary),
                          tooltip: 'Copy Token',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: req.accessToken ?? 'CID-PASS-7849-KM'));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Access Token copied to clipboard!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.verified, size: 16, color: AppColors.green),
                      const SizedBox(width: 6),
                      Text(
                        'Clearance granted by: ${req.reviewedBy ?? 'Superintendent of Police (CIB)'}',
                        style: TextStyle(color: isLight ? const Color(0xFF14532D) : AppColors.darkTextSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  if (req.reviewNotes != null && req.reviewNotes!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Official Reviewer Remark: "${req.reviewNotes}"',
                      style: TextStyle(color: isLight ? const Color(0xFF166534) : AppColors.darkTextSecondary, fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        widget.onSwitchToLogin(req.accessToken ?? 'CID-PASS-7849-KM');
                      },
                      icon: const Icon(Icons.login_rounded, size: 18),
                      label: const Text('Access Authorized Forensic Dossier Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (req.isPending) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isLight ? AppColors.goldLight : AppColors.darkSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.goldBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.pending_actions_rounded, color: AppColors.gold, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Awaiting CIB Clearance Review',
                          style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'The request is currently queued for Superintendent of Police (CIB) review. '
                          'Cross-referencing BP No. ${req.bpNumber} with Police HQ HR records.',
                          style: TextStyle(color: textSec, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isLight ? AppColors.redLight : AppColors.darkSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.redBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.red, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Request Declined by CIB',
                          style: TextStyle(color: AppColors.red, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        if (req.reviewNotes != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Reason: ${req.reviewNotes}',
                            style: TextStyle(color: textSec, fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, Color textPri, Color textSec, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: textSec, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: textPri,
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
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
          if (AppConstants.demoMode)
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
                    'A pre-approved demo pass is available: "CID-PASS-7849-KM". You can enter this token in the Officer Login view or search REQ-2026-0012 to test IO access!',
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
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedTab = 1;
                    _submitted = false;
                  });
                  if (_generatedReqCode != null) {
                    _searchRequest(_generatedReqCode);
                  }
                },
                icon: const Icon(Icons.track_changes_rounded, size: 16),
                label: const Text('Track this Request'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
