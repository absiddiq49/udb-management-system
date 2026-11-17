import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'models/udb_record.dart';
import 'providers/auth_provider.dart';
import 'providers/udb_provider.dart';
import 'providers/request_provider.dart';
import 'providers/theme_provider.dart';
import 'views/widgets/app_navbar.dart';
import 'views/public/public_home_view.dart';
import 'views/public/public_dossier_view.dart';
import 'views/public/citizen_report_view.dart';
import 'views/public/io_access_request_view.dart';
import 'views/official/official_login_view.dart';
import 'views/official/official_dashboard_view.dart';
import 'views/official/official_dossier_view.dart';
import 'views/official/cross_matching_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const UnidentifiedDeadBodyApp());
}

class UnidentifiedDeadBodyApp extends StatelessWidget {
  const UnidentifiedDeadBodyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UdbProvider()),
        ChangeNotifierProxyProvider<UdbProvider, RequestProvider>(
          create: (context) => RequestProvider(context.read<UdbProvider>().repository),
          update: (_, udb, previous) => previous ?? RequestProvider(udb.repository),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) {
          return MaterialApp(
            title: 'CID Unidentified Dead Body Management System | Bangladesh Police',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: theme.themeMode,
            home: const AppShell(),
          );
        },
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _activeNavIndex = 0;
  UdbRecord? _selectedPublicRecord;
  UdbRecord? _selectedOfficialRecord;
  String? _prefillToken;

  void _navigateTo(int index) {
    setState(() {
      _activeNavIndex = index;
      _selectedPublicRecord = null;
      _selectedOfficialRecord = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    Widget currentBody;

    // Detailed Views take precedence if a record is actively selected
    if (_selectedOfficialRecord != null && auth.isAuthenticated) {
      currentBody = OfficialDossierView(
        record: _selectedOfficialRecord!,
        onBack: () => setState(() => _selectedOfficialRecord = null),
      );
    } else if (_selectedPublicRecord != null) {
      currentBody = PublicDossierView(
        record: _selectedPublicRecord!,
        onBack: () => setState(() => _selectedPublicRecord = null),
        onOpenOfficialDossier: () {
          setState(() {
            _selectedOfficialRecord = _selectedPublicRecord;
            _selectedPublicRecord = null;
          });
        },
        onRequestIoAccess: () {
          _navigateTo(2); // Go to IO Access Request tab
        },
      );
    } else {
      switch (_activeNavIndex) {
        case 0:
          currentBody = PublicHomeView(
            onSelectRecord: (record) => setState(() => _selectedPublicRecord = record),
            onReportFoundBody: () => _navigateTo(1),
            onRequestIoAccess: () => _navigateTo(2),
          );
          break;
        case 1:
          currentBody = CitizenReportView(
            onCancel: () => _navigateTo(0),
          );
          break;
        case 2:
          currentBody = IoAccessRequestView(
            onCancel: () => _navigateTo(0),
            onSwitchToLogin: (token) {
              setState(() {
                _prefillToken = token;
                _activeNavIndex = 4; // Switch to login
              });
            },
          );
          break;
        case 3:
          currentBody = CrossMatchingView(
            onSelectRecord: (record) => setState(() => _selectedPublicRecord = record),
          );
          break;
        case 4:
          if (auth.isAuthenticated) {
            currentBody = OfficialDashboardView(
              onSelectRecord: (record) => setState(() => _selectedOfficialRecord = record),
            );
          } else {
            currentBody = OfficialLoginView(
              initialToken: _prefillToken,
              onLoginSuccess: () => setState(() => _activeNavIndex = 4),
              onCancel: () => _navigateTo(0),
            );
          }
          break;
        default:
          currentBody = PublicHomeView(
            onSelectRecord: (record) => setState(() => _selectedPublicRecord = record),
            onReportFoundBody: () => _navigateTo(1),
            onRequestIoAccess: () => _navigateTo(2),
          );
      }
    }

    return Scaffold(
      body: Column(
        children: [
          // Top Navigation Bar
          AppNavbar(
            activeIndex: _activeNavIndex,
            onNavigate: _navigateTo,
          ),

          // Main View Content
          Expanded(
            child: currentBody,
          ),
        ],
      ),
    );
  }
}
