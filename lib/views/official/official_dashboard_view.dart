import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../models/udb_record.dart';
import '../../providers/auth_provider.dart';
import '../../providers/udb_provider.dart';
import '../../providers/request_provider.dart';
import 'case_registration_view.dart';
import 'io_requests_manager_view.dart';

class OfficialDashboardView extends StatefulWidget {
  final ValueChanged<UdbRecord> onSelectRecord;

  const OfficialDashboardView({super.key, required this.onSelectRecord});

  @override
  State<OfficialDashboardView> createState() => _OfficialDashboardViewState();
}

class _OfficialDashboardViewState extends State<OfficialDashboardView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
                    Tab(text: 'All Deceased Cases (${udb.totalRecords})'),
                    const Tab(text: 'Case Registration (Intake)'),
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
                height: 850,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 0: Case Records Table / Cards
                    _buildCaseManagementTab(udb, isLight, cardBg, borderColor, textPri, textSec),
                    // Tab 1: New Case Intake Form
                    CaseRegistrationView(onSuccess: () => _tabController.animateTo(0)),
                    // Tab 2: IO Requests Manager
                    const IoRequestsManagerView(),
                    // Tab 3: Citizen Reports
                    _buildCitizenReportsTab(reqs, isLight, cardBg, borderColor, textPri, textSec),
                    // Tab 4: Citizen Tips
                    _buildCitizenTipsTab(reqs, isLight, cardBg, borderColor, textPri, textSec),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCaseManagementTab(UdbProvider udb, bool isLight, Color cardBg, Color borderColor, Color textPri, Color textSec) {
    final records = udb.allRecords;

    return ListView.separated(
      itemCount: records.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final r = records[index];
        final isActive = r.status == 'ACTIVE_GAZETTE';

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
    );
  }

  Widget _buildCitizenReportsTab(RequestProvider reqs, bool isLight, Color cardBg, Color borderColor, Color textPri, Color textSec) {
    final reports = reqs.citizenReports;
    if (reports.isEmpty) {
      return Center(child: Text('No citizen emergency reports filed.', style: TextStyle(color: textSec)));
    }

    return ListView.separated(
      itemCount: reports.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final rep = reports[index];
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.redBorder),
            boxShadow: isLight
                ? [
                    BoxShadow(
                      color: AppColors.red.withValues(alpha: 0.04),
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
                  Text(
                    '${rep.reportReference} • Reported by ${rep.reporterName} (${rep.reporterPhone})',
                    style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.redLight,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.redBorder),
                    ),
                    child: Text(rep.status, style: const TextStyle(color: AppColors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Spot: ${rep.spotLocation}, ${rep.thana}, ${rep.district} • Found: ${rep.dateSpotted}',
                style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                'Description: ${rep.description}',
                style: TextStyle(color: textSec, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCitizenTipsTab(RequestProvider reqs, bool isLight, Color cardBg, Color borderColor, Color textPri, Color textSec) {
    final tips = reqs.citizenTips;
    if (tips.isEmpty) {
      return Center(child: Text('No relative match claims or tips submitted yet.', style: TextStyle(color: textSec)));
    }

    return ListView.separated(
      itemCount: tips.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final tip = tips[index];
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
                  Text(
                    'Target: ${tip.bodyReference} • Claim by ${tip.claimantName} (${tip.relationshipToMissing})',
                    style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Text(tip.claimantPhone, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Missing Person: ${tip.missingPersonName} (GD: ${tip.missingPersonGd}, ${tip.thanaFiled})',
                style: TextStyle(color: textSec, fontSize: 12),
              ),
              const SizedBox(height: 6),
              Text(
                'Similarity Notes: ${tip.similarityReasons}',
                style: TextStyle(color: textPri, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}
