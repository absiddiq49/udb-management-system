import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../providers/locale_provider.dart';
import 'contact_action_pill.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final isDesktop = Responsive.isDesktop(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? AppColors.darkCardBg : AppColors.slate50;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.slate200;
    final headingColor = isDark ? AppColors.darkTextPrimary : AppColors.slate900;
    final bodyColor = isDark ? AppColors.darkTextSecondary : AppColors.slate600;
    final mutedColor = isDark ? AppColors.darkTextMuted : AppColors.slate500;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: borderColor, width: 1)),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 48 : 16,
        vertical: 32,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CID Info
              Expanded(
                flex: isDesktop ? 3 : 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/cid-logo-blue-ui.png',
                          height: 34,
                          errorBuilder: (_, _, _) => const Icon(Icons.shield_outlined, color: AppColors.primary, size: 28),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          loc.tr('UDBMS BANGLADESH • CID', 'ইউডিবিএমএস বাংলাদেশ • সিআইডি'),
                          style: TextStyle(
                            color: headingColor,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            fontSize: 13.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      loc.tr(
                        'Central Intelligence Bureau (CIB) & Forensic DNA Profiling Laboratory, CID Malibagh, Dhaka.\n'
                        'Standardized under Police Regulations of Bengal (PRB Rules 299-303) and CrPC Section 174.',
                        'কেন্দ্রীয় গোয়েন্দা শাখা (সিআইবি) এবং জাতীয় ফরেনসিক ডিএনএ ল্যাবরেটরি, সিআইডি মালিবাগ, ঢাকা।\n'
                        'বেঙ্গল পুলিশ রেগুলেশন (পিআরবি নিয়ম ২৯৯-৩০৩) এবং ফৌজদারি কার্যবিধি ১৭৪ ধারা অনুযায়ী পরিচালিত।',
                      ),
                      style: TextStyle(color: bodyColor, fontSize: 11.5, height: 1.55),
                    ),
                  ],
                ),
              ),

              if (isDesktop) ...[
                const SizedBox(width: 40),
                // Emergency Dispatch
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.tr('EMERGENCY & HELPLINE', 'জরুরি যোগাযোগ ও হেল্পলাইন'),
                        style: const TextStyle(
                          color: Color(0xFF0F2646),
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        direction: Axis.vertical,
                        spacing: 8,
                        children: [
                          ContactActionPill.phone(
                            label: loc.tr('National Emergency: 999 (24/7)', 'জাতীয় জরুরি সেবা: ৯৯৯ (২৪/৭)'),
                            target: '999',
                            isEmergency: true,
                          ),
                          ContactActionPill.phone(
                            label: loc.tr('CID Desk: 02-48311051', 'সিআইডি কন্ট্রোল রুম: ০২-৪৮৩১১০৫১'),
                            target: '0248311051',
                          ),
                          ContactActionPill.phone(
                            label: loc.tr('Anjuman Mufidul Islam: 02-9336611', 'আঞ্জুমান মফিদুল ইসলাম: ০২-৯৩৩৬৬১১'),
                            target: '029336611',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 40),
                // Legal & Forensic Mandate
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.tr('LEGAL & ETHICAL MANDATE', 'আইনি ও সুরতহাল নীতিমালা'),
                        style: const TextStyle(
                          color: Color(0xFF0F2646),
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        loc.tr('• CrPC §174 (Police Inquest & Magistrate Report)', '• ফৌজদারি কার্যবিধি ১৭৪ ধারা (পুলিশ সুরতহাল প্রতিবেদন)'),
                        style: TextStyle(color: bodyColor, fontSize: 11.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        loc.tr('• PRB Rule 299-303 (Unidentified Deceased Procedures)', '• পিআরবি নিয়ম ২৯৯-৩০৩ (মৃতদেহ সংরক্ষণ ও আঞ্জুমানে হস্তান্তর)'),
                        style: TextStyle(color: bodyColor, fontSize: 11.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        loc.tr('• Interpol Pink Form DVI Standard Protocol', '• ইন্টারপোল গোলাপি ফর্ম (পোস্ট-মর্টেম DVI নির্দেশিকা)'),
                        style: TextStyle(color: bodyColor, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 24),
          Divider(color: borderColor),
          const SizedBox(height: 14),

          // Copyright & Disclaimer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  loc.tr(
                    '© 2026 Criminal Investigation Department (CID), Bangladesh Police. Real-Time Inter-District Forensic Records Sharing Platform.',
                    '© ২০২৬ অপরাধ তদন্ত বিভাগ (সিআইডি), বাংলাদেশ পুলিশ। আন্তঃজেলা অপরাধ ও অজ্ঞাত মৃতদেহ সমন্বয় নেটওয়ার্ক।',
                  ),
                  style: TextStyle(color: mutedColor, fontSize: 10.5),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    loc.tr('Operational & Verified', 'সক্রিয় ও প্রত্যয়িত'),
                    style: const TextStyle(color: AppColors.green, fontSize: 10.5, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
