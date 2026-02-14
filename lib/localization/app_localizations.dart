import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;
  late Map<String, dynamic> _localizedStrings;

  AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  Future<bool> load() async {
    String jsonString = await rootBundle.loadString(
      "assets/lang/${locale.languageCode}.json",
    );

    _localizedStrings = json.decode(jsonString);
    return true;
  }

  String t(String key) {
    return _localizedStrings[key] ?? key;
  }

  List<String> list(String key) {
    return List<String>.from(_localizedStrings[key]);
  }

  // Return a Map<String, String> for key-value pairs (like Districts)
  Map<String, String> get districts {
    try {
      return Map<String, String>.from(_localizedStrings['districts'] as Map);
    } catch (e) {
      return {};
    }
  }

  // Restore Helper for Maps of Lists (Villages, UserIDs)
  Map<String, List<String>> map(String key) {
    return Map<String, List<String>>.from(
      (_localizedStrings[key] as Map).map(
        (k, v) => MapEntry(k, List<String>.from(v)),
      ),
    );
  }

  // Strict Getters for Authentication Screen
  String get login => t("login");
  String get role => t("select_role"); // Mapped to 'select_role' key
  String get admin => t("admin");
  String get anganwadiTeacher => t("anganwadi_teacher");
  String get district => t("select_district");
  String get village => t("select_village");
  String get userId => t("user_id");
  String get password => t("password");
  String get signIn => t("sign_in");

  // Dashboard Getters
  String get teacherDashboard => t("teacherDashboard");
  String get home => t("home");
  String get children => t("children");
  String get start => t("start");
  String get intervene => t("intervene");
  String get insights => t("insights");
  
  String get chatbotTitle => t("chatbot_title");
  String get chatbotPlaceholder => t("chatbot_placeholder");
  String get helplineTitle => t("helpline_title");
  String get callSupervisor => t("call_supervisor");
  String get emailSupport => t("email_support");
  String get whatsappSupport => t("whatsapp_support");
  String get nearestPhc => t("nearest_phc");
  String get emergencyContact => t("emergency_contact");

  // Splash Screen Getters
  String get select_language => t("select_language");
  String get get_started => t("get_started");

  // New Dashboard Getters
  String get welcome => t("welcome");
  String get goodMorning => t("goodMorning");
  String get goodAfternoon => t("goodAfternoon");
  String get goodEvening => t("goodEvening");

  String get startMonitoring => t("startMonitoring");
  String get growth => t("growth");
  String get reports => t("reports");
  String get alerts => t("alerts");
  String get childProfiles => t("childProfiles");
  String get addChild => t("addChild");
  String get growthData => t("growthData");
  String get adminPanel => t("adminPanel");
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return [
      "en","te","hi","ta","kn","ml","gu","mr","bn","pa","or"
    ].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localization = AppLocalizations(locale);
    await localization.load();
    return localization;
  }

  @override
  bool shouldReload(LocalizationsDelegate old) => false;
}
