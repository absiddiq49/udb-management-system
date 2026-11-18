import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/locale_provider.dart';
import '../../services/udb_repository.dart';

class ZipnetSearchDialog extends StatefulWidget {
  final UdbFilterParams initialFilters;
  final ValueChanged<UdbFilterParams> onApply;
  final VoidCallback onReset;

  const ZipnetSearchDialog({
    super.key,
    required this.initialFilters,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<ZipnetSearchDialog> createState() => _ZipnetSearchDialogState();
}

class _ZipnetSearchDialogState extends State<ZipnetSearchDialog> {
  String? _division;
  String? _district;
  final _thanaController = TextEditingController();
  final _dateFromController = TextEditingController();
  final _dateToController = TextEditingController();

  String? _gender;
  final _minAgeController = TextEditingController();
  final _maxAgeController = TextEditingController();
  final _minHeightController = TextEditingController();
  final _maxHeightController = TextEditingController();

  String? _complexion;
  final _clothingController = TextEditingController();
  final _marksController = TextEditingController();

  bool _hasPhotosOnly = false;
  bool _hasDna = false;
  bool _hasFingerprint = false;

  @override
  void initState() {
    super.initState();
    final f = widget.initialFilters;
    _division = f.division;
    _district = f.district;
    if (f.thana != null) _thanaController.text = f.thana!;
    if (f.dateFrom != null) _dateFromController.text = f.dateFrom!;
    if (f.dateTo != null) _dateToController.text = f.dateTo!;

    _gender = f.gender;
    if (f.minAge != null) _minAgeController.text = f.minAge.toString();
    if (f.maxAge != null) _maxAgeController.text = f.maxAge.toString();
    if (f.minHeight != null) _minHeightController.text = f.minHeight.toString();
    if (f.maxHeight != null) _maxHeightController.text = f.maxHeight.toString();

    _complexion = f.complexion;
    if (f.clothingKeyword != null) _clothingController.text = f.clothingKeyword!;
    if (f.keywords != null) _marksController.text = f.keywords!;

    _hasPhotosOnly = f.hasPhotosOnly ?? false;
    _hasDna = f.hasDna ?? false;
    _hasFingerprint = f.hasFingerprint ?? false;
  }

  @override
  void dispose() {
    _thanaController.dispose();
    _dateFromController.dispose();
    _dateToController.dispose();
    _minAgeController.dispose();
    _maxAgeController.dispose();
    _minHeightController.dispose();
    _maxHeightController.dispose();
    _clothingController.dispose();
    _marksController.dispose();
    super.dispose();
  }

  void _handleReset() {
    widget.onReset();
    Navigator.pop(context);
  }

  void _handleApply() {
    final int? minAge = int.tryParse(_minAgeController.text.trim());
    final int? maxAge = int.tryParse(_maxAgeController.text.trim());
    final int? minHeight = int.tryParse(_minHeightController.text.trim());
    final int? maxHeight = int.tryParse(_maxHeightController.text.trim());

    final updated = widget.initialFilters.copyWith(
      division: _division?.isEmpty == true ? null : _division,
      district: _district?.isEmpty == true ? null : _district,
      thana: _thanaController.text.trim().isEmpty ? null : _thanaController.text.trim(),
      dateFrom: _dateFromController.text.trim().isEmpty ? null : _dateFromController.text.trim(),
      dateTo: _dateToController.text.trim().isEmpty ? null : _dateToController.text.trim(),
      gender: _gender?.isEmpty == true ? null : _gender,
      minAge: minAge,
      maxAge: maxAge,
      minHeight: minHeight,
      maxHeight: maxHeight,
      complexion: _complexion?.isEmpty == true ? null : _complexion,
      clothingKeyword: _clothingController.text.trim().isEmpty ? null : _clothingController.text.trim(),
      keywords: _marksController.text.trim().isEmpty ? null : _marksController.text.trim(),
      hasPhotosOnly: _hasPhotosOnly ? true : null,
      hasDna: _hasDna ? true : null,
      hasFingerprint: _hasFingerprint ? true : null,
    );

    widget.onApply(updated);
    Navigator.pop(context);
  }

  List<String> get _currentDistricts {
    if (_division == null || !AppConstants.divisionDistricts.containsKey(_division)) {
      return AppConstants.divisionDistricts.values.expand((d) => d).toSet().toList()..sort();
    }
    return AppConstants.divisionDistricts[_division] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCardBg : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.slate900;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.slate600;

    return Dialog(
      backgroundColor: cardBg,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 780, maxHeight: 850),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F2646),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD97706),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.manage_search_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.tr(
                            'UDBMS Multi-Parametric Forensic Search',
                            'ইউডিবিএমএস বহু-মাত্রিক ফরেনসিক অনুসন্ধান',
                          ),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          loc.tr(
                            'Search across all 64 districts using exact physical traits, age, height, clothing and DNA/AFIS status.',
                            'শারীরিক বৈশিষ্ট্য, আনুমানিক বয়স, উচ্চতা, পোশাকের বিবরণ ও ডিএনএ/বায়োমেট্রিক তথ্য দিয়ে অনুসন্ধান।',
                          ),
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Form Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Jurisdiction & Geography
                    _sectionTitle(loc.tr('1. Administrative Jurisdiction (প্রশাসনিক এলাকা ও থানা)', '১. প্রশাসনিক এখতিয়ার ও থানা'), Icons.map_outlined),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _division,
                            decoration: InputDecoration(
                              labelText: loc.tr('Division (বিভাগ)', 'বিভাগ (Division)'),
                              hintText: loc.tr('All Divisions', 'সকল বিভাগ'),
                            ),
                            dropdownColor: cardBg,
                            items: [
                              DropdownMenuItem(value: '', child: Text(loc.tr('All Divisions (সব বিভাগ)', 'সকল বিভাগ'))),
                              ...AppConstants.divisions.map((d) => DropdownMenuItem(value: d, child: Text(d))),
                            ],
                            onChanged: (val) {
                              setState(() {
                                _division = (val == '' ? null : val);
                                _district = null;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _district,
                            decoration: InputDecoration(
                              labelText: loc.tr('District (জেলা)', 'জেলা (District)'),
                              hintText: loc.tr('All Districts', 'সকল জেলা'),
                            ),
                            dropdownColor: cardBg,
                            items: [
                              DropdownMenuItem(value: '', child: Text(loc.tr('All Districts (সকল জেলা)', 'সকল জেলা'))),
                              ..._currentDistricts.map((d) => DropdownMenuItem(value: d, child: Text(d))),
                            ],
                            onChanged: (val) {
                              setState(() => _district = (val == '' ? null : val));
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller: _thanaController,
                      decoration: InputDecoration(
                        labelText: loc.tr('Police Station / Spot (থানা বা উদ্ধারের এলাকা)', 'থানা বা উদ্ধারের স্থান'),
                        hintText: loc.tr('e.g. Paltan, Kotwali, Boalia, Buriganga...', 'যেমন: পল্টন, কোতোয়ালী, বোয়ালিয়া, বুড়িগঙ্গা...'),
                        prefixIcon: const Icon(Icons.place_outlined, size: 18),
                      ),
                    ),

                    const SizedBox(height: 22),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Section 2: Physical & Anthropometric Traits
                    _sectionTitle(loc.tr('2. Physical & Biological Traits (শারীরিক ও জৈবিক বিবরণ)', '২. শারীরিক ও জৈবিক বিবরণ'), Icons.accessibility_new_outlined),
                    const SizedBox(height: 12),

                    // Gender & Complexion Row
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _gender,
                            decoration: InputDecoration(labelText: loc.tr('Sex / Gender (লিঙ্গ)', 'লিঙ্গ (Gender)')),
                            dropdownColor: cardBg,
                            items: [
                              DropdownMenuItem(value: '', child: Text(loc.tr('All (যেকোনো লিঙ্গ)', 'যেকোনো লিঙ্গ'))),
                              DropdownMenuItem(value: 'Male', child: Text(loc.tr('Male (পুরুষ)', 'পুরুষ'))),
                              DropdownMenuItem(value: 'Female', child: Text(loc.tr('Female (নারী)', 'নারী'))),
                              DropdownMenuItem(value: 'Transgender', child: Text(loc.tr('Transgender (তৃতীয় লিঙ্গ)', 'তৃতীয় লিঙ্গ'))),
                              DropdownMenuItem(value: 'Unknown', child: Text(loc.tr('Unknown / Skeleton (অজ্ঞাত / কঙ্কাল)', 'অজ্ঞাত / কঙ্কাল'))),
                            ],
                            onChanged: (val) => setState(() => _gender = (val == '' ? null : val)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _complexion,
                            decoration: InputDecoration(labelText: loc.tr('Complexion (গায়ের রং)', 'গায়ের রং (Complexion)')),
                            dropdownColor: cardBg,
                            items: [
                              DropdownMenuItem(value: '', child: Text(loc.tr('Any Complexion', 'যেকোনো গায়ের রং'))),
                              ...AppConstants.complexions.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                            ],
                            onChanged: (val) => setState(() => _complexion = (val == '' ? null : val)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Age Range
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _minAgeController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: loc.tr('Min Age (সর্বনিম্ন বয়স)', 'সর্বনিম্ন বয়স (বছর)'),
                              hintText: '0',
                              suffixText: 'yrs',
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextField(
                            controller: _maxAgeController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: loc.tr('Max Age (সর্বোচ্চ বয়স)', 'সর্বোচ্চ বয়স (বছর)'),
                              hintText: '100',
                              suffixText: 'yrs',
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Height Range
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _minHeightController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: loc.tr('Min Height (সর্বনিম্ন উচ্চতা)', 'সর্বনিম্ন উচ্চতা (সেমি)'),
                              hintText: '120',
                              suffixText: 'cm',
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextField(
                            controller: _maxHeightController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: loc.tr('Max Height (সর্বোচ্চ উচ্চতা)', 'সর্বোচ্চ উচ্চতা (সেমি)'),
                              hintText: '210',
                              suffixText: 'cm',
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Section 3: Clothing, Scars & Special Marks
                    _sectionTitle(loc.tr('3. Clothing & Distinct Marks (পোশাক ও চিহ্নিতকরণ দাগ)', '৩. পোশাক ও চিহ্নিতকরণ দাগ'), Icons.checkroom_outlined),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _clothingController,
                      decoration: InputDecoration(
                        labelText: loc.tr('Clothing Description / Keyword (পোশাকের বিবরণ)', 'পোশাকের বিবরণ বা কীওয়ার্ড'),
                        hintText: loc.tr('e.g. Lungi, Shirt, Panjabi, Saree, Jeans...', 'যেমন: লুঙ্গি, শার্ট, পাঞ্জাবি, শাড়ি, জিন্স...'),
                        prefixIcon: const Icon(Icons.dry_cleaning_outlined, size: 18),
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller: _marksController,
                      decoration: InputDecoration(
                        labelText: loc.tr('Visible Marks, Scars, Tattoos (দাগ, তিল, কাটা চিহ্ন বা ট্যাটু)', 'দাগ, তিল, কাটা চিহ্ন বা ট্যাটু'),
                        hintText: loc.tr('e.g. Mole on neck, Burn scar on arm, Tattoo...', 'যেমন: ঘাড়ে তিল, পোড়া দাগ, কাটা চিহ্ন, ট্যাটু...'),
                        prefixIcon: const Icon(Icons.fingerprint_outlined, size: 18),
                      ),
                    ),

                    const SizedBox(height: 22),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Section 4: Forensic & Visual Criteria
                    _sectionTitle(loc.tr('4. Evidence & Forensic Filters (ফরেনসিক ও ছবি ফিল্টার)', '৪. ফরেনসিক ও সংরক্ষিত ছবি ফিল্টার'), Icons.biotech_outlined),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              loc.tr('Select Images (শুধুমাত্র ছবিযুক্ত মরদেহ ফিল্টার করুন)', 'শুধুমাত্র ছবিযুক্ত মরদেহ ফিল্টার করুন'),
                              style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 12.5),
                            ),
                            subtitle: Text(
                              loc.tr('Exclude records without verified face or body photos', 'ছবিহীন রেকর্ড বাদ দিয়ে কেবল যাচাইকৃত ছবিযুক্ত কেস দেখাবে'),
                              style: TextStyle(color: textSec, fontSize: 10.5),
                            ),
                            value: _hasPhotosOnly,
                            onChanged: (v) => setState(() => _hasPhotosOnly = v ?? false),
                          ),
                          const Divider(height: 8),
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              loc.tr('DNA Profile Available (সংরক্ষিত ডিএনএ প্রোফাইল)', 'সংরক্ষিত ডিএনএ প্রোফাইল বিদ্যমান'),
                              style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 12.5),
                            ),
                            value: _hasDna,
                            onChanged: (v) => setState(() => _hasDna = v ?? false),
                          ),
                          const Divider(height: 8),
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              loc.tr('AFIS Fingerprints Collected (এনআইডি মিলকরণ উপযোগী আঙ্গুলের ছাপ)', '১০ আঙ্গুলের ছাপ সংগৃহীত (AFIS NID Cross-Match)'),
                              style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 12.5),
                            ),
                            value: _hasFingerprint,
                            onChanged: (v) => setState(() => _hasFingerprint = v ?? false),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                border: Border(top: BorderSide(color: borderColor)),
              ),
              child: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _handleReset,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: Text(loc.tr('Reset All Filters', 'সকল ফিল্টার রিসেট')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.red,
                      side: const BorderSide(color: AppColors.redBorder),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(loc.tr('Cancel', 'বাতিল')),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _handleApply,
                    icon: const Icon(Icons.search, size: 16),
                    label: Text(
                      loc.tr('Apply Search', 'অনুসন্ধান করুন'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F2646),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF0F2646)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, letterSpacing: 0.2),
        ),
      ],
    );
  }
}
