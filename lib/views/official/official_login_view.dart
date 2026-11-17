import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';

class OfficialLoginView extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  final VoidCallback onCancel;
  final String? initialToken;

  const OfficialLoginView({
    super.key,
    required this.onLoginSuccess,
    required this.onCancel,
    this.initialToken,
  });

  @override
  State<OfficialLoginView> createState() => _OfficialLoginViewState();
}

class _OfficialLoginViewState extends State<OfficialLoginView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _usernameController =
      TextEditingController(text: AppConstants.demoMode ? 'cib_supervisor' : '');
  final _passwordController =
      TextEditingController(text: AppConstants.demoMode ? 'police123' : '');
  late TextEditingController _tokenController;

  @override
  void initState() {
    super.initState();
    _tokenController = TextEditingController(text: widget.initialToken ?? '');
    _tabController = TabController(length: 2, vsync: this);
    if (widget.initialToken != null && widget.initialToken!.isNotEmpty) {
      _tabController.index = 1;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _handleOfficialLogin() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );
    if (success && mounted) {
      widget.onLoginSuccess();
    }
  }

  Future<void> _handleTokenLogin() async {
    final auth = context.read<AuthProvider>();
    final reqs = context.read<RequestProvider>().requests;
    final success = await auth.loginWithToken(_tokenController.text.trim(), reqs);
    if (success && mounted) {
      widget.onLoginSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDesktop = Responsive.isDesktop(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 16,
        vertical: 32,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 580),
          child: Builder(
            builder: (context) {
              final isLight = Theme.of(context).brightness == Brightness.light;
              final cardBg = isLight ? Colors.white : AppColors.darkCardBg;
              final borderColor = isLight ? AppColors.lightBorder : AppColors.darkBorder;
              final textSec = isLight ? AppColors.lightTextSecondary : AppColors.darkTextSecondary;

              return Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                  boxShadow: isLight
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo & Header
                    Image.asset(
                      'assets/images/cid-logo-blue.png',
                      height: 64,
                      errorBuilder: (_, _, _) => const Icon(Icons.shield, color: AppColors.gold, size: 54),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'POLICE OFFICIAL SECURE PORTAL',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Criminal Investigation Department (CID) • Central Intelligence Bureau',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: textSec, fontSize: 12),
                    ),

                    const SizedBox(height: 24),

                    // Tab Bar: Modern Segmented Switcher
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isLight ? AppColors.slate100 : AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: isLight ? Colors.white : AppColors.darkCardBg,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: isLight
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  )
                                ]
                              : null,
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: textSec,
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        tabs: const [
                          Tab(text: 'CID Officer Login'),
                          Tab(text: 'IO Access Token Pass'),
                        ],
                      ),
                    ),

                const SizedBox(height: 20),

                if (auth.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.red.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.red, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            auth.errorMessage!,
                            style: const TextStyle(color: AppColors.red, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                SizedBox(
                  height: 280,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab 1: Username & Password
                      _buildUsernameLoginForm(auth),
                      // Tab 2: Temporary IO Token Pass
                      _buildTokenLoginForm(auth),
                    ],
                  ),
                ),

                if (AppConstants.demoMode) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),

                // One-click demo roles for reviewer evaluation
                const Text(
                  'Quick Reviewer Credentials (Click to Fill):',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _demoPill('cib_supervisor', 'Super Admin (SP CIB)', () {
                      _tabController.animateTo(0);
                      _usernameController.text = 'cib_supervisor';
                      _passwordController.text = 'police123';
                    }),
                    _demoPill('forensic_expert', 'Forensic Lab Expert', () {
                      _tabController.animateTo(0);
                      _usernameController.text = 'forensic_expert';
                      _passwordController.text = 'police123';
                    }),
                    _demoPill('officer_paltan', 'Thana Assigned IO', () {
                      _tabController.animateTo(0);
                      _usernameController.text = 'officer_paltan';
                      _passwordController.text = 'police123';
                    }),
                    _demoPill('CID-PASS-7849-KM', 'External IO Pass', () {
                      _tabController.animateTo(1);
                      _tokenController.text = 'CID-PASS-7849-KM';
                    }),
                  ],
                ),
                ],

                const SizedBox(height: 20),

                TextButton(
                  onPressed: widget.onCancel,
                  child: const Text('Back to Public Portal', style: TextStyle(color: AppColors.textSecondary)),
                ),
              ],
            ),
          );
        },
      ),
    ),
  ),
);
  }

  Widget _buildUsernameLoginForm(AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _usernameController,
          decoration: const InputDecoration(
            labelText: 'Officer Username or BP Number',
            prefixIcon: Icon(Icons.person, color: AppColors.gold, size: 18),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Security Password',
            prefixIcon: Icon(Icons.lock, color: AppColors.gold, size: 18),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: auth.isLoading ? null : _handleOfficialLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: auth.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Authenticate & Access Dossiers'),
        ),
      ],
    );
  }

  Widget _buildTokenLoginForm(AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'External Investigation Officers who received an approved Access Pass Token via SMS/Email can enter it below for immediate temporary clearance.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _tokenController,
          decoration: const InputDecoration(
            labelText: 'Access Pass Token (e.g. CID-PASS-7849-KM)',
            prefixIcon: Icon(Icons.vpn_key, color: AppColors.gold, size: 18),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: auth.isLoading ? null : _handleTokenLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: auth.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Validate Token & Enter Dossier'),
        ),
      ],
    );
  }

  Widget _demoPill(String value, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Text(
          label,
          style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
