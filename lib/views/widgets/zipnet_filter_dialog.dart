import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/locale_provider.dart';
import '../../services/udb_repository.dart';

class ZipnetFilterDialog extends StatefulWidget {
  final UdbFilterParams initialFilters;
  final ValueChanged<UdbFilterParams> onApply;
  final VoidCallback onReset;

  const ZipnetFilterDialog({
    super.key,
    required this.initialFilters,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<ZipnetFilterDialog> createState() => _ZipnetFilterDialogState();
}

class _ZipnetFilterDialogState extends State<ZipnetFilterDialog> {
  String? _division;
  String? _district;
  String? _agency;
  final _thanaController = TextEditingController();
  final _gdDateFromController = TextEditingController();
  final _gdDateToController = TextEditingController();
  final _reportDateFromController = TextEditingController();
  final _reportDateToController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final f = widget.initialFilters;
    _division = f.division;
    _district = f.district;
    _agency = f.agency;
    if (f.thana != null) _thanaController.text = f.thana!;
    if (f.dateFrom != null) _gdDateFromController.text = f.dateFrom!;
    if (f.dateTo != null) _gdDateToController.text = f.dateTo!;
  }

  @override
  void dispose() {
    _thanaController.dispose();
    _gdDateFromController.dispose();
    _gdDateToController.dispose();
    _reportDateFromController.dispose();
    _reportDateToController.dispose();
    super.dispose();
  }

  List<String> get _currentDistricts {
    if (_division == null || !AppConstants.divisionDistricts.containsKey(_division)) {
      return AppConstants.divisionDistricts.values.expand((d) => d).toSet().toList()..sort();
    }
    return AppConstants.divisionDistricts[_division] ?? [];
  }

  void _handleReset() {
    widget.onReset();
    Navigator.pop(context);
  }

  void _handleFilter() {
    final updated = widget.initialFilters.copyWith(
      division: _division?.isEmpty == true ? null : _division,
      district: _district?.isEmpty == true ? null : _district,
      agency: _agency == 'all' || _agency?.isEmpty == true ? null : _agency,
      thana: _thanaController.text.trim().isEmpty ? null : _thanaController.text.trim(),
      dateFrom: _gdDateFromController.text.trim().isEmpty ? null : _gdDateFromController.text.trim(),
      dateTo: _gdDateToController.text.trim().isEmpty ? null : _gdDateToController.text.trim(),
    );
    widget.onApply(updated);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCardBg : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.slate600;

    return Dialog(
      backgroundColor: cardBg,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: borderColor),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Modal Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F2646),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.filter_alt_outlined, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      loc.tr('Administrative & Jurisdiction Filter', 'প্রশাসনিক এখতিয়ার ও তারিখ ফিল্টার'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Modal Form Body
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Law Enforcement Agency Dropdown
                    _fieldLabel(loc.tr('Investigating Agency / Unit (তদন্তকারী ইউনিট)', 'তদন্তকারী সংস্থা / ইউনিট'), textSec),
                    DropdownButtonFormField<String>(
                      initialValue: _agency ?? 'all',
                      decoration: InputDecoration(hintText: loc.tr('All Agencies (সকল ইউনিট)', 'সকল ইউনিট')),
                      dropdownColor: cardBg,
                      items: [
                        DropdownMenuItem(value: 'all', child: Text(loc.tr('All Agencies (সকল ইউনিট)', 'সকল ইউনিট'))),
                        DropdownMenuItem(value: 'CID', child: Text(loc.tr('CID Forensics (সিআইডি)', 'সিআইডি ফরেনসিক'))),
                        DropdownMenuItem(value: 'DMP', child: Text(loc.tr('DMP Metropolitan (ডিএমপি)', 'ডিএমপি ঢাকা'))),
                        DropdownMenuItem(value: 'PBI', child: Text(loc.tr('PBI Investigation (পিবিআই)', 'পিবিআই তদন্ত ব্যুরো'))),
                        DropdownMenuItem(value: 'RAB', child: Text(loc.tr('RAB Elite Force (র‍্যাব)', 'র‍্যাব এলিট ফোর্স'))),
                        DropdownMenuItem(value: 'Railway', child: Text(loc.tr('Railway Police (রেলওয়ে পুলিশ)', 'রেলওয়ে পুলিশ (জিআরপি)'))),
                        DropdownMenuItem(value: 'Highway', child: Text(loc.tr('Highway Police (হাইওয়ে পুলিশ)', 'হাইওয়ে পুলিশ'))),
                      ],
                      onChanged: (val) => setState(() => _agency = val),
                    ),

                    const SizedBox(height: 14),

                    // State / Division Dropdown
                    _fieldLabel(loc.tr('Division / Region (বিভাগ) *', 'বিভাগ (Division) *'), textSec),
                    DropdownButtonFormField<String>(
                      initialValue: _division,
                      decoration: InputDecoration(hintText: loc.tr('All Divisions (সকল বিভাগ)', 'সকল বিভাগ')),
                      dropdownColor: cardBg,
                      items: [
                        DropdownMenuItem(value: '', child: Text(loc.tr('All Divisions (সকল বিভাগ)', 'সকল বিভাগ'))),
                        ...AppConstants.divisions.map((d) => DropdownMenuItem(value: d, child: Text(d))),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _division = (val == '' ? null : val);
                          _district = null;
                        });
                      },
                    ),

