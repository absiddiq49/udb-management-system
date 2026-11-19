import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/udb_record.dart';
import '../../services/cross_matching_service.dart';
import '../public/citizen_tip_dialog.dart';

class SideBySideMatchDialog extends StatelessWidget {
  final MissingPersonProfile missing;
  final MatchScoreResult matchResult;
  final ValueChanged<UdbRecord>? onOpenDossier;

  const SideBySideMatchDialog({
    super.key,
    required this.missing,
    required this.matchResult,
    this.onOpenDossier,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final record = matchResult.record;
    final cardBg = isDark ? AppColors.darkCardBg : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.slate900;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.slate600;

    return Dialog(
      backgroundColor: cardBg,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1040, maxHeight: 900),
        child: Column(
          children: [
            // Modal Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                border: Border(bottom: BorderSide(color: borderColor)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.compare_arrows_rounded,
                      color: AppColors.primary,
                      size: 22,
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
                              'Interpol DVI Forensic Cross-Match Inspection',
                              style: TextStyle(
                                color: textPri,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: matchResult.score >= 80
                                    ? AppColors.greenLight
                                    : AppColors.goldLight,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: matchResult.score >= 80
                                      ? AppColors.greenBorder
                                      : AppColors.goldBorder,
                                ),
                              ),
                              child: Text(
                                '${matchResult.score.toInt()}% MATCH • ${matchResult.confidenceLevel.toUpperCase()}',
                                style: TextStyle(
                                  color: matchResult.score >= 80
                                      ? AppColors.greenDark
                                      : AppColors.goldDark,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Ante-Mortem (Missing GD: ${missing.gdNumber}) vs Post-Mortem (${record.referenceNo})',
                          style: TextStyle(color: textSec, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: textSec),
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Close Comparison',
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Score Breakdown Visual Meter Strip
                    _buildScoreBreakdownStrip(
                      matchResult,
                      isDark,
                      textPri,
                      textSec,
                    ),

                    const SizedBox(height: 24),

                    // Side by Side Tables
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 700;
                        if (isWide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildAnteMortemColumn(
                                  missing,
                                  isDark,
                                  textPri,
                                  textSec,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildPostMortemColumn(
                                  record,
                                  isDark,
                                  textPri,
                                  textSec,
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              _buildAnteMortemColumn(
                                missing,
                                isDark,
                                textPri,
                                textSec,
                              ),
                              const SizedBox(height: 16),
                              _buildPostMortemColumn(
                                record,
                                isDark,
                                textPri,
                                textSec,
                              ),
                            ],
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 24),

                    // Transparent Match Reasons
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface
                            : AppColors.slate50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.fact_check_outlined,
                                color: AppColors.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Algorithmic Similarity Vectors & Transparent Audit Reasons',
                                style: TextStyle(
                                  color: textPri,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...matchResult.matchReasons.map(
                            (r) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline,
                                    color: AppColors.green,
                                    size: 15,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      r,
                                      style: TextStyle(
                                        color: textPri,
                                        fontSize: 12.5,
                                      ),
                                    ),
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
              ),
            ),

            // Footer Actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
                border: Border(top: BorderSide(color: borderColor)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Preparing Forensic Ante-Mortem vs Post-Mortem Comparison PDF...',
                          ),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    icon: const Icon(Icons.print_outlined, size: 15),
                    label: const Text('Print Comparison Sheet'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textSec,
                      side: BorderSide(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.slate300,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => CitizenTipDialog(
                              bodyReference: record.referenceNo,
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.record_voice_over_outlined,
                          size: 15,
                        ),
                        label: const Text('Submit Relative Match Claim'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          if (onOpenDossier != null) {
                            onOpenDossier!(record);
                          }
                        },
                        icon: const Icon(
                          Icons.folder_shared_outlined,
                          size: 15,
                        ),
                        label: const Text('Open Dead Body Dossier'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBreakdownStrip(
    MatchScoreResult res,
    bool isDark,
    Color textPri,
    Color textSec,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '5-Vector Interpol Scoring Breakdown',
                style: TextStyle(
                  color: textPri,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                ),
              ),
              Text(
                'Total Score: ${res.score.toInt()} / 100 Points',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _vectorProgress('Sex Align', res.sexScore, 30, AppColors.blue),
              _vectorProgress(
                'Age Proximity',
                res.ageScore,
                25,
                AppColors.green,
              ),
              _vectorProgress(
                'Stature (Height)',
                res.heightScore,
                20,
                AppColors.cyan,
              ),
              _vectorProgress(
                'District Jurisdiction',
                res.districtScore,
                10,
                AppColors.gold,
              ),
              _vectorProgress(
                'Marks & Clothing',
                res.keywordScore,
                15,
                AppColors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _vectorProgress(String label, double val, double max, Color color) {
    final pct = (val / max).clamp(0.0, 1.0);
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${val.toInt()}/${max.toInt()}',
                style: TextStyle(
                  fontSize: 10.5,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 5,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnteMortemColumn(
    MissingPersonProfile missing,
    bool isDark,
    Color textPri,
    Color textSec,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.goldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.goldLight,
              borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.person_search,
                  color: AppColors.goldDark,
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Text(
                  'ANTE-MORTEM (Yellow Form: Missing Person)',
                  style: TextStyle(
                    color: AppColors.goldDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _specRow('Full Name', missing.fullName, textSec, textPri),
                _specRow('GD / FIR Ref', missing.gdNumber, textSec, textPri),
                _specRow('Biological Sex', missing.gender, textSec, textPri),
                _specRow(
                  'Age at Missing',
                  '${missing.age} Years',
                  textSec,
                  textPri,
                ),
                _specRow(
                  'Height / Stature',
                  '${missing.heightCm} cm',
                  textSec,
                  textPri,
                ),
                _specRow(
                  'Location Missing',
                  '${missing.thana}, ${missing.district}',
                  textSec,
                  textPri,
                ),
                _specRow(
                  'Distinguishing Marks',
                  missing.distinguishingMarks,
                  textSec,
                  textPri,
                ),
                _specRow(
                  'Last Seen Clothing',
                  missing.lastSeenClothing,
                  textSec,
                  textPri,
                ),
                _specRow(
                  'Date Reported Missing',
                  missing.dateMissing,
                  textSec,
                  textPri,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostMortemColumn(
    UdbRecord record,
    bool isDark,
    Color textPri,
    Color textSec,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.biotech_outlined,
                  color: AppColors.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Text(
                  'POST-MORTEM (Pink Form: Dead Body Dossier)',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _specRow(
                  'Case Reference',
                  record.referenceNo,
                  textSec,
                  textPri,
                ),
                _specRow(
                  'Police Inquest Ref',
                  record.gdCaseReference,
                  textSec,
                  textPri,
                ),
                _specRow('Biological Sex', record.gender, textSec, textPri),
                _specRow(
                  'Estimated Age',
                  '~${record.estimatedAge} Years (${record.ageGroup})',
                  textSec,
                  textPri,
                ),
                _specRow(
                  'Height / Stature',
                  '${record.heightCm} cm',
                  textSec,
                  textPri,
                ),
                _specRow(
                  'Recovery Location',
                  '${record.thana}, ${record.district}',
                  textSec,
                  textPri,
                ),
                _specRow(
                  'Identified Marks',
                  record.identificationMarks,
                  textSec,
                  textPri,
                ),
                _specRow(
                  'Recovered Clothing',
                  record.clothing,
                  textSec,
                  textPri,
                ),
                _specRow('Date Discovered', record.dateFound, textSec, textPri),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _specRow(String label, String value, Color textSec, Color textPri) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                color: textSec,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Not recorded',
              style: TextStyle(color: textPri, fontSize: 12, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
