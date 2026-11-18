import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/link_service.dart';
import '../../models/udb_record.dart';
import 'contact_action_pill.dart';

class GazetteNoticeDialog extends StatelessWidget {
  final UdbRecord record;

  const GazetteNoticeDialog({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkCardBg : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860, maxHeight: 900),
        child: Column(
          children: [
            // Action Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCardBg : const Color(0xFFF8FAFC),
                border: Border(bottom: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.menu_book, color: AppColors.gold, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'OFFICIAL POLICE GAZETTE NOTIFICATION (পুলিশ গেজেট বিজ্ঞপ্তি)',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.slate900,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.print_outlined, color: isDark ? AppColors.goldBright : AppColors.primary, size: 20),
                    tooltip: 'Print Official Gazette Notice',
                    onPressed: () {
                      LinkService.printPage();
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: isDark ? AppColors.darkTextSecondary : AppColors.slate500, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Scrollable Gazette Document Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Official Government Header
                    Image.asset(
                      'assets/images/cid-logo-blue.png',
                      height: 72,
                      errorBuilder: (_, _, _) => const Icon(Icons.shield_outlined, size: 60, color: AppColors.primary),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'গণপ্রজাতন্ত্রী বাংলাদেশ সরকার',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Text(
                      'বাংলাদেশ পুলিশ • ক্রিমিনাল ইনভেস্টিগেশন ডিপার্টমেন্ট (সিআইডি)',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const Text(
                      'সেন্ট্রাল ইন্টেলিজেন্স ব্যুরো (সিআইবি) • প্রধান কার্যালয়, ঢাকা',
                      style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.goldLight,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.gold),
                      ),
                      child: const Text(
                        'বিশেষ গেজেট বিজ্ঞপ্তি: অজ্ঞাতনামা মৃতদেহ সনাক্তকরণ বিজ্ঞপ্তি\n'
                        'SPECIAL POLICE GAZETTE: UNIDENTIFIED DECEASED IDENTIFICATION NOTICE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.goldDark,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Legal Mandate Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkInputBg : AppColors.lightInputBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('গেজেট রেফারেন্স / Gazette Ref: GAZ-${record.referenceNo}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                const SizedBox(height: 2),
                                Text('আইনি ভিত্তি: ফৌজদারি কার্যবিধি (CrPC) ধারা ১৭৪ এবং পিআরবি প্রবিধান ২৯৯/৩০০', style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary, fontSize: 11)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.greenLight,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.green),
                            ),
                            child: const Text('PUBLIC GAZETTE', style: TextStyle(color: AppColors.greenDark, fontWeight: FontWeight.bold, fontSize: 10)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Gazette Notice Body Description
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'এতদ্বারা সর্বসাধারণের অবগতির জন্য জানানো যাচ্ছে যে, নিম্নবর্ণিত বিবরণ মোতাবেক একটি অজ্ঞাতনামা মৃতদেহ উদ্ধার করা হয়েছে। '
                        'উক্ত মৃতদেহটির পরিচয় নিশ্চিতকরণের জন্য নিম্নোক্ত শারীরিক ও পোশাকীয় বিবরণ পুলিশ গেজেটে প্রকাশ করা হলো:',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Gazette Descriptive Table
                    _buildGazetteTable(isDark),

                    const SizedBox(height: 24),

                    // Public Appeal Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.redLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.red),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.campaign, color: AppColors.redDark, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'জনসাধারণের জন্য জরুরি নোটিশ / Public Appeal',
                                style: TextStyle(color: AppColors.redDark, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'যদি কোনো নাগরিক বা আত্মীয়-স্বজন উপরোক্ত শারীরিক বিবরণ, চিহ্ন বা পোশাকের ভিত্তিতে মৃত ব্যক্তিকে চিনতে পারেন, '
                            'তবে অবিলম্বে উদ্ধারকারী কর্মকর্তা অথবা সিআইডি সেন্ট্রাল ইন্টেলিজেন্স ব্যুরো (CIB) হেল্পলাইনে যোগাযোগ করার অনুরোধ করা হচ্ছে।',
                            style: TextStyle(color: AppColors.redDark, fontSize: 12, height: 1.4),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              const ContactActionPill.phone(
                                label: 'কল করুন: ৯৯৯ (জরুরি ২৪/৭)',
                                target: '999',
                                isEmergency: true,
                              ),
                              ContactActionPill.phone(
                                label: 'সিআইডি সিআইবি হেল্পলাইন: ${AppConstants.cidHelpline}',
                                target: AppConstants.cidHelpline,
                              ),
                              ContactActionPill.email(
                                label: 'ইমেইল: ${AppConstants.cidEmail}',
                                target: AppConstants.cidEmail,
                                emailSubject: 'CID Gazette Claim - Ref: ${record.referenceNo}',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Official Seal & Sign-off
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('গেজেট প্রকাশের তারিখ: ${record.dateFound}', style: const TextStyle(fontSize: 12)),
                            Text('উদ্ধারকারী কর্মকর্তা: ${record.recoveryOfficerUnit}', style: const TextStyle(fontSize: 12)),
                            Text('থানা সাধারণ ডায়েরি: ${record.gdCaseReference}', style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'স্বাক্ষরিত/-',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'বিশেষ পুলিশ সুপার (সিআইবি)\nক্রিমিনাল ইনভেস্টিগেশন ডিপার্টমেন্ট (সিআইডি)\nবাংলাদেশ পুলিশ, ঢাকা',
                              textAlign: TextAlign.right,
                              style: TextStyle(fontSize: 11, height: 1.3),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGazetteTable(bool isDark) {
    return Table(
      border: TableBorder.all(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        width: 1,
      ),
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(5),
      },
      children: [
        _tableRow('মৃতদেহ প্রাপ্তির তারিখ ও স্থান / Date & Place Found', '${record.dateFound} • ${record.placeFound}, ${record.thana}, ${record.district}', isDark),
        _tableRow('নির্দিষ্ট উদ্ধারস্থল / Coordinates & Spot', record.locationFound, isDark),
        _tableRow('থানা ও জিডি নং / Police Station & GD Ref', '${record.thana} PS • ${record.gdCaseReference}', isDark),
        _tableRow('লিঙ্গ ও আনুমানিক বয়স / Sex & Estimated Age', '${record.gender} • আনুমানিক ${record.estimatedAge} বছর (${record.ageGroup})', isDark),
        _tableRow('উচ্চতা ও ওজন / Height & Weight', '${record.heightCm} সে.মি. • ${record.weightKg} কেজি', isDark),
        _tableRow('মৃতদেহের অবস্থা / Body Condition', record.bodyCondition, isDark),
        _tableRow('গায়ের রঙ ও চুল / Complexion & Hair', '${record.complexion} • ${record.hair} • ${record.facialHair}', isDark),
        _tableRow('সনাক্তকরণ বিশেষ চিহ্ন ও ট্যাটু / Marks & Scars', record.identificationMarks, isDark),
        _tableRow('দাঁতের বিবরণ / Dental Characteristics', record.dentalCharacteristics, isDark),
        _tableRow('পরনের পোশাক / Clothing Description', record.clothing, isDark),
        _tableRow('সাথে প্রাপ্ত জিনিসপত্র / Personal Belongings', record.personalBelongings, isDark),
        _tableRow('ময়নাতদন্ত ও ডিএনএ অবস্থা / Forensic Status', 'ময়নাতদন্ত নং: ${record.postmortemReference} • ডিএনএ প্রোফাইল: ${record.dnaProfileAvailability}', isDark),
      ],
    );
  }

  TableRow _tableRow(String label, String value, bool isDark) {
    return TableRow(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : Colors.white,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            value.isNotEmpty ? value : 'প্রযোজ্য নয় / Not specified',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

