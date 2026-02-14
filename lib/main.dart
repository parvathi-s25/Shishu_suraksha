import 'package:flutter/material.dart';
import 'localization/app_localizations.dart';
import 'ui/screens/splash/splash_screen.dart';
import 'ui/screens/auth/authentication_screen.dart';
import 'ui/screens/dashboard/teacher_dashboard.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
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
        Locale("en"), Locale("te"), Locale("hi"), Locale("ta"),
        Locale("kn"), Locale("ml"), Locale("gu"), Locale("mr"),
        Locale("bn"), Locale("pa"), Locale("or"),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: SplashScreen(),
      routes: {
        "/auth": (_) => AuthenticationScreen(),
        "/dashboard": (_) => DashboardScreen(),
      },
    );
  }
}
