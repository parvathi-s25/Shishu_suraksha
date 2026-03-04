import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:shishu_suraksha/l10n/generated/app_localizations.dart';
import 'package:shishu_suraksha/localization/legacy_app_localizations.dart'; // For DataLocalizations
import 'package:shishu_suraksha/ui/screens/splash/splash_screen.dart';
import 'package:shishu_suraksha/ui/screens/opening/opening_animation_screen.dart';
import 'package:shishu_suraksha/core/theme/app_theme.dart';
import 'package:shishu_suraksha/core/constants/app_constants.dart';
import 'package:shishu_suraksha/ui/screens/auth/authentication_screen.dart';
import 'package:shishu_suraksha/ui/screens/dashboard/teacher_dashboard.dart';
import 'package:shishu_suraksha/services/db_service.dart';
import 'core/services/data_service.dart';
import 'firebase_options.dart';
import 'models/child_model.dart';

void main() async {
  print("Main: Starting app...");
  WidgetsFlutterBinding.ensureInitialized();
  
  print("Main: Initializing Firebase...");
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 5));
    print("Main: Firebase initialized.");
  } catch (e) {
    print("Main: Firebase initialization error or timeout: $e");
  }
  
  print("Main: Loading .env...");
  try {
    await dotenv.load(fileName: ".env");
    print("Main: .env loaded.");
  } catch (e) {
    print("Main: .env load error: $e");
  }
  
  // Initialize Hive
  print("Main: Initializing Hive...");
  await Hive.initFlutter();
  Hive.registerAdapter(ChildModelAdapter());
  
  await Hive.openBox(AppConstants.kBoxSettings);
  await Hive.openBox(AppConstants.kBoxChildren);
  await Hive.openBox(AppConstants.kBoxAssessments);
  await Hive.openBox(AppConstants.kBoxPendingSync);
  print("Main: Hive boxes opened.");

  // Initialize DataService
  print("Main: Initializing DataService...");
  // Ensure DB / static data updated on app launch (useful after installing new APK)
  await DBService.instance.ensureStaticDataUpToDate();
  DataService().init();
  print("Main: DataService initialized.");

  print("Main: Calling runApp...");
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  static void setLocale(BuildContext context, Locale locale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLocale(locale);
  }

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  Locale _locale = const Locale("en");

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final box = Hive.box(AppConstants.kBoxSettings);
    final String? languageCode = box.get(AppConstants.kKeyLanguage);
    if (languageCode != null) {
      setState(() {
        _locale = Locale(languageCode);
      });
    }
  }

  static const platform = MethodChannel('com.shishusuraksha/locale');

  void changeLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
    Hive.box(AppConstants.kBoxSettings).put(AppConstants.kKeyLanguage, locale.languageCode);
    
    // Sync with Native Android
    try {
      platform.invokeMethod('updateLocale', {'languageCode': locale.languageCode});
    } catch (e) {
      print("Failed to update native locale: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ShishuSuraksha AI',
      locale: _locale,
      supportedLocales: const [
        Locale("en"), 
        Locale("te"),
        Locale("hi"),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        DataLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.getThemeForLocale(_locale),
      home: const OpeningAnimationScreen(),
      routes: {
        "/auth": (_) => AuthenticationScreen(),
        "/dashboard": (_) => const DashboardScreen(), 
      },
    );
  }
}

