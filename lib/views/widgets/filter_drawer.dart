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
  bool _hasFingerprint = false;
  bool _hasDna = false;

  late TextEditingController _districtController;
  late TextEditingController _thanaController;

  @override
  void initState() {
    super.initState();
    _gender = widget.initialFilters.gender;
    _ageGroup = widget.initialFilters.ageGroup;
    _division = widget.initialFilters.division;
    _district = widget.initialFilters.district;
    _thana = widget.initialFilters.thana;
    _status = widget.initialFilters.status;
    _hasFingerprint = widget.initialFilters.hasFingerprint ?? false;
    _hasDna = widget.initialFilters.hasDna ?? false;

    _districtController = TextEditingController(text: _district ?? '');
    _thanaController = TextEditingController(text: _thana ?? '');
  }

  @override
  void dispose() {
    _districtController.dispose();
    _thanaController.dispose();
    super.dispose();
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
                  _label('Administrative Division', textSec),
                  DropdownButtonFormField<String>(
                    initialValue: _division,
                    decoration: const InputDecoration(hintText: 'All Divisions'),
                    dropdownColor: drawerBg,
                    items: [
                      const DropdownMenuItem(value: '', child: Text('All Divisions')),
                      ...AppConstants.divisions.map((d) => DropdownMenuItem(value: d, child: Text(d))),
                    ],
                    onChanged: (val) => setState(() => _division = (val == '' ? null : val)),
                  ),

                  const SizedBox(height: 16),

                  // District
                  _label('District', textSec),
                  TextField(
                    controller: _districtController,
                    decoration: const InputDecoration(hintText: 'e.g. Dhaka, Sylhet, Rangpur'),
                    onChanged: (val) => _district = val.trim().isEmpty ? null : val.trim(),
                  ),

                  const SizedBox(height: 16),

                  // Thana
                  _label('Police Station (Thana)', textSec),
                  TextField(
                    controller: _thanaController,
                    decoration: const InputDecoration(hintText: 'e.g. Paltan, Kotwali, Boalia'),
                    onChanged: (val) => _thana = val.trim().isEmpty ? null : val.trim(),
                  ),

                  const SizedBox(height: 20),
                  Divider(color: dividerColor),
                  const SizedBox(height: 12),

                  // Biological Sex
                  _label('Biological Sex', textSec),
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

                  // Age Bracket
                  _label('Estimated Age Bracket', textSec),
                  DropdownButtonFormField<String>(
                    initialValue: _ageGroup,
                    decoration: const InputDecoration(hintText: 'All Age Brackets'),
                    dropdownColor: drawerBg,
                    items: [
                      const DropdownMenuItem(value: '', child: Text('All Age Brackets')),
                      ...AppConstants.ageGroups.map((a) => DropdownMenuItem(value: a, child: Text(a))),
                    ],
                    onChanged: (val) => setState(() => _ageGroup = (val == '' ? null : val)),
                  ),

                  const SizedBox(height: 20),
                  Divider(color: dividerColor),
                  const SizedBox(height: 12),

                  // Case Status
                  _label('Case Status', textSec),
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

                  // Biometric switches
                  CheckboxListTile(
                    title: Text('AFIS Fingerprint Available', style: TextStyle(fontSize: 13, color: textPri)),
                    value: _hasFingerprint,
                    activeColor: AppColors.gold,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) => setState(() => _hasFingerprint = v ?? false),
                  ),
                  CheckboxListTile(
                    title: Text('DNA Profile in CID Lab', style: TextStyle(fontSize: 13, color: textPri)),
                    value: _hasDna,
                    activeColor: AppColors.gold,
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
                        widget.onApply(UdbFilterParams(
                          keywords: widget.initialFilters.keywords,
                          gender: _gender,
                          ageGroup: _ageGroup,
                          division: _division,
                          district: _district,
                          thana: _thana,
                          status: _status,
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

  Widget _label(String text, Color textSec) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          color: textSec,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
