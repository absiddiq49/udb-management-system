import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../models/udb_record.dart';
import '../../providers/udb_provider.dart';
import '../../services/udb_repository.dart';
import '../widgets/kpi_card.dart';
import '../widgets/case_card.dart';
import '../widgets/filter_drawer.dart';
import '../widgets/app_footer.dart';

class PublicHomeView extends StatefulWidget {
  final ValueChanged<UdbRecord> onSelectRecord;
  final VoidCallback onReportFoundBody;
  final VoidCallback onRequestIoAccess;

  const PublicHomeView({
    super.key,
    required this.onSelectRecord,
    required this.onReportFoundBody,
    required this.onRequestIoAccess,
  });

  @override
  State<PublicHomeView> createState() => _PublicHomeViewState();
}

class _PublicHomeViewState extends State<PublicHomeView> {
  final _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final udb = context.watch<UdbProvider>();
    final isDesktop = Responsive.isDesktop(context);
    final records = udb.filteredRecords;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      endDrawer: FilterDrawer(
        initialFilters: udb.filters,
        onApply: (f) => udb.setFilters(f),
        onReset: () => udb.resetFilters(),
      ),
      body: SingleChildScrollView(
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
                // Hero Banner
                _buildHeroBanner(isDesktop, udb),

                const SizedBox(height: 24),

                // KPI Metrics Strip
                _buildKpiGrid(isDesktop, udb),

                const SizedBox(height: 28),

                // Search Bar & Filter Controls
                _buildSearchToolbar(context, isDesktop, udb),

                const SizedBox(height: 16),

                // Active Filter Chips Strip
                if (!udb.filters.isEmpty)
                  _buildActiveFilterChips(udb),

                const SizedBox(height: 16),

                // Results Toolbar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          children: [
                            const TextSpan(text: 'Showing '),
                            TextSpan(
                              text: '${records.length}',
                              style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: ' of ${udb.totalRecords} verified deceased records'),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.shield_outlined, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        const Text(
                          'Interpol DVI & NamUs Compliant',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Records Grid
                if (records.isNotEmpty)
                  _buildRecordGrid(isDesktop, records, udb.blurSensitive)
                else
                  _buildEmptyState(udb),
                const SizedBox(height: 48),
                const AppFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner(bool isDesktop, UdbProvider udb) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cardBg = isLight ? Colors.white : AppColors.darkCardBg;
    final borderColor = isLight ? AppColors.lightBorder : AppColors.darkBorder;
    final titleColor = isLight ? AppColors.slate900 : Colors.white;
    final subtitleColor = isLight ? AppColors.slate600 : AppColors.darkTextSecondary;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 32 : 20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: isLight
            ? const [
                BoxShadow(
                  color: Color(0x060F172A),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.goldLight,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.goldBorder),
                      ),
                      child: const Text(
                        'CENTRAL INTELLIGENCE BUREAU (CIB)',
                        style: TextStyle(color: AppColors.goldDark, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.greenLight,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.greenBorder),
                      ),
                      child: const Text(
                        'NATIONAL DNA & AFIS DATABASE',
                        style: TextStyle(color: AppColors.green, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Unidentified Deceased Management & Forensic Cross-Matching System',
                  style: TextStyle(
                    color: titleColor,
                    fontWeight: FontWeight.w900,
                    fontSize: isDesktop ? 26 : 20,
                    height: 1.25,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'A specialized, centralized platform by Criminal Investigation Department (CID), Bangladesh Police. '
                  'Search verified unidentified bodies recovered across all 64 districts using anthropological traits, tattoos, marks, and clothing.',
                  style: TextStyle(color: subtitleColor, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: widget.onReportFoundBody,
                      icon: const Icon(Icons.report_problem, size: 16),
                      label: const Text('Report Found Body (Emergency)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: widget.onRequestIoAccess,
                      icon: const Icon(Icons.vpn_key_outlined, size: 16),
                      label: const Text('Police Officer (IO) Access Request'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isLight ? AppColors.slate800 : Colors.white,
                        side: BorderSide(color: isLight ? AppColors.slate300 : AppColors.darkBorder),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isDesktop) ...[
            const SizedBox(width: 32),
            Image.asset(
              'assets/images/cid-logo-blue.png',
              height: 130,
              errorBuilder: (_, _, _) => Image.asset(
                'assets/images/CID.png',
                height: 130,
                errorBuilder: (_, _, _) => const Icon(Icons.shield_outlined, color: AppColors.primary, size: 100),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKpiGrid(bool isDesktop, UdbProvider udb) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final int crossAxisCount = width > 1000
            ? 5
            : width > 700
                ? 3
                : 2;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: width > 1100 ? 2.1 : (width > 700 ? 2.2 : 1.9),
          children: [
            KpiCard(
              title: 'CIB Database Index',
              count: '${udb.totalRecords}',
              subtitle: 'Total Deceased Records',
              icon: Icons.folder_open_outlined,
              accentColor: AppColors.blue,
            ),
            KpiCard(
              title: 'Recent Recoveries',
              count: '${udb.recentRecoveriesCount}',
              subtitle: 'Active cases in system',
              icon: Icons.access_time_outlined,
              accentColor: AppColors.gold,
            ),
            KpiCard(
              title: 'Biometric AFIS',
              count: '${udb.afisAvailableCount}',
              subtitle: 'Fingerprints collected',
              icon: Icons.fingerprint,
              accentColor: AppColors.cyan,
            ),
            KpiCard(
              title: 'DNA Profiling',
              count: '${udb.dnaAvailableCount}',
              subtitle: 'DNA profiles archived',
              icon: Icons.biotech_outlined,
              accentColor: AppColors.purple,
            ),
            KpiCard(
              title: 'Active Verification',
              count: '${udb.activeMatchingCount}',
              subtitle: 'Under cross-matching',
              icon: Icons.compare_arrows_outlined,
              accentColor: AppColors.green,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchToolbar(BuildContext context, bool isDesktop, UdbProvider udb) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cardBg = isLight ? Colors.white : AppColors.darkCardBg;
    final borderColor = isLight ? AppColors.lightBorder : AppColors.darkBorder;

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: AppColors.gold),
                    hintText: 'Search by case/GD ref, visible marks, tattoos, scars, clothing, thana, location...',
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              udb.updateKeywords('');
                            },
                          )
                        : null,
                  ),
                  onChanged: (val) => udb.updateKeywords(val),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                icon: const Icon(Icons.tune, size: 16),
                label: Text(isDesktop ? 'Filter Parameters' : 'Filters'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Quick Filter Shortcuts
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text('Quick Sex Filter: ', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                _quickFilterChip(
                  label: 'All Genders',
                  isSelected: udb.filters.gender == null || udb.filters.gender!.isEmpty,
                  onTap: () => udb.setFilters(_cloneFilter(udb.filters, gender: '')),
                ),
                _quickFilterChip(
                  label: 'Male',
                  isSelected: udb.filters.gender == 'Male',
                  onTap: () => udb.setFilters(_cloneFilter(udb.filters, gender: 'Male')),
                ),
                _quickFilterChip(
                  label: 'Female',
                  isSelected: udb.filters.gender == 'Female',
                  onTap: () => udb.setFilters(_cloneFilter(udb.filters, gender: 'Female')),
                ),
                const SizedBox(width: 16),
                const Text('Biometrics: ', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                _quickFilterChip(
                  label: 'Has DNA Profile',
                  isSelected: udb.filters.hasDna == true,
                  onTap: () => udb.setFilters(_cloneFilter(udb.filters, hasDna: udb.filters.hasDna == true ? null : true)),
                ),
                _quickFilterChip(
                  label: 'Has AFIS Fingerprint',
                  isSelected: udb.filters.hasFingerprint == true,
                  onTap: () => udb.setFilters(_cloneFilter(udb.filters, hasFingerprint: udb.filters.hasFingerprint == true ? null : true)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final fg = isSelected
        ? AppColors.primary
        : (isLight ? AppColors.slate700 : AppColors.darkTextSecondary);
    final bg = isSelected
        ? AppColors.primaryLight
        : (isLight ? AppColors.slate100 : AppColors.darkInputBg);
    final border = isSelected
        ? AppColors.primaryBorder
        : (isLight ? AppColors.slate200 : AppColors.darkBorder);

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: fg)),
        selected: isSelected,
        selectedColor: bg,
        backgroundColor: bg,
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onSelected: (_) => onTap(),
      ),
    );
  }

  Widget _buildActiveFilterChips(UdbProvider udb) {
    final f = udb.filters;
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Active Filters: ',
          style: TextStyle(
            color: isLight ? AppColors.slate700 : AppColors.darkTextSecondary,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (f.keywords != null && f.keywords!.isNotEmpty)
          _chip('Keyword: "${f.keywords}"', () => udb.updateKeywords('')),
        if (f.gender != null && f.gender!.isNotEmpty)
          _chip('Sex: ${f.gender}', () => udb.setFilters(_cloneFilter(f, gender: ''))),
        if (f.ageGroup != null && f.ageGroup!.isNotEmpty)
          _chip('Age: ${f.ageGroup}', () => udb.setFilters(_cloneFilter(f, ageGroup: ''))),
        if (f.division != null && f.division!.isNotEmpty)
          _chip('Division: ${f.division}', () => udb.setFilters(_cloneFilter(f, division: ''))),
        if (f.district != null && f.district!.isNotEmpty)
          _chip('District: ${f.district}', () => udb.setFilters(_cloneFilter(f, district: ''))),
        if (f.thana != null && f.thana!.isNotEmpty)
          _chip('Thana: ${f.thana}', () => udb.setFilters(_cloneFilter(f, thana: ''))),
        if (f.status != null && f.status!.isNotEmpty)
          _chip('Status: ${f.status}', () => udb.setFilters(_cloneFilter(f, status: ''))),
        if (f.hasFingerprint == true)
          _chip('AFIS Fingerprint', () => udb.setFilters(_cloneFilter(f, hasFingerprint: null))),
        if (f.hasDna == true)
          _chip('DNA Profile', () => udb.setFilters(_cloneFilter(f, hasDna: null))),
        TextButton(
          onPressed: () => udb.resetFilters(),
          child: const Text('Clear All', style: TextStyle(color: AppColors.red, fontSize: 11, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _chip(String label, VoidCallback onRemove) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
      backgroundColor: AppColors.primaryLight,
      side: const BorderSide(color: AppColors.primaryBorder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      deleteIcon: const Icon(Icons.close, size: 14, color: AppColors.primary),
      onDeleted: onRemove,
    );
  }

  Widget _buildRecordGrid(bool isDesktop, List<UdbRecord> records, bool blurSensitive) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final int crossAxisCount = width > 1150
            ? 3
            : width > 750
                ? 2
                : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: width > 1200
                ? 0.53
                : width > 750
                    ? 0.49
                    : 0.70,
          ),
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];
            return CaseCard(
              record: record,
              blurSensitive: blurSensitive,
              onTap: () => widget.onSelectRecord(record),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(UdbProvider udb) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cardBg = isLight ? Colors.white : AppColors.darkCardBg;
    final borderColor = isLight ? AppColors.lightBorder : AppColors.darkBorder;
    final titleColor = isLight ? AppColors.slate900 : Colors.white;
    final descColor = isLight ? AppColors.slate600 : AppColors.darkTextSecondary;

    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: isLight
            ? const [
                BoxShadow(
                  color: Color(0x060F172A),
                  blurRadius: 12,
                  offset: Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.search_off, size: 52, color: AppColors.slate400),
            const SizedBox(height: 16),
            Text(
              'No Matching Deceased Records Found',
              style: TextStyle(color: titleColor, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Try widening your age parameters, selecting all divisions, or clearing specific keyword filters.',
              style: TextStyle(color: descColor, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => udb.resetFilters(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Reset All Filters'),
            ),
          ],
        ),
      ),
    );
  }

  UdbFilterParams _cloneFilter(
    UdbFilterParams orig, {
    String? gender,
    String? ageGroup,
    String? division,
    String? district,
    String? thana,
    String? status,
    bool? hasFingerprint,
    bool? hasDna,
  }) {
    return UdbFilterParams(
      keywords: orig.keywords,
      gender: gender ?? orig.gender,
      ageGroup: ageGroup ?? orig.ageGroup,
      division: division ?? orig.division,
      district: district ?? orig.district,
      thana: thana ?? orig.thana,
      status: status ?? orig.status,
      hasFingerprint: hasFingerprint ?? orig.hasFingerprint,
      hasDna: hasDna ?? orig.hasDna,
    );
  }
}
