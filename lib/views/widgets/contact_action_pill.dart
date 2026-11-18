import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/link_service.dart';

class ContactActionPill extends StatelessWidget {
  final String label;
  final String target;
  final bool isEmail;
  final bool isEmergency;
  final IconData? icon;
  final String? emailSubject;
  final double fontSize;

  const ContactActionPill.phone({
    super.key,
    required this.label,
    required this.target,
    this.isEmergency = false,
    this.icon,
    this.fontSize = 11.5,
  })  : isEmail = false,
        emailSubject = null;

  const ContactActionPill.email({
    super.key,
    required this.label,
    required this.target,
    this.emailSubject,
    this.icon,
    this.fontSize = 11.5,
  })  : isEmail = true,
        isEmergency = false;

  void _handleTap(BuildContext context) async {
    if (isEmail) {
      final success = await LinkService.launchEmail(target, subject: emailSubject);
      if (!success && context.mounted) {
        Clipboard.setData(ClipboardData(text: target));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Copied email: $target'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } else {
      final success = await LinkService.launchPhone(target);
      if (!success && context.mounted) {
        Clipboard.setData(ClipboardData(text: target));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Copied phone number: $target'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color fgColor = isEmergency
        ? AppColors.redDark
        : (isEmail
            ? AppColors.primary
            : (isDark ? AppColors.green : AppColors.greenDark));

    final Color bgColor = isEmergency
        ? AppColors.redLight
        : (isEmail
            ? (isDark ? AppColors.primary.withValues(alpha: 0.15) : AppColors.primaryLight)
            : (isDark ? AppColors.green.withValues(alpha: 0.15) : AppColors.greenLight));

    final Color borderColor = isEmergency
        ? AppColors.redBorder
        : (isEmail ? AppColors.primaryBorder : AppColors.greenBorder);

    final IconData effectiveIcon = icon ??
        (isEmail
            ? Icons.email_outlined
            : (isEmergency ? Icons.phone_in_talk : Icons.call_outlined));

    return InkWell(
      onTap: () => _handleTap(context),
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: target));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Copied: $target'),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: borderColor, width: 0.9),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(effectiveIcon, size: fontSize + 2, color: fgColor),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: fgColor,
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