                    const SizedBox(height: 14),

                    // District Dropdown
                    _fieldLabel(loc.tr('District / Metropolitan Area (জেলা) *', 'জেলা বা মেট্রোপলিটন এলাকা *'), textSec),
                    DropdownButtonFormField<String>(
                      key: ValueKey(_division),
                      initialValue: _district,
                      decoration: InputDecoration(hintText: loc.tr('All Districts (সকল জেলা)', 'সকল জেলা')),
                      dropdownColor: cardBg,
                      items: [
                        DropdownMenuItem(value: '', child: Text(loc.tr('All Districts (সকল জেলা)', 'সকল জেলা'))),
                        ..._currentDistricts.map((d) => DropdownMenuItem(value: d, child: Text(d))),
                      ],
                      onChanged: (val) {
                        setState(() => _district = (val == '' ? null : val));
                      },
                    ),

                    const SizedBox(height: 14),

                    // Police Station / Thana
                    _fieldLabel(loc.tr('Police Station (থানা)', 'থানা (Police Station)'), textSec),
                    TextField(
                      controller: _thanaController,
                      decoration: InputDecoration(
                        hintText: loc.tr('e.g. Paltan, Kotwali, Boalia, Panchlaish...', 'যেমন: পল্টন, কোতোয়ালী, বোয়ালিয়া, পাঁচলাইশ...'),
                        prefixIcon: const Icon(Icons.local_police_outlined, size: 18),
                      ),
                    ),

                    const SizedBox(height: 18),
                    const Divider(),
                    const SizedBox(height: 10),

                    // GD / FIR Inquest Date Range
                    _fieldLabel(loc.tr('GD / FIR Inquest Date Range (CrPC §174)', 'জিডি / এফআইআর সুরতহাল তারিখের সময়সীমা'), textSec),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _gdDateFromController,
                            decoration: InputDecoration(
                              hintText: 'From (YYYY-MM-DD)',
                              prefixIcon: const Icon(Icons.calendar_today_outlined, size: 16),
                              labelText: loc.tr('Date From', 'তারিখ হতে'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _gdDateToController,
                            decoration: InputDecoration(
                              hintText: 'To (YYYY-MM-DD)',
                              prefixIcon: const Icon(Icons.event_outlined, size: 16),
                              labelText: loc.tr('Date To', 'তারিখ পর্যন্ত'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Modal Footer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
                  border: Border(top: BorderSide(color: borderColor)),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
                ),
                child: Row(
                  children: [
                    OutlinedButton(
                      onPressed: _handleReset,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.red,
                        side: const BorderSide(color: AppColors.redBorder),
                      ),
                      child: Text(loc.tr('Reset', 'রিসেট')),
                    ),
                    const Spacer(),
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(loc.tr('Close', 'বন্ধ করুন')),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _handleFilter,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F2646),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: Text(loc.tr('Apply Filter', 'ফিল্টার প্রয়োগ করুন')),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.bold),
      ),
    );
  }
}
