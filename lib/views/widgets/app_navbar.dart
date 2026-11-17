import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/udb_provider.dart';
import '../../providers/theme_provider.dart';

class AppNavbar extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onNavigate;

  const AppNavbar({
    super.key,
    required this.activeIndex,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final udb = context.watch<UdbProvider>();
    final themeProv = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.sizeOf(context).width;

    // Responsive breakpoints adjusted to prevent any horizontal overflow
    final isDesktop = width >= 1320;
    final isTablet = width >= 860 && width < 1320;

    final navBg = isDark ? AppColors.darkCardBg : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final titleColor = isDark ? AppColors.darkTextPrimary : AppColors.slate900;
    final subtitleColor = isDark ? AppColors.darkTextMuted : AppColors.slate500;

    return Container(
      decoration: BoxDecoration(
        color: navBg,
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 20 : (isTablet ? 14 : 10),
        vertical: 9,
      ),
      child: Row(
        children: [
          // Brand Logo & Title
          InkWell(
            onTap: () => onNavigate(0),
            borderRadius: BorderRadius.circular(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/cid-logo-blue-ui.png',
                  height: 36,
                  errorBuilder: (_, _, _) => Image.asset(
                    'assets/images/CID.png',
                    height: 36,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.shield_outlined,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          width > 480 ? 'CID BANGLADESH' : 'CID UDB',
                          style: TextStyle(
                            color: titleColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.primaryBorder),
                          ),
                          child: const Text(
                            'UDB-MS',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (width > 1150) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Unidentified Deceased & Forensic Cross-Matching',
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          const Spacer(),

          // Desktop Full Navigation Links
          if (isDesktop) ...[
            _navLink('Deceased Index', 0, Icons.person_search_outlined, isDark),
            _navLink('Report Found Body', 1, Icons.report_problem_outlined, isDark),
            _navLink('IO Access Request', 2, Icons.vpn_key_outlined, isDark),
            _navLink('Cross-Matching Engine', 3, Icons.compare_arrows_outlined, isDark),
            if (auth.isAuthenticated)
              _navLink('Official Portal', 4, Icons.admin_panel_settings_outlined, isDark),
            const SizedBox(width: 6),
          ] else if (isTablet) ...[
            // Tablet Compact Navigation (Icon with Tooltip)
            _compactNavLink('Deceased Index', 0, Icons.person_search_outlined, isDark),
            _compactNavLink('Report Found Body', 1, Icons.report_problem_outlined, isDark),
            _compactNavLink('IO Access Request', 2, Icons.vpn_key_outlined, isDark),
            _compactNavLink('Cross-Matching Engine', 3, Icons.compare_arrows_outlined, isDark),
            if (auth.isAuthenticated)
              _compactNavLink('Official Portal', 4, Icons.admin_panel_settings_outlined, isDark),
            const SizedBox(width: 4),
          ] else ...[
            // Mobile Menu Popup
            PopupMenuButton<int>(
              icon: Icon(Icons.menu, color: isDark ? Colors.white : AppColors.slate700),
              tooltip: 'Navigation Menu',
              color: isDark ? AppColors.darkCardBg : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: borderColor),
              ),
              onSelected: (idx) => onNavigate(idx),
              itemBuilder: (_) => [
                _popupMenuItem(0, Icons.person_search_outlined, 'Deceased Index', isDark),
                _popupMenuItem(1, Icons.report_problem_outlined, 'Report Found Body', isDark),
                _popupMenuItem(2, Icons.vpn_key_outlined, 'IO Access Request', isDark),
                _popupMenuItem(3, Icons.compare_arrows_outlined, 'Cross-Matching Engine', isDark),
                if (auth.isAuthenticated)
                  _popupMenuItem(4, Icons.admin_panel_settings_outlined, 'Official Portal', isDark),
              ],
            ),
          ],

          // Theme Mode Switch (Light / Dark)
          IconButton(
            icon: Icon(
              themeProv.isLight ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              color: isDark ? AppColors.goldBright : AppColors.slate600,
              size: 19,
            ),
            tooltip: themeProv.isLight ? 'Switch to Dark Mode' : 'Switch to Light Mode',
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(),
            onPressed: () => themeProv.toggleTheme(),
          ),

          const SizedBox(width: 6),

          // Global Sensitive Blur Toggle
          Tooltip(
            message: udb.blurSensitive ? 'Sensitive photos are blurred' : 'Sensitive photos are visible',
            child: OutlinedButton.icon(
              onPressed: () => udb.toggleBlur(),
              icon: Icon(
                udb.blurSensitive ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 14,
                color: udb.blurSensitive ? AppColors.amber : AppColors.primary,
              ),
              label: Text(
                isDesktop
                    ? (udb.blurSensitive ? 'Blur: ON' : 'Blur: OFF')
                    : (udb.blurSensitive ? 'ON' : 'OFF'),
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: udb.blurSensitive ? AppColors.amber : AppColors.primary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: udb.blurSensitive ? AppColors.amber.withValues(alpha: 0.5) : AppColors.primaryBorder,
                ),
                backgroundColor: udb.blurSensitive ? AppColors.goldLight : AppColors.primaryLight,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
          ),

          const SizedBox(width: 6),

          // Auth Button / User Profile
          if (!auth.isAuthenticated)
            ElevatedButton.icon(
              onPressed: () => onNavigate(4),
              icon: const Icon(Icons.lock_outline, size: 13),
              label: Text(
                isDesktop ? 'Officer Portal' : 'Login',
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 12 : 8, vertical: 7),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
            )
          else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.slate800 : AppColors.slate100,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    child: const Icon(Icons.shield, color: AppColors.primary, size: 11),
                  ),
                  if (width > 1050) ...[
                    const SizedBox(width: 6),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            auth.session.fullName,
                            style: TextStyle(
                              color: titleColor,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${auth.session.rank} (${auth.session.bpNumber})',
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 8.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout, size: 17, color: AppColors.red),
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(),
              onPressed: () {
                auth.logout();
                onNavigate(0);
              },
              tooltip: 'Sign Out Officer Session',
            ),
          ],
        ],
      ),
    );
  }

  Widget _navLink(String label, int index, IconData icon, bool isDark) {
    final isSelected = activeIndex == index;
    final fg = isSelected
        ? AppColors.primary
        : (isDark ? AppColors.darkTextSecondary : AppColors.slate600);
    final bg = isSelected
        ? (isDark ? AppColors.primary.withValues(alpha: 0.15) : AppColors.primaryLight)
        : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1.5),
      child: TextButton.icon(
        onPressed: () => onNavigate(index),
        icon: Icon(icon, size: 14, color: fg),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: fg,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          backgroundColor: bg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  Widget _compactNavLink(String label, int index, IconData icon, bool isDark) {
    final isSelected = activeIndex == index;
    return Tooltip(
      message: label,
      child: IconButton(
        onPressed: () => onNavigate(index),
        icon: Icon(
          icon,
          size: 18,
          color: isSelected ? AppColors.primary : (isDark ? AppColors.darkTextSecondary : AppColors.slate600),
        ),
        padding: const EdgeInsets.all(6),
        constraints: const BoxConstraints(),
        style: IconButton.styleFrom(
          backgroundColor: isSelected
              ? (isDark ? AppColors.primary.withValues(alpha: 0.15) : AppColors.primaryLight)
              : Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  PopupMenuItem<int> _popupMenuItem(int value, IconData icon, String label, bool isDark) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 17, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : AppColors.slate800,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
