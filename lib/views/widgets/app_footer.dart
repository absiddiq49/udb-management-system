import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
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
        horizontal: isDesktop ? 64 : 20,
        vertical: 36,
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
                          height: 32,
                          errorBuilder: (_, _, _) => const Icon(Icons.shield_outlined, color: AppColors.primary, size: 28),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'CID BANGLADESH',
                          style: TextStyle(
                            color: headingColor,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Central Intelligence Bureau (CIB) & Forensic DNA Profiling Laboratory.\n'
                      'Standardized under Interpol DVI (Disaster Victim Identification) Guidelines and Police Regulations of Bengal (PRB).',
                      style: TextStyle(color: bodyColor, fontSize: 12, height: 1.55),
                    ),
                  ],
                ),
              ),

              if (isDesktop) ...[
                const SizedBox(width: 48),
                // Emergency Dispatch
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'EMERGENCY & HELPLINE',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.redLight,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.redBorder),
                            ),
                            child: const Text('24/7', style: TextStyle(color: AppColors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          Text('National Emergency: 999', style: TextStyle(color: headingColor, fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('CID CIB Desk: ${AppConstants.cidHelpline}', style: TextStyle(color: bodyColor, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('Official Email: ${AppConstants.cidEmail}', style: TextStyle(color: bodyColor, fontSize: 12)),
                    ],
                  ),
                ),

                const SizedBox(width: 48),
                // Forensic Compliance
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'LEGAL & ETHICAL MANDATE',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text('• CrPC Section 174 (Police Inquest)', style: TextStyle(color: bodyColor, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('• Interpol Pink Form (Post-Mortem Standard)', style: TextStyle(color: bodyColor, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('• SHA-256 Cryptographic Report Integrity', style: TextStyle(color: bodyColor, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 28),
          Divider(color: borderColor),
          const SizedBox(height: 16),

          // Copyright & Disclaimer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '© 2026 Criminal Investigation Department (CID), Bangladesh Police. Standardized Forensic Deceased Registry.',
                  style: TextStyle(color: mutedColor, fontSize: 11),
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
                  const Text(
                    'Operational & Verified',
                    style: TextStyle(color: AppColors.green, fontSize: 11, fontWeight: FontWeight.w600),
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
