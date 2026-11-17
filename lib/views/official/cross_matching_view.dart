import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive.dart';
import '../../models/udb_record.dart';
import '../../services/cross_matching_service.dart';
import '../../providers/udb_provider.dart';

class CrossMatchingView extends StatefulWidget {
  final ValueChanged<UdbRecord> onSelectRecord;

  const CrossMatchingView({super.key, required this.onSelectRecord});

  @override
  State<CrossMatchingView> createState() => _CrossMatchingViewState();
}

class _CrossMatchingViewState extends State<CrossMatchingView> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController(text: 'Md. Rafiqul Islam');
  final _gdController = TextEditingController(text: 'Ramna PS Missing GD No. 442/2026');
  final _thanaController = TextEditingController(text: 'Ramna');
  final _districtController = TextEditingController(text: 'Dhaka');
  String _gender = 'Male';
  final _ageController = TextEditingController(text: '28');
  final _heightController = TextEditingController(text: '170');
  final _marksController = TextEditingController(text: 'Cut mark above eyebrow, mole on cheek, steel ring');
  final _clothingController = TextEditingController(text: 'Blue check shirt, dark trousers, sandals');

  List<MatchScoreResult>? _results;
  bool _isAnalyzing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _gdController.dispose();
    _thanaController.dispose();
    _districtController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _marksController.dispose();
    _clothingController.dispose();
    super.dispose();
  }

  void _runCrossMatch() {
    if (_formKey.currentState?.validate() ?? false) {
      final allRecords = context.read<UdbProvider>().allRecords;
      setState(() => _isAnalyzing = true);

      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        final missing = MissingPersonProfile(
          fullName: _nameController.text.trim(),
          gdNumber: _gdController.text.trim(),
          thana: _thanaController.text.trim(),
          district: _districtController.text.trim(),
          gender: _gender,
          age: int.tryParse(_ageController.text.trim()) ?? 30,
          heightCm: int.tryParse(_heightController.text.trim()) ?? 170,
          distinguishingMarks: _marksController.text.trim(),
          lastSeenClothing: _clothingController.text.trim(),
          dateMissing: '2026-07-27',
        );

        final matches = CrossMatchingService.calculateMatches(
          missing: missing,
          records: allRecords,
        );

        setState(() {
          _results = matches;
          _isAnalyzing = false;
        });
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
        horizontal: isDesktop ? 48 : 16,
        vertical: 24,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner
              Container(
                padding: const EdgeInsets.all(20),
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
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.compare_arrows, color: AppColors.cyan, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Automated Missing Person vs Unidentified Deceased Cross-Matching Engine',
                            style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Algorithmic similarity scoring modeled on US NamUs and Interpol DVI Ante-Mortem (Yellow) to Post-Mortem (Pink) matching. '
                            'Input missing person parameters to rank potential matches across the national deceased database.',
                            style: TextStyle(color: textSec, fontSize: 12, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Two Columns on desktop: Input Form on left, Match Results on right
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: _buildInputForm(isLight, cardBg, borderColor, textPri)),
                    const SizedBox(width: 24),
                    Expanded(flex: 6, child: _buildResultsSection(isLight, cardBg, borderColor, textPri, textSec)),
                  ],
                )
              else ...[
                _buildInputForm(isLight, cardBg, borderColor, textPri),
                const SizedBox(height: 24),
                _buildResultsSection(isLight, cardBg, borderColor, textPri, textSec),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputForm(bool isLight, Color cardBg, Color borderColor, Color textPri) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person_search, color: AppColors.gold, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Ante-Mortem (Missing Person) Profile',
                  style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _nameController.text = 'Fatema Begum';
                      _gdController.text = 'Kotwali PS Missing GD 88/2026';
                      _thanaController.text = 'Kotwali';
                      _districtController.text = 'Chattogram';
                      _gender = 'Female';
                      _ageController.text = '42';
                      _heightController.text = '158';
                      _marksController.text = 'Burn scar on forearm, pierced ears, gold crown';
                      _clothingController.text = 'Maroon salwar kameez, black shawl, red glass bangles';
                    });
                  },
                  child: const Text('Load Demo Case 2', style: TextStyle(color: AppColors.cyan, fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Missing Person Name *'),
              validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _gdController,
                    decoration: const InputDecoration(labelText: 'Thana GD / FIR Reference *'),
                    validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _gender,
                    decoration: const InputDecoration(labelText: 'Biological Sex *'),
                    dropdownColor: AppColors.cardBg,
                    items: AppConstants.genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                    onChanged: (v) => setState(() => _gender = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Age (Years) *'),
                    validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Height (cm) *'),
                    validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _districtController,
                    decoration: const InputDecoration(labelText: 'Missing District *'),
                    validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _thanaController,
                    decoration: const InputDecoration(labelText: 'Police Station (Thana) *'),
                    validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _marksController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Distinguishing Marks, Scars, Tattoos *',
                hintText: 'e.g. Healed cut mark above eyebrow, surgical scar, mole, tattoo...',
              ),
              validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _clothingController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Last Seen Clothing & Effects *',
                hintText: 'e.g. Blue check shirt, rubber sandals, steel ring...',
              ),
              validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _runCrossMatch,
                icon: const Icon(Icons.bolt_rounded, size: 18),
                label: Text(_isAnalyzing ? 'Calculating Similarity Vectors...' : 'Execute Biometric & Descriptor Cross-Match'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection(bool isLight, Color cardBg, Color borderColor, Color textPri, Color textSec) {
    if (_isAnalyzing) {
      return Container(
        padding: const EdgeInsets.all(48),
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
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.gold),
              SizedBox(height: 16),
              Text(
                'Analyzing 24+ Interpol DVI records across 5 weighted vectors...',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    if (_results == null) {
      return Container(
        padding: const EdgeInsets.all(40),
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
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.hub_outlined, size: 48, color: AppColors.textMuted),
              const SizedBox(height: 12),
              Text(
                'No Cross-Match Executed Yet',
                style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                'Click "Execute Biometric & Descriptor Cross-Match" to evaluate similarity against the database.',
                textAlign: TextAlign.center,
                style: TextStyle(color: textSec, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_results!.length} Potential Matches Identified',
              style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Text(
              'Sorted by Algorithm Confidence %',
              style: TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _results!.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final res = _results![index];
            return _buildMatchResultCard(res, isLight, cardBg, borderColor, textPri, textSec);
          },
        ),
      ],
    );
  }

  Widget _buildMatchResultCard(MatchScoreResult res, bool isLight, Color cardBg, Color borderColor, Color textPri, Color textSec) {
    final record = res.record;
    final score = res.score.round();

    Color scoreColor = AppColors.green;
    if (score < 50) scoreColor = AppColors.amber;
    if (score < 40) scoreColor = AppColors.textMuted;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: score >= 70 ? AppColors.green.withValues(alpha: 0.6) : borderColor),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Score Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: scoreColor),
                ),
                child: Row(
                  children: [
                    Icon(Icons.bolt, color: scoreColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '$score% Match',
                      style: TextStyle(color: scoreColor, fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.referenceNo,
                      style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      'Found on ${record.dateFound} • ${record.thana}, ${record.district} (${record.placeFound})',
                      style: TextStyle(color: textSec, fontSize: 11),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => widget.onSelectRecord(record),
                icon: const Icon(Icons.open_in_new, size: 13),
                label: const Text('Open Dossier', style: TextStyle(fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Match Reasons
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isLight ? AppColors.slate50 : AppColors.darkSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isLight ? AppColors.slate200 : AppColors.darkBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Alignment Vectors:',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11),
                ),
                const SizedBox(height: 6),
                ...res.matchReasons.map(
                  (r) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(r, style: TextStyle(color: textPri, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
