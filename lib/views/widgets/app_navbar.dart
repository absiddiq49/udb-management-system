import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/udb_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/locale_provider.dart';
import 'contact_action_pill.dart';

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
    final themeProv = context.watch<ThemeProvider>();
    final loc = context.watch<LocaleProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.sizeOf(context).width;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. TOP UTILITY STRIP (Emergency 999 + Prominent Language Switcher + Theme + Officer Status)
        Container(
          color: isDark ? const Color(0xFF07111E) : const Color(0xFF0A192F),
          padding: EdgeInsets.symmetric(horizontal: width > 900 ? 28 : 12, vertical: 5),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Emergency 999 Hotline
                ContactActionPill.phone(
                  label: width > 700
                      ? loc.tr(
                          'National Emergency Service: 999 (Toll-Free 24/7)',
                          'জাতীয় জরুরি সেবা: ৯৯৯ (টোল-ফ্রি ২৪/৭)',
                        )
                      : loc.tr('Emergency 999', 'জরুরি ৯৯৯'),
                  target: '999',
                  isEmergency: true,
                  fontSize: 10.5,
                ),

                SizedBox(width: width > 900 ? 24 : 12),

                // CID Control Room Direct Hotline
                if (width > 850) ...[
                  ContactActionPill.phone(
                    label: loc.tr('CID Desk: 02-48311051', 'সিআইডি হটলাইন: ০২-৪৮৩১১০৫১'),
                    target: '0248311051',
                    fontSize: 10.5,
                  ),
                  SizedBox(width: width > 900 ? 24 : 12),
                ],

                // PROMINENT INTERACTIVE LANGUAGE SWITCHER (বাংলা / English)
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white24, width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            loc.setLanguage(AppLanguage.bangla);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: loc.isBangla ? const Color(0xFFD97706) : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: loc.isBangla
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🇧🇩', style: TextStyle(fontSize: 11.5)),
                                const SizedBox(width: 4),
                                Text(
                                  'বাংলা',
                                  style: TextStyle(
                                    color: loc.isBangla ? Colors.white : Colors.white70,
                                    fontSize: 11,
                                    fontWeight: loc.isBangla ? FontWeight.w900 : FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 2),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            loc.setLanguage(AppLanguage.english);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: loc.isEnglish ? const Color(0xFFD97706) : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: loc.isEnglish
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🇬🇧', style: TextStyle(fontSize: 11.5)),
                                const SizedBox(width: 4),
                                Text(
                                  'English',
                                  style: TextStyle(
                                    color: loc.isEnglish ? Colors.white : Colors.white70,
                                    fontSize: 11,
                                    fontWeight: loc.isEnglish ? FontWeight.w900 : FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('|', style: TextStyle(color: Colors.white38, fontSize: 11)),
                ),

                // Theme Switcher
                InkWell(
                  onTap: () => themeProv.toggleTheme(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        themeProv.isLight ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                        color: AppColors.goldBright,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        themeProv.isLight ? loc.tr('Dark', 'ডার্ক') : loc.tr('Light', 'লাইট'),
                        style: const TextStyle(color: Colors.white70, fontSize: 10.5),
                      ),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('|', style: TextStyle(color: Colors.white38, fontSize: 11)),
                ),

                // Quick Login / Officer Status
                if (!auth.isAuthenticated)
                  InkWell(
                    onTap: () => onNavigate(4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock_outline, color: Colors.white, size: 13),
                        const SizedBox(width: 4),
                        Text(
                          loc.tr('Police Login', 'পুলিশ লগইন'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shield, color: AppColors.goldBright, size: 13),
                      const SizedBox(width: 4),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 180),
                        child: Text(
                          auth.session.fullName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          context.read<AuthProvider>().logout();
                          onNavigate(0);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.logout, color: AppColors.red, size: 13),
                            const SizedBox(width: 2),
                            Text(
                              loc.tr('Logout', 'লগআউট'),
                              style: const TextStyle(color: Colors.white70, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),

        // 2. MAIN BRANDING HEADER (UDBMS Logo + BD Police Crest + High-Visibility Unit Badges)
        Container(
          color: isDark ? AppColors.darkCardBg : Colors.white,
          padding: EdgeInsets.symmetric(horizontal: width > 900 ? 28 : 14, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Bangladesh Police CID Official Crest Logo
              InkWell(
                onTap: () => onNavigate(0),
                child: Image.asset(
                  'assets/images/cid-logo-blue-ui.png',
                  height: 60,
                  errorBuilder: (_, _, _) => Image.asset(
                    'assets/images/cid-logo-blue.png',
                    height: 60,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.shield,
                      color: AppColors.primary,
                      size: 52,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // UDBMS Title Block
              Expanded(
                child: InkWell(
                  onTap: () => onNavigate(0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'UDBMS',
                            style: TextStyle(
                              color: isDark ? Colors.white : const Color(0xFF0A192F),
                              fontSize: width < 600 ? 20 : 25,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              fontFamily: 'serif',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDC2626),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'BANGLADESH',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text(
                        loc.tr(
                          'Unidentified Deadbody Management System',
                          'অজ্ঞাত মৃতদেহ ব্যবস্থাপনা পদ্ধতি',
                        ),
                        style: TextStyle(
                          color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E3A8A),
                          fontSize: width < 600 ? 11 : 12.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        loc.tr(
                          'Criminal Investigation Department (CID) • Bangladesh Police',
                          'অপরাধ তদন্ত বিভাগ (সিআইডি) • বাংলাদেশ পুলিশ',
                        ),
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.slate600,
                          fontSize: width < 600 ? 9.5 : 10.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Soothing Institutional Verification Tag & Helpline Info
              if (width > 860)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F1E36) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.5) : const Color(0xFFCBD5E1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F2646),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.verified_user_rounded,
                          color: AppColors.goldBright,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                loc.tr('CENTRAL FORENSIC REPOSITORY', 'কেন্দ্রীয় ফরেনসিক ডেটাবেজ'),
                                style: TextStyle(
                                  color: isDark ? Colors.white : const Color(0xFF0F2646),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            loc.tr(
                              'Inter-Agency Inquest Network • CrPC §174',
                              'আন্তঃইউনিট অপমৃত্যু তদন্ত নেটওয়ার্ক • ধারা ১৭৪',
                            ),
                            style: TextStyle(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.slate600,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w500,
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

        // 3. MAIN NAVIGATION MENU BAR (Full Width Dark Navy Bar)
        Container(
          color: const Color(0xFF0A1D37),
          padding: EdgeInsets.symmetric(horizontal: width > 900 ? 20 : 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _menuItem(loc.tr('HOME', 'হোম'), 0, Icons.home_outlined),

                // VICTIMS Dropdown
                PopupMenuButton<int>(
                  tooltip: loc.tr('Victims Registry', 'শনাক্তকরণ ও রেজিস্ট্রি'),
                  offset: const Offset(0, 42),
                  color: const Color(0xFF0A1D37),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  onSelected: (idx) => onNavigate(idx),
                  itemBuilder: (_) => [
                    _dropdownItem(0, loc.tr('Un-Identified Dead Bodies (অজ্ঞাত মৃতদেহ)', 'অজ্ঞাত মৃতদেহ রেজিস্ট্রি')),
                    _dropdownItem(3, loc.tr('Missing Persons Registry (নিখোঁজ ব্যক্তি)', 'নিখোঁজ ব্যক্তি রেজিস্ট্রি')),
                    _dropdownItem(0, loc.tr('Un-Identified Persons Found (উদ্ধারকৃত জীবিত ব্যক্তি)', 'উদ্ধারকৃত অজ্ঞাত জীবিত ব্যক্তি')),
                  ],
                  child: _menuDropdownLabel(loc.tr('VICTIMS (শনাক্তকরণ)', 'শনাক্তকরণ (Victims)')),
                ),

                // VEHICLES / PROPERTY Dropdown
                PopupMenuButton<String>(
                  tooltip: loc.tr('Vehicles & Property', 'যানবাহন ও মালামাল'),
                  offset: const Offset(0, 42),
                  color: const Color(0xFF0A1D37),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  onSelected: (val) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$val module integrated with National Police DB.')),
                    );
                  },
                  itemBuilder: (_) => [
                    _dropdownItemString(loc.tr('Stolen Vehicles (চুরি যাওয়া যানবাহন)', 'চুরি যাওয়া যানবাহন ডাটাবেজ')),
                    _dropdownItemString(loc.tr('Un-claimed / Seized Vehicles (জব্দকৃত যানবাহন)', 'জব্দকৃত বেওয়ারিশ যানবাহন')),
                    _dropdownItemString(loc.tr('Missing Mobiles (হারানো মোবাইল ফোন)', 'হারানো মোবাইল ফোন (GD Track)')),
                  ],
                  child: _menuDropdownLabel(loc.tr('STOLEN / SEIZED', 'চুরি ও জব্দকৃত মালামাল')),
                ),

                _menuItem(loc.tr('CROSS-MATCHING ENGINE', 'মিলকরণ ইঞ্জিন'), 3, Icons.compare_arrows_rounded),
                _menuItem(loc.tr('REPORT FOUND BODY', 'লাশের তথ্য দিন'), 1, Icons.emergency_outlined),
                _menuItem(loc.tr('IO ACCESS REQUEST', 'পুলিশ কর্মকর্তা আবেদন'), 2, Icons.vpn_key_outlined),

                const SizedBox(width: 16),

                // Sensitive Photo Blur Global Toggle
                Consumer<UdbProvider>(
                  builder: (context, udb, _) {
                    return InkWell(
                      onTap: () => udb.toggleBlur(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: udb.blurSensitive ? const Color(0xFF2E1065) : const Color(0xFF1E3A8A),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              udb.blurSensitive ? Icons.visibility_off : Icons.visibility,
                              color: Colors.white,
                              size: 13,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              udb.blurSensitive
                                  ? loc.tr('Photos: Blur ON', 'ছবি ব্লার: চালু')
                                  : loc.tr('Photos: Blur OFF', 'ছবি ব্লার: বন্ধ'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(width: 10),

                // Police Portal
                _menuItem(
                  auth.isAuthenticated
                      ? loc.tr('OFFICER PORTAL', 'অফিসার পোর্টাল')
                      : loc.tr('POLICE LOGIN', 'পুলিশ লগইন'),
                  4,
                  Icons.admin_panel_settings_outlined,
                  highlight: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _menuItem(String title, int index, IconData icon, {bool highlight = false}) {
    final isSelected = activeIndex == index;
    return InkWell(
      onTap: () => onNavigate(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1E40AF)
              : (highlight ? const Color(0xFF047857) : Colors.transparent),
          border: isSelected
              ? const Border(bottom: BorderSide(color: AppColors.goldBright, width: 3))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 13),
            const SizedBox(width: 5),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuDropdownLabel(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 16),
        ],
      ),
    );
  }

  PopupMenuItem<int> _dropdownItem(int value, String text) {
    return PopupMenuItem<int>(
      value: value,
      height: 38,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  PopupMenuItem<String> _dropdownItemString(String text) {
    return PopupMenuItem<String>(
      value: text,
      height: 38,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}
