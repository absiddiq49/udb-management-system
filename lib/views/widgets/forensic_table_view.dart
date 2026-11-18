import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/udb_record.dart';
import '../../providers/locale_provider.dart';
import '../public/citizen_tip_dialog.dart';
import 'gazette_notice_dialog.dart';
import 'sensitive_image_card.dart';

class ForensicTableView extends StatefulWidget {
  final List<UdbRecord> records;
  final ValueChanged<UdbRecord> onSelectRecord;

  const ForensicTableView({
    super.key,
    required this.records,
    required this.onSelectRecord,
  });

  @override
  State<ForensicTableView> createState() => _ForensicTableViewState();
}

class _ForensicTableViewState extends State<ForensicTableView> {
  final Set<String> _expandedIds = {};

  void _toggleExpand(String id) {
    setState(() {
      if (_expandedIds.contains(id)) {
        _expandedIds.remove(id);
      } else {
        _expandedIds.add(id);
      }
    });
  }

  void _toggleAll() {
    setState(() {
      if (_expandedIds.length == widget.records.length) {
        _expandedIds.clear();
      } else {
        _expandedIds.addAll(widget.records.map((r) => r.id));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCardBg : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1);
    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.slate900;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.slate600;
    final textMut = isDark ? AppColors.darkTextMuted : AppColors.slate400;
    final headerBg = isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9);

    final allExpanded = widget.records.isNotEmpty && _expandedIds.length == widget.records.length;

    return Container(
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Table Control Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            color: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: AppColors.primaryBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.table_rows_rounded, size: 14, color: AppColors.primary),
                      const SizedBox(width: 5),
                      Text(
                        loc.tr('UDBMS REGISTRY VIEW', 'ইউডিবিএমএস ডাটাবেজ ভিউ'),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    loc.tr(
                      'National Unidentified Deceased Register • CrPC §174 Inquests & Forensic Profiles',
                      'জাতীয় অজ্ঞাত মৃতদেহ রেজিস্ট্রি • ফৌজদারি কার্যবিধি ১৭৪ ধারা সুরতহাল ও ফরেনসিক প্রোফাইল',
                    ),
                    style: TextStyle(color: textPri, fontSize: 11.5, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton.icon(
                  onPressed: _toggleAll,
                  icon: Icon(
                    allExpanded ? Icons.unfold_less_rounded : Icons.unfold_more_rounded,
                    size: 16,
                    color: const Color(0xFF0F2646),
                  ),
                  label: Text(
                    allExpanded
                        ? loc.tr('Collapse All', 'সবগুলো সংক্ষেপ করুন')
                        : loc.tr('Expand All (+)', 'সবগুলো বিস্তারিত দেখুন (+)'),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F2646)),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1),

          // Scrollable Table Body
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 1080),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Table Header Row
                  Container(
                    color: headerBg,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        _colHeader('', 36, textPri),
                        _colHeader(loc.tr('PHOTO', 'ছবি'), 65, textPri),
                        _colHeader(loc.tr('CASE REF & GD', 'জিডি ও সিআইবি নং'), 150, textPri),
                        _colHeader(loc.tr('RECOVERY DATE', 'উদ্ধারের তারিখ'), 140, textPri),
                        _colHeader(loc.tr('THANA / DISTRICT', 'থানা ও জেলা'), 170, textPri),
                        _colHeader(loc.tr('AGE & BUILD', 'বয়স ও শারীরিক গড়ন'), 150, textPri),
                        _colHeader(loc.tr('MARKS & CLOTHING', 'চিহ্ন ও পোশাক'), 170, textPri),
                        _colHeader(loc.tr('BIOMETRICS', 'বায়োমেট্রিক'), 100, textPri),
                        _colHeader(loc.tr('STATUS', 'স্ট্যাটাস'), 110, textPri),
                        _colHeader(loc.tr('ACTIONS', 'অ্যাকশন'), 110, textPri),
                      ],
                    ),
                  ),

                  const Divider(height: 1, thickness: 1),

