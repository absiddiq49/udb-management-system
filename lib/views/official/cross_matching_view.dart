import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive.dart';
import '../../models/udb_record.dart';
import '../../services/cross_matching_service.dart';
import '../../providers/udb_provider.dart';
import '../widgets/side_by_side_match_dialog.dart';
import '../public/citizen_tip_dialog.dart';

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
  MissingPersonProfile? _currentMissingProfile;

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

  void _loadPreset(MissingPersonProfile p) {
    setState(() {
      _nameController.text = p.fullName;
      _gdController.text = p.gdNumber;
      _thanaController.text = p.thana;
      _districtController.text = p.district;
      _gender = p.gender;
      _ageController.text = p.age.toString();
      _heightController.text = p.heightCm.toString();
      _marksController.text = p.distinguishingMarks;
      _clothingController.text = p.lastSeenClothing;
    });
    _runCrossMatch();
  }

  void _runCrossMatch() {
    if (_formKey.currentState?.validate() ?? false) {
      final allRecords = context.read<UdbProvider>().allRecords;
      setState(() => _isAnalyzing = true);

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

      _currentMissingProfile = missing;

      Future.delayed(const Duration(milliseconds: 350), () {
        if (!mounted) return;
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
    final samplePresets = CrossMatchingService.sampleProfiles;

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
              ],
            ),
            const SizedBox(height: 10),

            // Quick Preset Selection Strip
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isLight ? AppColors.slate100 : AppColors.darkSurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.bolt, size: 14, color: AppColors.gold),
                      SizedBox(width: 4),
                      Text('Quick Test Presets (Load & Auto-Match):', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _loadPreset(samplePresets[0]),
                        icon: const Icon(Icons.male, size: 14, color: AppColors.primary),
                        label: const Text('Preset 1: Dhaka (Male, 28y)', style: TextStyle(fontSize: 11)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          backgroundColor: isLight ? Colors.white : AppColors.darkCardBg,
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _loadPreset(samplePresets[1]),
                        icon: const Icon(Icons.female, size: 14, color: AppColors.goldDark),
                        label: const Text('Preset 2: Ctg (Female, 42y)', style: TextStyle(fontSize: 11)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          backgroundColor: isLight ? Colors.white : AppColors.darkCardBg,
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _loadPreset(samplePresets[2]),
                        icon: const Icon(Icons.help_outline, size: 14, color: AppColors.cyan),
                        label: const Text('Preset 3: Sylhet (Youth, 18y)', style: TextStyle(fontSize: 11)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          backgroundColor: isLight ? Colors.white : AppColors.darkCardBg,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
                    dropdownColor: cardBg,
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
    if (score < 70) scoreColor = AppColors.gold;
    if (score < 45) scoreColor = AppColors.slate500;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: score >= 70 ? AppColors.green.withValues(alpha: 0.6) : borderColor, width: score >= 70 ? 1.5 : 1),
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
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: scoreColor),
                ),
                child: Row(
                  children: [
                    Icon(Icons.bolt, color: scoreColor, size: 16),
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
                    Row(
                      children: [
                        Text(
                          record.referenceNo,
                          style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            res.confidenceLevel.toUpperCase(),
                            style: const TextStyle(color: AppColors.primary, fontSize: 9.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Found on ${record.dateFound} at ${record.thana}, ${record.district} (${record.placeFound})',
                      style: TextStyle(color: textSec, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Vector Scoring Breakdown Bars
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isLight ? AppColors.slate100 : AppColors.darkSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(child: _miniBar('Sex', res.sexScore, 30, AppColors.blue, textSec)),
                const SizedBox(width: 8),
                Expanded(child: _miniBar('Age', res.ageScore, 25, AppColors.green, textSec)),
                const SizedBox(width: 8),
                Expanded(child: _miniBar('Height', res.heightScore, 20, AppColors.cyan, textSec)),
                const SizedBox(width: 8),
                Expanded(child: _miniBar('Region', res.districtScore, 10, AppColors.gold, textSec)),
                const SizedBox(width: 8),
                Expanded(child: _miniBar('Markers', res.keywordScore, 15, AppColors.purple, textSec)),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Match Reasons List
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
                  'Algorithm Alignment Breakdown:',
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
                          child: Text(r, style: TextStyle(color: textPri, fontSize: 11.5)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Actions Row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => CitizenTipDialog(bodyReference: record.referenceNo),
                  );
                },
                icon: const Icon(Icons.record_voice_over_outlined, size: 13),
                label: const Text('Submit Relative Lead', style: TextStyle(fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.goldDark,
                  side: const BorderSide(color: AppColors.goldBorder),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  if (_currentMissingProfile != null) {
                    showDialog(
                      context: context,
                      builder: (_) => SideBySideMatchDialog(
                        missing: _currentMissingProfile!,
                        matchResult: res,
                        onOpenDossier: widget.onSelectRecord,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.compare_arrows_rounded, size: 14),
                label: const Text('Interpol DVI Side-by-Side Compare', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldLight,
                  foregroundColor: AppColors.goldDark,
                  side: const BorderSide(color: AppColors.goldBorder),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => widget.onSelectRecord(record),
                icon: const Icon(Icons.open_in_new, size: 13),
                label: const Text('Open Dossier', style: TextStyle(fontSize: 11)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniBar(String title, double val, double max, Color color, Color textSec) {
    final pct = (val / max).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: textSec, fontSize: 9.5, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 4,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
