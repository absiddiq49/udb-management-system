import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../models/udb_record.dart';
import '../../providers/udb_provider.dart';
import '../../providers/locale_provider.dart';
import '../widgets/case_card.dart';
import '../widgets/app_footer.dart';
import '../widgets/forensic_table_view.dart';
import '../widgets/zipnet_filter_dialog.dart';
import '../widgets/zipnet_search_dialog.dart';

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
  bool _isTableView = true; // UDBMS Default is Forensic Data Table View

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterDialog(BuildContext context, UdbProvider udb) {
    showDialog(
      context: context,
      builder: (_) => ZipnetFilterDialog(
        initialFilters: udb.filters,
        onApply: (f) => udb.setFilters(f),
        onReset: () => udb.resetFilters(),
      ),
    );
  }

  void _openSearchDialog(BuildContext context, UdbProvider udb) {
    showDialog(
      context: context,
      builder: (_) => ZipnetSearchDialog(
        initialFilters: udb.filters,
        onApply: (f) => udb.setFilters(f),
        onReset: () => udb.resetFilters(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final udb = context.watch<UdbProvider>();
    final loc = context.watch<LocaleProvider>();
    final isDesktop = Responsive.isDesktop(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final records = udb.filteredRecords;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 32 : 12,
          vertical: 16,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1360),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. UDBMS Breadcrumbs Navigation
                _buildBreadcrumbs(isDark, loc),

                const SizedBox(height: 12),

                // 2. UDBMS Section Header with [ Filter ] and [ Search ] Action Buttons
                _buildUdbmsPageHeader(context, isDark, isDesktop, udb, loc),

                const SizedBox(height: 16),

                // 3. Search Bar & Quick Forensic Presets Toolbar
                _buildUdbmsControlsBar(context, isDark, isDesktop, udb, loc),

                const SizedBox(height: 12),

                // 4. Active Filters Summary Ribbon (if any active filter)
                if (!udb.filters.isEmpty)
                  _buildActiveFilterChips(udb, loc),

                const SizedBox(height: 14),

                // 5. Main Records Display (Table view or Grid view)
                if (records.isNotEmpty)
                  _isTableView
                      ? ForensicTableView(
                          records: records,
                          onSelectRecord: widget.onSelectRecord,
                        )
                      : _buildRecordGrid(isDesktop, records, udb.blurSensitive)
                else
                  _buildEmptyState(udb, loc),

                const SizedBox(height: 48),

                // 6. Official UDBMS Footer
                const AppFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 1. Breadcrumbs Strip
  Widget _buildBreadcrumbs(bool isDark, LocaleProvider loc) {
    final textStyle = TextStyle(
      color: isDark ? AppColors.darkTextMuted : AppColors.slate500,
      fontSize: 11.5,
    );
    final activeStyle = TextStyle(
      color: isDark ? AppColors.goldBright : const Color(0xFF0F2646),
      fontSize: 11.5,
      fontWeight: FontWeight.bold,
    );

    return Row(
      children: [
        Icon(Icons.home, size: 14, color: textStyle.color),
        const SizedBox(width: 4),
        Text(loc.tr('Home', 'হোম'), style: textStyle),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Icon(Icons.chevron_right, size: 14, color: AppColors.slate400),
        ),
        Text(loc.tr('Victims', 'ভিকটিমস'), style: textStyle),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Icon(Icons.chevron_right, size: 14, color: AppColors.slate400),
        ),
        Text(
          loc.tr(
            'Un-Identified Dead Bodies (অজ্ঞাত মৃতদেহ)',
            'অজ্ঞাত মৃতদেহ রেজিস্ট্রি (UIDB)',
          ),
          style: activeStyle,
        ),
      ],
    );
  }

  // 2. UDBMS Header with prominent [ Filter ] & [ Search ] Buttons
  Widget _buildUdbmsPageHeader(
    BuildContext context,
    bool isDark,
    bool isDesktop,
    UdbProvider udb,
    LocaleProvider loc,
  ) {
    final cardBg = isDark ? AppColors.darkCardBg : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 22 : 14,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Title & Subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 4,
                        height: 22,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F2646),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        loc.tr('Un-Identified Dead Bodies', 'অজ্ঞাত মৃতদেহ রেজিস্ট্রি'),
                        style: const TextStyle(
                          color: Color(0xFF0F2646),
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          fontFamily: 'serif',
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFF1E3A8A).withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      loc.tr(
                        'Total: ${udb.totalRecords} Records',
                        'মোট: ${udb.totalRecords}টি মরদেহ',
                      ),
                      style: const TextStyle(
                        color: Color(0xFF1E3A8A),
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  loc.tr(
                    'Inter-District Central Biometric & Inquest Database • PRB Rule 299-303 & CrPC §174 • CID Bangladesh Police',
                    'বেঙ্গল পুলিশ রেগুলেশন (পিআরবি নিয়ম ২৯৯-৩০৩) ও সিআরপিসি ১৭৪ ধারা • সিআইডি কেন্দ্রীয় ডাটাবেজ',
                  ),
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.slate600,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          // Action Buttons: [ Filter ] and [ Search ] + View Mode
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // [ Filter ] Button (UDBMS Navy Blue Button)
              ElevatedButton.icon(
                onPressed: () => _openFilterDialog(context, udb),
                icon: const Icon(Icons.tune_rounded, size: 15),
                label: Text(
                  loc.tr('Filter', 'ফিল্টার'),
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, letterSpacing: 0.3),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F2646),
                  foregroundColor: Colors.white,
                  elevation: 1,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),

              const SizedBox(width: 10),

              // [ Search ] Button (UDBMS Amber / Orange Button)
              ElevatedButton.icon(
                onPressed: () => _openSearchDialog(context, udb),
                icon: const Icon(Icons.manage_search_rounded, size: 16),
                label: Text(
                  loc.tr('Search', 'অনুসন্ধান'),
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, letterSpacing: 0.3),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD97706),
                  foregroundColor: Colors.white,
                  elevation: 1,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),

              const SizedBox(width: 14),

              // View Mode Toggle (Table / Grid)
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.table_rows_rounded,
                        size: 16,
                        color: _isTableView ? const Color(0xFF0F2646) : AppColors.slate400,
                      ),
                      tooltip: loc.tr('Table View (UDBMS Default)', 'টেবিল ভিউ'),
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(),
                      onPressed: () => setState(() => _isTableView = true),
                    ),
                    Container(width: 1, height: 16, color: const Color(0xFFCBD5E1)),
                    IconButton(
                      icon: Icon(
                        Icons.grid_view_rounded,
                        size: 16,
                        color: !_isTableView ? const Color(0xFF0F2646) : AppColors.slate400,
                      ),
                      tooltip: loc.tr('Card Grid View', 'কার্ড গ্রিড ভিউ'),
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(),
                      onPressed: () => setState(() => _isTableView = false),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 3. Quick Search Bar & Forensic Presets Toolbar
  Widget _buildUdbmsControlsBar(
    BuildContext context,
    bool isDark,
    bool isDesktop,
    UdbProvider udb,
    LocaleProvider loc,
  ) {
    final cardBg = isDark ? AppColors.darkCardBg : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Instant Search Input
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => udb.updateKeywords(val),
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark ? Colors.white : AppColors.slate900,
                    ),
                    decoration: InputDecoration(
                      hintText: loc.tr(
                        'Search by case no, GD ref, thana, district, marks, clothing, scars, tattoos...',
                        'জিডি নং, থানা, জেলা, পোশাক, বিশেষ তিল, জন্মদাগ, ট্যাটু বা ক্ষতচিহ্ন দিয়ে অনুসন্ধান...',
                      ),
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextMuted : AppColors.slate400,
                      ),
                      prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF0F2646)),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 16),
                              onPressed: () {
                                _searchController.clear();
                                udb.updateKeywords('');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      filled: true,
                      fillColor: isDark ? AppColors.darkInputBg : const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFF0F2646), width: 1.5),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Reset All Filters Button
              TextButton.icon(
                onPressed: () {
                  _searchController.clear();
                  udb.resetFilters();
                },
                icon: const Icon(Icons.refresh_rounded, size: 15, color: AppColors.slate600),
                label: Text(
                  loc.tr('Reset', 'রিসেট'),
                  style: const TextStyle(color: AppColors.slate600, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: BorderSide(color: isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1)),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Quick Presets Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Text(
                  loc.tr('Quick Filters: ', 'দ্রুত ফিল্টার: '),
                  style: const TextStyle(
                    color: Color(0xFF0F2646),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                _quickFilterChip(
                  label: loc.tr('All (${udb.totalRecords})', 'সকল (${udb.totalRecords})'),
                  isSelected: udb.filters.quickPreset == null || udb.filters.quickPreset == 'all',
                  onTap: () => udb.updateQuickPreset('all'),
                ),
                _quickFilterChip(
                  label: loc.tr('DNA Archived (${udb.dnaAvailableCount})', 'ডিএনএ প্রোফাইল (${udb.dnaAvailableCount})'),
                  isSelected: udb.filters.quickPreset == 'withDna',
                  onTap: () => udb.updateQuickPreset(udb.filters.quickPreset == 'withDna' ? 'all' : 'withDna'),
                ),
                _quickFilterChip(
                  label: loc.tr('AFIS Fingerprints (${udb.afisAvailableCount})', 'আঙ্গুলের ছাপ AFIS (${udb.afisAvailableCount})'),
                  isSelected: udb.filters.quickPreset == 'withAfis',
                  onTap: () => udb.updateQuickPreset(udb.filters.quickPreset == 'withAfis' ? 'all' : 'withAfis'),
                ),
                _quickFilterChip(
                  label: loc.tr('Water Floater', 'পানিতে ভাসমান মরদেহ'),
                  isSelected: udb.filters.quickPreset == 'floater',
                  onTap: () => udb.updateQuickPreset(udb.filters.quickPreset == 'floater' ? 'all' : 'floater'),
                ),
                _quickFilterChip(
                  label: loc.tr('Skeletal / Decomposed', 'কঙ্কালসার / অর্ধগলিত'),
                  isSelected: udb.filters.quickPreset == 'skeletal',
                  onTap: () => udb.updateQuickPreset(udb.filters.quickPreset == 'skeletal' ? 'all' : 'skeletal'),
                ),
                const SizedBox(width: 8),
                Text('|  ${loc.tr('Sex: ', 'লিঙ্গ: ')}', style: const TextStyle(color: AppColors.slate400, fontSize: 11)),
                _quickFilterChip(
                  label: loc.tr('Male', 'পুরুষ'),
                  isSelected: udb.filters.gender == 'Male',
                  onTap: () => udb.setFilters(udb.filters.copyWith(gender: udb.filters.gender == 'Male' ? '' : 'Male')),
                ),
                _quickFilterChip(
                  label: loc.tr('Female', 'নারী'),
                  isSelected: udb.filters.gender == 'Female',
                  onTap: () => udb.setFilters(udb.filters.copyWith(gender: udb.filters.gender == 'Female' ? '' : 'Female')),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Law Enforcement Agency Filter Strip
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Text(
                  loc.tr('Investigating Agency: ', 'তদন্তকারী ইউনিট: '),
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : const Color(0xFF0F2646),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                _agencyPill(
                  code: 'all',
                  label: loc.tr('All Agencies', 'সকল ইউনিট'),
                  isSelected: udb.filters.agency == null || udb.filters.agency == 'all',
                  onTap: () => udb.updateAgency('all'),
                ),
                _agencyPill(
                  code: 'CID',
                  label: loc.tr('CID Forensics', 'সিআইডি ফরেনসিক'),
                  isSelected: udb.filters.agency == 'CID',
                  onTap: () => udb.updateAgency(udb.filters.agency == 'CID' ? 'all' : 'CID'),
                ),
                _agencyPill(
                  code: 'DMP',
                  label: loc.tr('DMP (Dhaka)', 'ডিএমপি মেট্রোপলিটন'),
                  isSelected: udb.filters.agency == 'DMP',
                  onTap: () => udb.updateAgency(udb.filters.agency == 'DMP' ? 'all' : 'DMP'),
                ),
                _agencyPill(
                  code: 'PBI',
                  label: loc.tr('PBI Investigation', 'পিবিআই তদন্ত ব্যুরো'),
                  isSelected: udb.filters.agency == 'PBI',
                  onTap: () => udb.updateAgency(udb.filters.agency == 'PBI' ? 'all' : 'PBI'),
                ),
                _agencyPill(
                  code: 'RAB',
                  label: loc.tr('RAB Elite Force', 'র‍্যাব এলিট ফোর্স'),
                  isSelected: udb.filters.agency == 'RAB',
                  onTap: () => udb.updateAgency(udb.filters.agency == 'RAB' ? 'all' : 'RAB'),
                ),
                _agencyPill(
                  code: 'Railway',
                  label: loc.tr('Railway Police (GRP)', 'রেলওয়ে পুলিশ (জিআরপি)'),
                  isSelected: udb.filters.agency == 'Railway',
                  onTap: () => udb.updateAgency(udb.filters.agency == 'Railway' ? 'all' : 'Railway'),
                ),
                _agencyPill(
                  code: 'Highway',
                  label: loc.tr('Highway Police', 'হাইওয়ে পুলিশ'),
                  isSelected: udb.filters.agency == 'Highway',
                  onTap: () => udb.updateAgency(udb.filters.agency == 'Highway' ? 'all' : 'Highway'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _agencyPill({
    required String code,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isSelected
        ? Colors.white
        : (isDark ? AppColors.darkTextSecondary : const Color(0xFF1E293B));
    final bg = isSelected
        ? const Color(0xFF0F2646)
        : (isDark ? AppColors.darkInputBg : const Color(0xFFF1F5F9));
    final border = isSelected
        ? const Color(0xFF38BDF8)
        : (isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1));

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: isSelected ? 1.2 : 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF38BDF8) : AppColors.slate400,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isSelected
        ? Colors.white
        : (isDark ? AppColors.darkTextSecondary : const Color(0xFF0F2646));
    final bg = isSelected
        ? const Color(0xFF0F2646)
        : (isDark ? AppColors.darkInputBg : const Color(0xFFF1F5F9));
    final border = isSelected
        ? const Color(0xFF0F2646)
        : (isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1));

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: border),
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 10.5, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600, color: fg),
          ),
        ),
      ),
    );
  }

  // 4. Active Filters Summary Ribbon
  Widget _buildActiveFilterChips(UdbProvider udb, LocaleProvider loc) {
    final f = udb.filters;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.filter_alt, size: 14, color: Color(0xFFB45309)),
              const SizedBox(width: 4),
              Text(
                loc.tr('Active Filters: ', 'সক্রিয় ফিল্টারসমূহ: '),
                style: const TextStyle(
                  color: Color(0xFFB45309),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (f.quickPreset != null && f.quickPreset != 'all')
            _chip('Preset: ${f.quickPreset}', () => udb.updateQuickPreset('all')),
          if (f.agency != null && f.agency!.isNotEmpty && f.agency != 'all')
            _chip('Agency: ${f.agency}', () => udb.updateAgency('all')),
          if (f.keywords != null && f.keywords!.isNotEmpty)
            _chip('Keyword: "${f.keywords}"', () => udb.updateKeywords('')),
          if (f.gender != null && f.gender!.isNotEmpty)
            _chip('Sex: ${f.gender}', () => udb.setFilters(f.copyWith(gender: ''))),
          if (f.division != null && f.division!.isNotEmpty)
            _chip('Division: ${f.division}', () => udb.setFilters(f.copyWith(division: ''))),
          if (f.district != null && f.district!.isNotEmpty)
            _chip('District: ${f.district}', () => udb.setFilters(f.copyWith(district: ''))),
          if (f.thana != null && f.thana!.isNotEmpty)
            _chip('Thana: ${f.thana}', () => udb.setFilters(f.copyWith(thana: ''))),
          if (f.minAge != null || f.maxAge != null)
            _chip('Age: ${f.minAge ?? 0}-${f.maxAge ?? 100}y', () => udb.setFilters(f.copyWith(minAge: null, maxAge: null))),
          if (f.minHeight != null || f.maxHeight != null)
            _chip('Height: ${f.minHeight ?? 0}-${f.maxHeight ?? 220}cm', () => udb.setFilters(f.copyWith(minHeight: null, maxHeight: null))),
          if (f.complexion != null && f.complexion!.isNotEmpty)
            _chip('Complexion: ${f.complexion}', () => udb.setFilters(f.copyWith(complexion: ''))),
          if (f.clothingKeyword != null && f.clothingKeyword!.isNotEmpty)
            _chip('Clothing: ${f.clothingKeyword}', () => udb.setFilters(f.copyWith(clothingKeyword: ''))),
          if (f.hasPhotosOnly == true)
            _chip(loc.tr('With Photos Only', 'শুধুমাত্র ছবিযুক্ত'), () => udb.setFilters(f.copyWith(hasPhotosOnly: false))),
          if (f.dateFrom != null || f.dateTo != null)
            _chip('Found Date: ${f.dateFrom ?? "Start"} to ${f.dateTo ?? "End"}', () => udb.setFilters(f.copyWith(dateFrom: '', dateTo: ''))),
          TextButton(
            onPressed: () => udb.resetFilters(),
            child: Text(
              loc.tr('Clear All Filters', 'সকল ফিল্টার মুছুন'),
              style: const TextStyle(color: AppColors.redDark, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, VoidCallback onRemove) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 10.5, color: Color(0xFF0F2646), fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white,
      side: const BorderSide(color: Color(0xFFCBD5E1)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      deleteIcon: const Icon(Icons.close, size: 13, color: Color(0xFF0F2646)),
      onDeleted: onRemove,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  // 5. Grid View (Fallback if user toggles view)
  Widget _buildRecordGrid(bool isDesktop, List<UdbRecord> records, bool blurSensitive) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 380,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            mainAxisExtent: 410,
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

  // Empty State
  Widget _buildEmptyState(UdbProvider udb, LocaleProvider loc) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCardBg : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1);

    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.search_off_rounded, size: 52, color: AppColors.slate400),
            const SizedBox(height: 14),
            Text(
              loc.tr(
                'No Matching Deceased Records Found in UDBMS Registry',
                'ইউডিবিএমএস রেজিস্ট্রিতে কোনো মিল পাওয়া যায়নি',
              ),
              style: const TextStyle(color: Color(0xFF0F2646), fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              loc.tr(
                'Try clearing some filter criteria, broadening the age/height range, or searching for fewer keywords.',
                'অনুসন্ধানের পরিধি বাড়াতে ফিল্টার অপশনগুলো রিসেট করুন অথবা বয়স ও উচ্চতার সীমা প্রসারিত করুন।',
              ),
              style: const TextStyle(color: AppColors.slate600, fontSize: 12.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () => udb.resetFilters(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F2646),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: Text(loc.tr('Reset All Filters', 'সকল ফিল্টার রিসেট করুন')),
            ),
          ],
        ),
      ),
    );
  }
}
