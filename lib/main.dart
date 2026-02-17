import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

import 'l10n/app_localizations.dart';
import 'localization/legacy_app_localizations.dart'; // For DataLocalizations
import 'ui/screens/splash/splash_screen.dart';
import 'ui/screens/opening/opening_animation_screen.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'ui/screens/auth/authentication_screen.dart';
import 'ui/screens/dashboard/teacher_dashboard.dart';
import 'core/services/data_service.dart';
import 'firebase_options.dart';
import 'models/child_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await dotenv.load(fileName: ".env");
  
  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(ChildModelAdapter());
  
  await Hive.openBox(AppConstants.kBoxSettings);
  await Hive.openBox(AppConstants.kBoxChildren);
  await Hive.openBox(AppConstants.kBoxAssessments);
  await Hive.openBox(AppConstants.kBoxPendingSync);

  // Initialize DataService
  DataService().init();

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

  void changeLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
    Hive.box(AppConstants.kBoxSettings).put(AppConstants.kKeyLanguage, locale.languageCode);
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
        "/dashboard": (_) => DashboardScreen(), // Verify this widget exists or update appropriately
      },
    );
  }
}

