import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../services/udb_repository.dart';

class FilterDrawer extends StatefulWidget {
  final UdbFilterParams initialFilters;
  final ValueChanged<UdbFilterParams> onApply;
  final VoidCallback onReset;

  const FilterDrawer({
    super.key,
    required this.initialFilters,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<FilterDrawer> createState() => _FilterDrawerState();
}

class _FilterDrawerState extends State<FilterDrawer> {
  String? _gender;
  String? _ageGroup;
  String? _division;
  String? _district;
  String? _thana;
  String? _status;
  String? _complexion;
  bool _hasFingerprint = false;
  bool _hasDna = false;
  bool _hasPhotosOnly = false;

  late TextEditingController _districtController;
  late TextEditingController _thanaController;
  late TextEditingController _minAgeController;
  late TextEditingController _maxAgeController;
  late TextEditingController _minHeightController;
  late TextEditingController _maxHeightController;
  late TextEditingController _clothingController;
  late TextEditingController _dateFromController;
  late TextEditingController _dateToController;

  @override
  void initState() {
    super.initState();
    final f = widget.initialFilters;
    _gender = f.gender;
    _ageGroup = f.ageGroup;
    _division = f.division;
    _district = f.district;
    _thana = f.thana;
    _status = f.status;
    _complexion = f.complexion;
    _hasFingerprint = f.hasFingerprint ?? false;
    _hasDna = f.hasDna ?? false;
    _hasPhotosOnly = f.hasPhotosOnly ?? false;

    _districtController = TextEditingController(text: _district ?? '');
    _thanaController = TextEditingController(text: _thana ?? '');
    _minAgeController = TextEditingController(text: f.minAge?.toString() ?? '');
    _maxAgeController = TextEditingController(text: f.maxAge?.toString() ?? '');
    _minHeightController = TextEditingController(text: f.minHeight?.toString() ?? '');
    _maxHeightController = TextEditingController(text: f.maxHeight?.toString() ?? '');
    _clothingController = TextEditingController(text: f.clothingKeyword ?? '');
    _dateFromController = TextEditingController(text: f.dateFrom ?? '');
    _dateToController = TextEditingController(text: f.dateTo ?? '');
  }

  @override
  void dispose() {
    _districtController.dispose();
    _thanaController.dispose();
    _minAgeController.dispose();
    _maxAgeController.dispose();
    _minHeightController.dispose();
    _maxHeightController.dispose();
    _clothingController.dispose();
    _dateFromController.dispose();
    _dateToController.dispose();
    super.dispose();
  }

  List<String> get _currentDistricts {
    if (_division == null || !AppConstants.divisionDistricts.containsKey(_division)) {
      return AppConstants.divisionDistricts.values.expand((d) => d).toSet().toList()..sort();
    }
    return AppConstants.divisionDistricts[_division] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final drawerBg = isLight ? Colors.white : AppColors.darkCardBg;
    final headerFooterBg = isLight ? AppColors.slate50 : AppColors.darkSurface;
    final dividerColor = isLight ? AppColors.lightDivider : AppColors.darkDivider;
    final textPri = isLight ? AppColors.lightTextPrimary : AppColors.darkTextPrimary;
    final textSec = isLight ? AppColors.lightTextSecondary : AppColors.darkTextSecondary;

    return Drawer(
      backgroundColor: drawerBg,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: headerFooterBg,
                border: Border(bottom: BorderSide(color: dividerColor)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.tune, color: AppColors.gold, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Forensic Search Filters',
                    style: TextStyle(
                      color: textPri,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: textSec, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Filter Form Fields
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Division
                  _label('Administrative Division (বিভাগ)', textSec),
                  DropdownButtonFormField<String>(
                    initialValue: _division,
                    decoration: const InputDecoration(hintText: 'All Divisions'),
                    dropdownColor: drawerBg,
                    items: [
                      const DropdownMenuItem(value: '', child: Text('All Divisions (সব বিভাগ)')),
                      ...AppConstants.divisions.map((d) => DropdownMenuItem(value: d, child: Text(d))),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _division = (val == '' ? null : val);
                        _district = null;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // District
                  _label('District (জেলা)', textSec),
                  DropdownButtonFormField<String>(
                    initialValue: _district,
                    decoration: const InputDecoration(hintText: 'All Districts'),
                    dropdownColor: drawerBg,
                    items: [
                      const DropdownMenuItem(value: '', child: Text('All Districts (সব জেলা)')),
                      ..._currentDistricts.map((d) => DropdownMenuItem(value: d, child: Text(d))),
                    ],
                    onChanged: (val) => setState(() => _district = (val == '' ? null : val)),
                  ),

                  const SizedBox(height: 16),

                  // Thana
                  _label('Police Station (থানা)', textSec),
                  TextField(
                    controller: _thanaController,
                    decoration: const InputDecoration(hintText: 'e.g. Paltan, Kotwali, Boalia'),
                    onChanged: (val) => _thana = val.trim().isEmpty ? null : val.trim(),
                  ),

                  const SizedBox(height: 20),
                  Divider(color: dividerColor),
                  const SizedBox(height: 12),

                  // Biological Sex
                  _label('Biological Sex (লিঙ্গ)', textSec),
                  DropdownButtonFormField<String>(
                    initialValue: _gender,
                    decoration: const InputDecoration(hintText: 'All Genders'),
                    dropdownColor: drawerBg,
                    items: [
                      const DropdownMenuItem(value: '', child: Text('All Genders')),
                      ...AppConstants.genders.map((g) => DropdownMenuItem(value: g, child: Text(g))),
                    ],
                    onChanged: (val) => setState(() => _gender = (val == '' ? null : val)),
                  ),

                  const SizedBox(height: 16),

                  // Age Range (ZIPNET Min / Max Age)
                  _label('Estimated Age Range (বয়স পরিসীমা)', textSec),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minAgeController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: 'Min Age (e.g. 18)'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('to', style: TextStyle(color: textSec, fontSize: 12)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _maxAgeController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: 'Max Age (e.g. 45)'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Height Range (ZIPNET Height cm)
                  _label('Height Range (উচ্চতা সেমি)', textSec),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minHeightController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: 'Min (cm)'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('to', style: TextStyle(color: textSec, fontSize: 12)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _maxHeightController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: 'Max (cm)'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Complexion
                  _label('Complexion (গায়ের রঙ)', textSec),
                  DropdownButtonFormField<String>(
                    initialValue: _complexion,
                    decoration: const InputDecoration(hintText: 'Any Complexion'),
                    dropdownColor: drawerBg,
                    items: [
                      const DropdownMenuItem(value: '', child: Text('Any Complexion')),
                      ...AppConstants.complexions.map((c) => DropdownMenuItem(value: c.split(' ').first, child: Text(c))),
                    ],
                    onChanged: (val) => setState(() => _complexion = (val == '' ? null : val)),
                  ),

                  const SizedBox(height: 16),

                  // Clothing
                  _label('Clothing Keyword (পোশাকের ধরন)', textSec),
                  TextField(
                    controller: _clothingController,
                    decoration: const InputDecoration(hintText: 'e.g. Lungi, Shirt, Panjabi, Saree'),
                  ),

                  const SizedBox(height: 20),
                  Divider(color: dividerColor),
                  const SizedBox(height: 12),

                  // Case Status
                  _label('Case Status (অবস্থা)', textSec),
                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    decoration: const InputDecoration(hintText: 'Any Status'),
                    dropdownColor: drawerBg,
                    items: [
                      const DropdownMenuItem(value: '', child: Text('Any Status')),
                      ...AppConstants.caseStatuses.map((s) => DropdownMenuItem(value: s, child: Text(s))),
                    ],
                    onChanged: (val) => setState(() => _status = (val == '' ? null : val)),
                  ),

                  const SizedBox(height: 16),

                  // With Photos Only (ZIPNET Select Images)
                  CheckboxListTile(
                    title: Text('With Photos Only (শুধুমাত্র ছবিযুক্ত কেস)', style: TextStyle(fontSize: 13, color: textPri, fontWeight: FontWeight.bold)),
                    value: _hasPhotosOnly,
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) => setState(() => _hasPhotosOnly = v ?? false),
                  ),

                  // Biometric switches
                  CheckboxListTile(
                    title: Text('AFIS Fingerprint Available (১০-আঙ্গুলের ছাপ)', style: TextStyle(fontSize: 13, color: textPri)),
                    value: _hasFingerprint,
                    activeColor: AppColors.cyan,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) => setState(() => _hasFingerprint = v ?? false),
                  ),
                  CheckboxListTile(
                    title: Text('DNA Profile in CID Lab (ডিএনএ প্রোফাইল)', style: TextStyle(fontSize: 13, color: textPri)),
                    value: _hasDna,
                    activeColor: AppColors.purple,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) => setState(() => _hasDna = v ?? false),
                  ),
                ],
              ),
            ),

            // Footer Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: headerFooterBg,
                border: Border(top: BorderSide(color: dividerColor)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        widget.onReset();
                        Navigator.pop(context);
                      },
                      child: const Text('Reset All'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final int? minAge = int.tryParse(_minAgeController.text.trim());
                        final int? maxAge = int.tryParse(_maxAgeController.text.trim());
                        final int? minHeight = int.tryParse(_minHeightController.text.trim());
                        final int? maxHeight = int.tryParse(_maxHeightController.text.trim());

                        widget.onApply(widget.initialFilters.copyWith(
                          gender: _gender,
                          ageGroup: _ageGroup,
                          division: _division,
                          district: _district,
                          thana: _thana,
                          status: _status,
                          minAge: minAge,
                          maxAge: maxAge,
                          minHeight: minHeight,
                          maxHeight: maxHeight,
                          complexion: _complexion,
                          clothingKeyword: _clothingController.text.trim().isEmpty ? null : _clothingController.text.trim(),
                          hasPhotosOnly: _hasPhotosOnly ? true : null,
                          hasFingerprint: _hasFingerprint ? true : null,
                          hasDna: _hasDna ? true : null,
                        ));
                        Navigator.pop(context);
                      },
                      child: const Text('Apply Filters'),
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

  Widget _label(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