                  // Data Rows + Inline Expandable Details
                  ...widget.records.map((record) {
                    final isExpanded = _expandedIds.contains(record.id);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main Summary Row
                        InkWell(
                          onTap: () => _toggleExpand(record.id),
                          hoverColor: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isExpanded
                                  ? (isDark ? AppColors.primary.withValues(alpha: 0.08) : const Color(0xFFF0F7FF))
                                  : null,
                              border: Border(
                                bottom: BorderSide(
                                  color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
                                  width: 0.8,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Expand Icon Button
                                SizedBox(
                                  width: 36,
                                  child: Center(
                                    child: IconButton(
                                      icon: Icon(
                                        isExpanded ? Icons.remove_circle : Icons.add_circle,
                                        size: 19,
                                        color: isExpanded ? const Color(0xFF0F2646) : AppColors.slate500,
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      tooltip: isExpanded
                                          ? loc.tr('Hide Details', 'সংক্ষেপ করুন')
                                          : loc.tr('Expand Details', 'বিস্তারিত দেখুন'),
                                      onPressed: () => _toggleExpand(record.id),
                                    ),
                                  ),
                                ),

                                // Photo Thumbnail
                                SizedBox(
                                  width: 65,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Container(
                                        width: 46,
                                        height: 46,
                                        color: isDark ? AppColors.darkSurface : AppColors.slate200,
                                        child: record.primaryPhoto != null
                                            ? SensitiveImageCard(
                                                imageUrl: record.primaryPhoto!.previewUrl,
                                                initialBlur: true,
                                                height: 46,
                                                width: 46,
                                                borderRadius: BorderRadius.circular(6),
                                              )
                                            : Center(
                                                child: Text(
                                                  record.gender.isNotEmpty ? record.gender[0].toUpperCase() : 'U',
                                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),

                                // UIDB Reference & GD No
                                SizedBox(
                                  width: 150,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        record.referenceNo,
                                        style: const TextStyle(
                                          color: Color(0xFF0F2646),
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        record.gdCaseReference.isNotEmpty ? record.gdCaseReference : 'GD Pending',
                                        style: TextStyle(color: textSec, fontSize: 10.5),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),

                                // Recovery Date & Time
                                SizedBox(
                                  width: 140,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today_outlined, size: 11, color: AppColors.slate400),
                                          const SizedBox(width: 4),
                                          Text(
                                            record.dateFound,
                                            style: TextStyle(color: textPri, fontWeight: FontWeight.w600, fontSize: 11.5),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(record.timeFound, style: TextStyle(color: textMut, fontSize: 10)),
                                    ],
                                  ),
                                ),

                                // Jurisdiction / Spot
                                SizedBox(
                                  width: 170,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${record.thana}, ${record.district}',
                                        style: TextStyle(color: textPri, fontWeight: FontWeight.w600, fontSize: 11.5),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        record.placeFound.isNotEmpty ? record.placeFound : record.division,
                                        style: TextStyle(color: textSec, fontSize: 10.5),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),

                                // Anthropometry (Age, Gender, Height, Weight)
                                SizedBox(
                                  width: 150,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Wrap(
                                        spacing: 5,
                                        runSpacing: 2,
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              record.gender.toUpperCase(),
                                              style: const TextStyle(color: Color(0xFF1E3A8A), fontSize: 9.0, fontWeight: FontWeight.w800),
                                            ),
                                          ),
                                          Text('~${record.estimatedAge} yrs', style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 11.5)),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${record.heightCm} cm • ${record.weightKg} kg',
                                        style: TextStyle(color: textSec, fontSize: 10.5),
                                      ),
                                    ],
                                  ),
                                ),

                                // Marks & Clothing
                                SizedBox(
                                  width: 170,
                                  child: Text(
                                    record.identificationMarks.isNotEmpty ? record.identificationMarks : record.clothing,
                                    style: TextStyle(color: textPri, fontSize: 11, height: 1.3),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                // Biometrics
                                SizedBox(
                                  width: 100,
                                  child: Wrap(
                                    spacing: 3,
                                    runSpacing: 2,
                                    children: [
                                      if (record.hasDna)
                                        _badge('DNA', AppColors.purple, AppColors.purpleLight),
                                      if (record.hasFingerprint)
                                        _badge('AFIS', AppColors.cyan, AppColors.cyanLight),
                                      if (record.documents.any((d) => d.type == 'inquest_report'))
                                        _badge('§174 INQ', AppColors.blue, AppColors.blueLight),
                                    ],
                                  ),
                                ),

                                // Status
                                SizedBox(
                                  width: 110,
                                  child: _statusBadge(record.status),
                                ),

                                // Quick Actions
                                SizedBox(
                                  width: 110,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Tooltip(
                                        message: loc.tr('Open Dossier', 'পূর্ণাঙ্গ নথি'),
                                        child: InkWell(
                                          onTap: () => widget.onSelectRecord(record),
                                          borderRadius: BorderRadius.circular(4),
                                          child: const Padding(
                                            padding: EdgeInsets.all(4),
                                            child: Icon(Icons.folder_open_rounded, size: 16, color: Color(0xFF0F2646)),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Tooltip(
                                        message: loc.tr('Print Gazette Poster', 'গেজেট পোস্টার মুদ্রণ'),
                                        child: InkWell(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (_) => GazetteNoticeDialog(record: record),
                                            );
                                          },
                                          borderRadius: BorderRadius.circular(4),
                                          child: const Padding(
                                            padding: EdgeInsets.all(4),
                                            child: Icon(Icons.print_outlined, size: 16, color: AppColors.goldDark),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Tooltip(
                                        message: loc.tr('Submit Lead / Tip', 'নাগরিক তথ্য প্রদান'),
                                        child: InkWell(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (_) => CitizenTipDialog(bodyReference: record.referenceNo),
                                            );
                                          },
                                          borderRadius: BorderRadius.circular(4),
                                          child: const Padding(
                                            padding: EdgeInsets.all(4),
                                            child: Icon(Icons.record_voice_over_outlined, size: 16, color: AppColors.green),
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

                        // In-Line Expanded Accordion Details (UDBMS Full Inquest & Traits)
                        if (isExpanded)
                          _buildExpandedDetailPanel(record, isDark, textPri, textSec, textMut, borderColor, loc),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _colHeader(String title, double width, Color textColor) {
    return SizedBox(
      width: width,
      child: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildExpandedDetailPanel(
    UdbRecord record,
    bool isDark,
    Color textPri,
    Color textSec,
    Color textMut,
    Color borderColor,
    LocaleProvider loc,
  ) {
    final panelBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardInnerBg = isDark ? AppColors.darkCardBg : Colors.white;

    return Container(
      width: 1080,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: panelBg,
        border: Border(
          bottom: BorderSide(color: const Color(0xFF0F2646).withValues(alpha: 0.3), width: 1.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo Evidence Stack
          Container(
            width: 160,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cardInnerBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (record.primaryPhoto != null)
                  SensitiveImageCard(
                    imageUrl: record.primaryPhoto!.previewUrl,
                    caption: record.primaryPhoto!.caption,
                    initialBlur: true,
                    height: 120,
                    width: 140,
                    borderRadius: BorderRadius.circular(6),
                  )
                else
                  Container(
                    height: 120,
                    width: 140,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.slate100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_outline, size: 36, color: textMut),
                          const SizedBox(height: 4),
                          Text(loc.tr('No Photo', 'ছবি নেই'), style: TextStyle(color: textMut, fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  loc.tr(
                    '${record.photos.length} Forensic Photos',
                    '${record.photos.length}টি সংরক্ষিত ছবি',
                  ),
                  style: TextStyle(color: textSec, fontSize: 10.5, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Central Descriptive Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Jurisdiction Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      loc.tr(
                        'Forensic Physical Traits & Discovery Particulars (উদ্ধার ও শারীরিক তথ্যাবলি)',
                        'সুরতহাল বিবরণ, উদ্ধার ও ফরেনসিক তথ্যাবলি (PRB Rule 299-303)',
                      ),
                      style: TextStyle(color: textPri, fontWeight: FontWeight.bold, fontSize: 12.5),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.greenLight,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: AppColors.greenBorder),
                      ),
                      child: Text(
                        'Jurisdiction: ${record.thana} PS, ${record.district}',
                        style: const TextStyle(color: AppColors.greenDark, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Grid of Attributes
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardInnerBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _field(
                              loc.tr('Exact Spot Found (উদ্ধারের স্থান)', 'উদ্ধারের স্থান ও দাগ নং'),
                              record.placeFound.isNotEmpty ? record.placeFound : record.locationFound,
                              textPri,
                              textSec,
                            ),
                          ),
                          Expanded(
                            child: _field(
                              loc.tr('Recovery Date & Time', 'উদ্ধারের তারিখ ও সময়'),
                              '${record.dateFound} at ${record.timeFound}',
                              textPri,
                              textSec,
                            ),
                          ),
                          Expanded(
                            child: _field(
                              loc.tr('Inquest & GD Reference', 'সুরতহাল ও জিডি নম্বর'),
                              '${record.gdCaseReference} (CrPC §174)',
                              textPri,
                              textSec,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _field(
                              loc.tr('Estimated Age & Gender', 'আনুমানিক বয়স ও লিঙ্গ'),
                              '${record.estimatedAge} Years • ${record.gender}',
                              textPri,
                              textSec,
                            ),
                          ),
                          Expanded(
                            child: _field(
                              loc.tr('Height & Weight', 'উচ্চতা ও ওজন'),
                              '${record.heightCm} cm (~${(record.heightCm / 30.48).toStringAsFixed(1)} ft) • ${record.weightKg} kg',
                              textPri,
                              textSec,
                            ),
                          ),
                          Expanded(
                            child: _field(
                              loc.tr('Complexion & Hair', 'গায়ের রং ও চুল'),
                              '${record.complexion.isNotEmpty ? record.complexion : "Unspecified"} • ${record.hair}',
                              textPri,
                              textSec,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _field(
                              loc.tr('Clothing Worn (পরিহিত পোশাক)', 'পরিহিত পোশাকের পূর্ণ বিবরণ'),
                              record.clothing.isNotEmpty ? record.clothing : 'No clothes cataloged',
                              textPri,
                              textSec,
                            ),
                          ),
                          Expanded(
                            child: _field(
                              loc.tr('Personal Belongings (উদ্ধারকৃত সামগ্রী)', 'উদ্ধারকৃত সামগ্রী ও আলামত'),
                              record.personalBelongings.isNotEmpty ? record.personalBelongings : 'None recovered',
                              textPri,
                              textSec,
                            ),
                          ),
                          Expanded(
                            child: _field(
                              loc.tr('Marks, Tattoos & Scars (দাগ ও চিহ্ন)', 'শনাক্তকারী স্থায়ী দাগ, ট্যাটু ও ক্ষত'),
                              record.identificationMarks.isNotEmpty ? record.identificationMarks : 'No distinct marks cataloged',
                              textPri,
                              textSec,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _field(
                              loc.tr('DNA Laboratory Status', 'ডিএনএ ল্যাবরেটরি স্ট্যাটাস (সিআইডি মালিবাগ)'),
                              record.hasDna ? 'DNA Profile Archived & Ready for Kinship Testing' : 'DNA Sampling in Progress',
                              textPri,
                              textSec,
                            ),
                          ),
                          Expanded(
                            child: _field(
                              loc.tr('AFIS Fingerprint Slip (EC NID)', 'আঙ্গুলের ছাপ (জাতীয় পরিচয়পত্র এনআইডি ম্যাচিং)'),
                              record.hasFingerprint ? '10-Print Digital Card Archived (AFIS Ready)' : 'No readable fingerprint (Decomposed)',
                              textPri,
                              textSec,
                            ),
                          ),
                          Expanded(
                            child: _field(
                              loc.tr('Anjuman Burial / Custody Ref', 'আঞ্জুমান মফিদুল ইসলাম দাফন রেফারেন্স'),
                              'AMI-REG-${record.id.replaceAll(RegExp(r"[^0-9]"), "")}-PLOT-BD',
                              textPri,
                              textSec,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Action Bar (Open Dossier, Print Gazette, Submit Tip)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => widget.onSelectRecord(record),
                      icon: const Icon(Icons.folder_open_rounded, size: 14),
                      label: Text(loc.tr('Open Dossier (পূর্ণাঙ্গ নথি)', 'পূর্ণাঙ্গ কেস ডসিয়ার')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: textPri,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => GazetteNoticeDialog(record: record),
                        );
                      },
                      icon: const Icon(Icons.print_rounded, size: 14, color: AppColors.goldDark),
                      label: Text(loc.tr('Print Gazette Poster (গেজেট পোস্টার)', 'গেজেট নোটিশ পোস্টার')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.goldDark,
                        side: const BorderSide(color: AppColors.goldBorder),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => CitizenTipDialog(bodyReference: record.referenceNo),
                        );
                      },
                      icon: const Icon(Icons.record_voice_over_rounded, size: 14),
                      label: Text(loc.tr('Submit Lead / Tip (তথ্য দিন)', 'নাগরিক তথ্য প্রদান')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F2646),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, String value, Color textPri, Color textSec) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: textSec, fontSize: 9.5, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 3),
        Text(
          value.isNotEmpty ? value : '—',
          style: TextStyle(color: textPri, fontSize: 11, fontWeight: FontWeight.w600),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _badge(String text, Color fg, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: TextStyle(color: fg, fontSize: 9.0, fontWeight: FontWeight.bold)),
    );
  }

  Widget _statusBadge(String status) {
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
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(
        status.split('-').last.trim(),
        style: TextStyle(color: fg, fontSize: 9.0, fontWeight: FontWeight.w700),
      ),
    );
  }
}
