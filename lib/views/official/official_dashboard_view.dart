import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../models/udb_record.dart';
import '../../models/citizen_report.dart';
import '../../models/citizen_tip.dart';
import '../../providers/auth_provider.dart';
import '../../providers/udb_provider.dart';
import '../../providers/request_provider.dart';
import 'case_registration_view.dart';
import 'io_requests_manager_view.dart';
import '../widgets/contact_action_pill.dart';

class OfficialDashboardView extends StatefulWidget {
  final ValueChanged<UdbRecord> onSelectRecord;

  const OfficialDashboardView({super.key, required this.onSelectRecord});

  @override
  State<OfficialDashboardView> createState() => _OfficialDashboardViewState();
}

class _OfficialDashboardViewState extends State<OfficialDashboardView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _caseSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final udb = context.watch<UdbProvider>();
    final reqs = context.watch<RequestProvider>();
    final isDesktop = Responsive.isDesktop(context);

    final isLight = Theme.of(context).brightness == Brightness.light;
    final cardBg = isLight ? Colors.white : AppColors.darkCardBg;
    final borderColor = isLight ? AppColors.lightBorder : AppColors.darkBorder;
    final textPri = isLight ? AppColors.lightTextPrimary : AppColors.darkTextPrimary;
    final textSec = isLight ? AppColors.lightTextSecondary : AppColors.darkTextSecondary;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 48 : 16,
        vertical: 24,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Officer Identity Bar
              Container(
                padding: const EdgeInsets.all(20),
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
                      child: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                auth.session.fullName,
                                style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                                ),
                                child: Text(
                                  auth.session.bpNumber,
                                  style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${auth.session.rank} • ${auth.session.unitThana}',
                            style: TextStyle(color: textSec, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _tabController.animateTo(1),
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('New Case Intake'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Navigation Tabs - Modern Segmented Control
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isLight ? AppColors.slate100 : AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: !isDesktop,
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
                  tabs: [
                    Tab(text: 'All Dead Body Cases (${udb.totalRecords})'),
                    const Tab(text: 'Case Intake Wizard'),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('IO Access Requests'),
                          if (reqs.pendingRequestsCount > 0) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: const BoxDecoration(
                                color: AppColors.gold,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${reqs.pendingRequestsCount}',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Citizen Reports'),
                          if (reqs.pendingCitizenReportsCount > 0) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: const BoxDecoration(
                                color: AppColors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${reqs.pendingCitizenReportsCount}',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Tab(text: 'Match Leads / Tips (${reqs.citizenTips.length})'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Tab View Content
              SizedBox(
                height: 920,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 0: Case Records Table / Cards
                    _buildCaseManagementTab(udb, isLight, cardBg, borderColor, textPri, textSec),
                    // Tab 1: New Case Intake Wizard
                    CaseRegistrationView(onSuccess: () => _tabController.animateTo(0)),
                    // Tab 2: IO Requests Manager
                    const IoRequestsManagerView(),
                    // Tab 3: Citizen Reports
                    _buildCitizenReportsTab(reqs, isLight, cardBg, borderColor, textPri, textSec),
                    // Tab 4: Citizen Tips
                    _buildCitizenTipsTab(udb, reqs, isLight, cardBg, borderColor, textPri, textSec),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCaseManagementTab(
    UdbProvider udb,
    bool isLight,
    Color cardBg,
    Color borderColor,
    Color textPri,
    Color textSec,
  ) {
    final allRecords = udb.allRecords;
    final records = _caseSearchQuery.trim().isEmpty
        ? allRecords
        : allRecords.where((r) {
            final q = _caseSearchQuery.trim().toLowerCase();
            return r.referenceNo.toLowerCase().contains(q) ||
                r.gdCaseReference.toLowerCase().contains(q) ||
                r.thana.toLowerCase().contains(q) ||
                r.district.toLowerCase().contains(q) ||
                r.placeFound.toLowerCase().contains(q);
          }).toList();

    return Column(
      children: [
        // Search Filter Bar
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, size: 20, color: AppColors.slate400),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Quick filter by Reference (e.g. CIB-UDB-2026-001), GD No, Thana, District...',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onChanged: (val) => setState(() => _caseSearchQuery = val),
                ),
              ),
              if (_caseSearchQuery.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear, size: 16),
                  onPressed: () => setState(() => _caseSearchQuery = ''),
                ),
              Text(
                'Showing ${records.length} of ${allRecords.length} records',
                style: TextStyle(color: textSec, fontSize: 12),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.separated(
            itemCount: records.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final r = records[index];
              final isActive = r.status.toUpperCase().contains('ACTIVE') || r.status.toUpperCase().contains('GAZETTE');

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                  boxShadow: isLight
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          r.gender.isNotEmpty ? r.gender[0] : 'U',
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                r.referenceNo,
                                style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isActive ? AppColors.greenLight : AppColors.goldLight,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: isActive ? AppColors.greenBorder : AppColors.goldBorder),
                                ),
                                child: Text(
                                  r.status,
                                  style: TextStyle(
                                    color: isActive ? AppColors.green : AppColors.gold,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (r.hasFingerprint)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  margin: const EdgeInsets.only(right: 4),
                                  decoration: BoxDecoration(
                                    color: isLight ? AppColors.slate100 : AppColors.darkSurface,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: isLight ? AppColors.slate300 : AppColors.darkBorder),
                                  ),
                                  child: const Text('AFIS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                ),
                              if (r.hasDna)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.purpleLight,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: AppColors.purpleBorder),
                                  ),
                                  child: const Text('DNA', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.purple)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${r.gender}, ~${r.estimatedAge} yrs • ${r.thana}, ${r.district} • GD: ${r.gdCaseReference} • PM Ref: ${r.postmortemReference}',
                            style: TextStyle(color: textSec, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => widget.onSelectRecord(r),
                      icon: const Icon(Icons.folder_open_rounded, size: 15),
                      label: const Text('Open Dossier', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        side: BorderSide(color: isLight ? AppColors.slate300 : AppColors.darkBorder),
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCitizenReportsTab(
    RequestProvider reqs,
    bool isLight,
    Color cardBg,
    Color borderColor,
    Color textPri,
    Color textSec,
  ) {
    final reports = reqs.citizenReports;
    if (reports.isEmpty) {
      return Center(child: Text('No citizen emergency reports filed.', style: TextStyle(color: textSec)));
    }

    return ListView.separated(
      itemCount: reports.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final rep = reports[index];
        final isPending = rep.status.toUpperCase().contains('PENDING');

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isPending ? AppColors.redBorder : borderColor, width: isPending ? 1.5 : 1),
            boxShadow: isLight
                ? [
                    BoxShadow(
                      color: (isPending ? AppColors.red : Colors.black).withValues(alpha: 0.03),
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.redLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          rep.reportReference,
                          style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Reported by: ${rep.reporterName}',
                        style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(width: 8),
                      ContactActionPill.phone(
                        label: rep.reporterPhone,
                        target: rep.reporterPhone,
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isPending ? AppColors.redLight : AppColors.greenLight,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: isPending ? AppColors.redBorder : AppColors.greenBorder),
                    ),
                    child: Text(
                      rep.status,
                      style: TextStyle(
                        color: isPending ? AppColors.red : AppColors.green,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isLight ? AppColors.slate50 : AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.place_outlined, size: 16, color: AppColors.red),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Spot: ${rep.spotLocation}, ${rep.thana}, ${rep.district} • Spotted on: ${rep.dateSpotted} (${rep.timeSpotted})',
                        style: TextStyle(color: textPri, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Incident Details: ${rep.description}',
                style: TextStyle(color: textSec, fontSize: 12, height: 1.4),
              ),
              const SizedBox(height: 14),

              // Action buttons for officer
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      reqs.updateCitizenReportStatus(rep.id, 'DISPATCHED_TO_THANA');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Report ${rep.reportReference} dispatched to ${rep.thana} Model Thana.'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    icon: const Icon(Icons.send_rounded, size: 14),
                    label: const Text('Dispatch Thana Patrol', style: TextStyle(fontSize: 11)),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      reqs.updateCitizenReportStatus(rep.id, 'UNDER_INQUEST');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Report ${rep.reportReference} marked: Police Inquest Initiated (CrPC 174).'),
                          backgroundColor: AppColors.gold,
                        ),
                      );
                    },
                    icon: const Icon(Icons.gavel_rounded, size: 14),
                    label: const Text('Mark Under Inquest', style: TextStyle(fontSize: 11)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      reqs.updateCitizenReportStatus(rep.id, 'CONVERTED_TO_DOSSIER');
                      _tabController.animateTo(1);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Report ${rep.reportReference} opened in Case Intake Wizard!'),
                          backgroundColor: AppColors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.folder_open_rounded, size: 14),
                    label: const Text('Convert to Dossier', style: TextStyle(fontSize: 11)),
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
      },
    );
  }

  Widget _buildCitizenTipsTab(
    UdbProvider udb,
    RequestProvider reqs,
    bool isLight,
    Color cardBg,
    Color borderColor,
    Color textPri,
    Color textSec,
  ) {
    final tips = reqs.citizenTips;
    if (tips.isEmpty) {
      return Center(child: Text('No relative match claims or tips submitted yet.', style: TextStyle(color: textSec)));
    }

    return ListView.separated(
      itemCount: tips.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final tip = tips[index];

        Color statusColor = AppColors.gold;
        Color statusBg = AppColors.goldLight;
        if (tip.status == 'VERIFIED_MATCH') {
          statusColor = AppColors.green;
          statusBg = AppColors.greenLight;
        } else if (tip.status == 'UNDER_INVESTIGATION') {
          statusColor = AppColors.primary;
          statusBg = AppColors.primaryLight;
        } else if (tip.status == 'DISMISSED') {
          statusColor = AppColors.slate500;
          statusBg = AppColors.slate100;
        }

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
            boxShadow: isLight
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Target: ${tip.bodyReference}',
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Claimant: ${tip.claimantName} (${tip.relationshipToMissing})',
                        style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tip.status,
                      style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isLight ? AppColors.slate50 : AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Missing Person: ${tip.missingPersonName} • GD No: ${tip.missingPersonGd} (${tip.thanaFiled})',
                        style: TextStyle(color: textPri, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                    ContactActionPill.phone(
                      label: 'Call: ${tip.claimantPhone}',
                      target: tip.claimantPhone,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Claimant Similarity Statement: "${tip.similarityReasons}"',
                style: TextStyle(color: textSec, fontSize: 12, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 14),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      reqs.updateTipStatus(tip.id, 'DISMISSED');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Lead dismissed.')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.slate600,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: const Text('Dismiss', style: TextStyle(fontSize: 11)),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      reqs.updateTipStatus(tip.id, 'UNDER_INVESTIGATION');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Lead for ${tip.bodyReference} marked: Under Active Investigation.'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    icon: const Icon(Icons.saved_search_rounded, size: 14),
                    label: const Text('Investigate Lead', style: TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      reqs.updateTipStatus(tip.id, 'VERIFIED_MATCH');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Lead marked: VERIFIED MATCH! DNA Requisition dispatched.'),
                          backgroundColor: AppColors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_circle_rounded, size: 14),
                    label: const Text('Verify Match', style: TextStyle(fontSize: 11)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      final rec = udb.findRecord(tip.bodyReference);
                      if (rec != null) {
                        widget.onSelectRecord(rec);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Case record ${tip.bodyReference} not found.')),
                        );
                      }
                    },
                    icon: const Icon(Icons.open_in_new_rounded, size: 14),
                    label: const Text('Open Dossier', style: TextStyle(fontSize: 11)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
