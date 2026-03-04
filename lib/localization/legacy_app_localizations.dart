import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class DataLocalizations {
  final Locale locale;
  late Map<String, dynamic> _localizedStrings;

  DataLocalizations(this.locale);

  static const LocalizationsDelegate<DataLocalizations> delegate =
      _DataLocalizationsDelegate();

  static DataLocalizations of(BuildContext context) {
    return Localizations.of<DataLocalizations>(context, DataLocalizations)!;
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
  
  // Admin Dashboard
  String get centralConsole => t("central_console");
  String get realtimeOverview => t("realtime_overview");
  String get totalSchools => t("total_schools");
  String get childrenMonitored => t("children_monitored");
  String get highRiskCases => t("high_risk_cases");
  String get malnutrition => t("malnutrition");
  String get feverAlerts => t("fever_alerts");
  String get envIssues => t("env_issues");
  String get highRiskChildren => t("high_risk_children");
  String get exportExcel => t("export_excel");
  String get riskScore => t("risk_score");
  String get generatingReport => t("generating_report");
  String get exportSuccessful => t("export_successful");
  String get reportGenerated => t("report_generated");
  String get fileSaved => t("file_saved");
  String get openFile => t("open_file");
  String get close => t("close");

  // Shared / Teacher Dashboard
  String get overview => t("overview");
  String get schedule => t("schedule");
  String get quickActions => t("quick_actions");
  String get assessments => t("assessments");
  String get interventions => t("interventions");
  String get redFlags => t("red_flags");
  String get pending => t("pending");
  String get active => t("active");
  String get highRisk => t("high_risk");
  String get lastVisitReminder => t("last_visit_reminder");
  String get scheduleVisit => t("schedule_visit");
  String get view => t("view");
  String get tasks => t("tasks");
  String get profile => t("profile");
  String get helpCenter => t("help_center");
  String get quickAdd => t("quick_add");
  String get scanDocument => t("scan_document");
  String get autofillId => t("autofill_id");
  String get quickAddFast => t("quick_add_fast");
  String get enterDetailsOnly => t("enter_details_only");
  String get selectMode => t("select_mode");
  String get featureUnderDevelopment => t("feature_under_development");
  String get health => t("health");
  String get classroom => t("classroom");
  
  // Comprehensive Localization Keys
  String get noAlerts => t("no_alerts");
  String get allMonitored => t("all_monitored");
  String get childAlerts => t("child_alerts");
  String get alertsAttention => t("alerts_attention");
  String get riskHigh => t("risk_high");
  String get riskModerate => t("risk_moderate");
  String get riskMild => t("risk_mild");
  String get riskNormal => t("risk_normal");
  
  String get interventionRequired => t("intervention_required");
  String get noInterventionRequired => t("no_intervention_required");
  String get savePlan => t("save_plan");
  String get suggestedExercises => t("suggested_exercises");
  String get referralRequired => t("referral_required");
  String get followUpSchedule => t("follow_up_schedule");
  String get tapToSchedule => t("tap_to_schedule");
  String get followUpOn => t("follow_up_on");
  
  String get scanDocSubtitle => t("scan_doc_subtitle");
  String get quickAddSubtitle => t("quick_add_subtitle");
  
  String get riskHighHeartRate => t("risk_high_heart_rate");
  String get riskLowSpo2 => t("risk_low_spo2");
  String get riskSevereMalnutrition => t("risk_severe_malnutrition");
  String get riskHighFever => t("risk_high_fever");
  String get riskIrregularEcg => t("risk_irregular_ecg");
  
  String get ageLabel => t("age_label");
  String get idLabel => t("id_label");
  String get categoryLabel => t("category_label");
  String get startIntervention => t("start_intervention");
  
  String get interventionSaved => t("intervention_saved");
  
  String get exercisesHearing => t("exercises_hearing");
  String get exercisesSpeech => t("exercises_speech");
  String get exercisesMotor => t("exercises_motor");
  String get exercisesNutrition => t("exercises_nutrition");
  String get exercisesDevelopment => t("exercises_development");
  String get exercisesDefault => t("exercises_default");
  
  String get referralHearing => t("referral_hearing");
  String get referralSpeech => t("referral_speech");
  String get referralMotor => t("referral_motor");
  String get referralNutrition => t("referral_nutrition");
  String get referralDefault => t("referral_default");
}

class _DataLocalizationsDelegate
    extends LocalizationsDelegate<DataLocalizations> {
  const _DataLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return [
      "en","te","hi","ta","kn","ml","gu","mr","bn","pa","or"
    ].contains(locale.languageCode);
  }

  @override
  Future<DataLocalizations> load(Locale locale) async {
    DataLocalizations localization = DataLocalizations(locale);
    await localization.load();
    return localization;
  }

  @override
  bool shouldReload(LocalizationsDelegate old) => false;
}
