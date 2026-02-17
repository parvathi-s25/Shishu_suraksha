import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'localization/legacy_app_localizations.dart'; // For DataLocalizations
import 'ui/screens/splash/splash_screen.dart';
import 'ui/screens/opening/opening_animation_screen.dart';
import 'ui/screens/auth/authentication_screen.dart';
import 'ui/screens/dashboard/teacher_dashboard.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/services/data_service.dart';
import 'app/theme/colors.dart';

import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");
  
  // Initialize Hive for Offline Mode
  await Hive.initFlutter();
  // Open boxes (tables)
  await Hive.openBox('settings');
  await Hive.openBox('children');
  await Hive.openBox('assessments');
  await Hive.openBox('pending_sync'); // For changes made offline

  // Initialize DataService for realtime counts
  DataService().init();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  static void setLocale(BuildContext context, Locale locale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLocale(locale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale("en");

  void changeLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: const [
        Locale("en"), Locale("te"),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        DataLocalizations.delegate, // For dynamic data like/districts
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Roboto', // Use a clean font
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.textPrimary),
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.border),
          ),
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: AppColors.primary, 
          secondary: AppColors.secondary
        ),
      ),
      home: OpeningAnimationScreen(),
      routes: {
        "/auth": (_) => AuthenticationScreen(),
        "/dashboard": (_) => DashboardScreen(),
      },
    );
  }
}

