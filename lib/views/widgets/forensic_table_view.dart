import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/udb_record.dart';
import 'gazette_notice_dialog.dart';

class ForensicTableView extends StatelessWidget {
  final List<UdbRecord> records;
  final ValueChanged<UdbRecord> onSelectRecord;

  const ForensicTableView({
    super.key,
    required this.records,
    required this.onSelectRecord,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCardBg : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.slate900;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.slate600;
    final headerBg = isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 980),
          child: DataTable(
            headingRowColor: WidgetStatePropertyAll(headerBg),
            dataRowMaxHeight: 68,
            dataRowMinHeight: 56,
            columnSpacing: 20,
            horizontalMargin: 20,
            columns: [
              DataColumn(label: Text('CASE REFERENCE', style: _headerStyle(textPri))),
              DataColumn(label: Text('RECOVERY DATE', style: _headerStyle(textPri))),
              DataColumn(label: Text('LOCATION / JURISDICTION', style: _headerStyle(textPri))),
              DataColumn(label: Text('ANTHROPOLOGY', style: _headerStyle(textPri))),
              DataColumn(label: Text('MARKS & CLOTHING', style: _headerStyle(textPri))),
              DataColumn(label: Text('BIOMETRICS', style: _headerStyle(textPri))),
              DataColumn(label: Text('STATUS', style: _headerStyle(textPri))),
              DataColumn(label: Text('ACTIONS', style: _headerStyle(textPri))),
            ],
            rows: records.map((r) {
              return DataRow(
                cells: [
                  // Case Reference
                  DataCell(
                    InkWell(
                      onTap: () => onSelectRecord(r),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.referenceNo,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            r.gdCaseReference,
                            style: TextStyle(color: textSec, fontSize: 10.5),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Recovery Date
                  DataCell(
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.dateFound, style: TextStyle(color: textPri, fontWeight: FontWeight.w600, fontSize: 12)),
                        Text(r.timeFound, style: TextStyle(color: textSec, fontSize: 10.5)),
                      ],
                    ),
                  ),

                  // Location
                  DataCell(
                    SizedBox(
                      width: 150,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${r.thana}, ${r.district}', style: TextStyle(color: textPri, fontWeight: FontWeight.w600, fontSize: 12), overflow: TextOverflow.ellipsis),
                          Text(r.division, style: TextStyle(color: textSec, fontSize: 10.5)),
                        ],
                      ),
                    ),
                  ),

                  // Anthropology (Sex, Age, Height)
                  DataCell(
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                r.gender,
                                style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text('~${r.estimatedAge} yrs', style: TextStyle(color: textPri, fontSize: 11.5, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text('${r.heightCm} cm • ${r.weightKg} kg', style: TextStyle(color: textSec, fontSize: 11)),
                      ],
                    ),
                  ),

                  // Marks & Clothing
                  DataCell(
                    SizedBox(
                      width: 200,
                      child: Text(
                        '${r.identificationMarks} | ${r.clothing}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: textPri, fontSize: 11.5, height: 1.3),
                      ),
                    ),
                  ),

                  // Biometrics
                  DataCell(
                    Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      children: [
                        if (r.hasDna)
                          _miniBadge('DNA', AppColors.purple, AppColors.purpleLight),
                        if (r.hasFingerprint)
                          _miniBadge('AFIS', AppColors.cyan, AppColors.cyanLight),
                        if (r.documents.any((d) => d.type == 'inquest_report'))
                          _miniBadge('INQ', AppColors.blue, AppColors.blueLight),
                      ],
                    ),
                  ),

                  // Status
                  DataCell(_buildStatusBadge(r.status)),

                  // Actions
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.open_in_new, size: 17, color: AppColors.primary),
                          tooltip: 'Open Dossier',
                          onPressed: () => onSelectRecord(r),
                        ),
                        IconButton(
                          icon: const Icon(Icons.menu_book_outlined, size: 17, color: AppColors.gold),
                          tooltip: 'Police Gazette Notice',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => GazetteNoticeDialog(record: r),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  TextStyle _headerStyle(Color color) {
    return TextStyle(
      color: color,
      fontSize: 10.5,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.6,
    );
  }

  Widget _miniBadge(String text, Color fg, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontSize: 9.5, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = const Color(0xFFF1F5F9);
    Color fg = AppColors.slate700;

    final lower = status.toLowerCase();
    if (lower.contains('active') || lower.contains('probable')) {
      bg = AppColors.greenLight;
      fg = AppColors.green;
    } else if (lower.contains('verification') || lower.contains('pending')) {
      bg = AppColors.goldLight;
      fg = AppColors.goldDark;
    } else if (lower.contains('dna')) {
      bg = AppColors.purpleLight;
      fg = AppColors.purple;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        status.split('-').last.trim(),
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }
}
