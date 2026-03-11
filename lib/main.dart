import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// --- استيراد الملفات اللازمة ---
import 'l10n/app_localizations.dart';
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/hive_provider.dart';
import 'providers/inspection_provider.dart';
import 'providers/treatment_provider.dart';
import 'providers/production_provider.dart';
import 'services/ad_service.dart';
import 'utils/app_theme.dart';
import 'screens/login_screen.dart';
// --- *** 1. استيراد الشاشة الحاضنة الجديدة *** ---
import 'screens/main_screen_holder.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );
  await MobileAds.instance.initialize();
  await AdManager.initialize();
  runApp(const HiveLogBeeApp());
}

class HiveLogBeeApp extends StatelessWidget {
  const HiveLogBeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()..loadSettings()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HiveProvider()),
        ChangeNotifierProvider(create: (_) => InspectionProvider()),
        ChangeNotifierProvider(create: (_) => TreatmentProvider()),
        ChangeNotifierProvider(create: (_) => ProductionProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'HiveLog Bee',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            locale: settings.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Consumer<AuthProvider>(
              builder: (context, auth, child) {
                if (auth.isLoading) {
                  return const Scaffold(
                    backgroundColor: AppTheme.primaryYellow,
                    body: Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.darkBrown,
                      ),
                    ),
                  );
                }

                if (auth.isAuthenticated) {
                  // --- *** 2. استخدام الشاشة الحاضنة كنقطة بداية *** ---
                  return const MainScreenHolder();
                } else {
                  return const LoginScreen();
                }
              },
            ),
          );
        },
      ),
    );
  }
}

// هذا الـ extension لم يعد ضروريًا
// extension on SettingsProvider {
//   Locale? get locale => Locale(language);
// }
