import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('te')
  ];

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @teacherDashboard.
  ///
  /// In en, this message translates to:
  /// **'Teacher Dashboard'**
  String get teacherDashboard;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @children.
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get children;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @intervene.
  ///
  /// In en, this message translates to:
  /// **'Intervene'**
  String get intervene;

  /// No description provided for @insights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @chatbotTitle.
  ///
  /// In en, this message translates to:
  /// **'Chatbot'**
  String get chatbotTitle;

  /// No description provided for @chatbotPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get chatbotPlaceholder;

  /// No description provided for @helplineTitle.
  ///
  /// In en, this message translates to:
  /// **'Helpline'**
  String get helplineTitle;

  /// No description provided for @callSupervisor.
  ///
  /// In en, this message translates to:
  /// **'Call Supervisor'**
  String get callSupervisor;

  /// No description provided for @emailSupport.
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get emailSupport;

  /// No description provided for @whatsappSupport.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Support'**
  String get whatsappSupport;

  /// No description provided for @nearestPhc.
  ///
  /// In en, this message translates to:
  /// **'Nearest PHC'**
  String get nearestPhc;

  /// No description provided for @emergencyContact.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact'**
  String get emergencyContact;

  /// No description provided for @selectRole.
  ///
  /// In en, this message translates to:
  /// **'Select Role'**
  String get selectRole;

  /// No description provided for @anganwadiTeacher.
  ///
  /// In en, this message translates to:
  /// **'Anganwadi Teacher'**
  String get anganwadiTeacher;

  /// No description provided for @selectDistrict.
  ///
  /// In en, this message translates to:
  /// **'Select District'**
  String get selectDistrict;

  /// No description provided for @selectVillage.
  ///
  /// In en, this message translates to:
  /// **'Select Village'**
  String get selectVillage;

  /// No description provided for @userId.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get userId;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcome;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @startMonitoring.
  ///
  /// In en, this message translates to:
  /// **'Start monitoring child health with these quick actions.'**
  String get startMonitoring;

  /// No description provided for @growth.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get growth;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// No description provided for @childProfiles.
  ///
  /// In en, this message translates to:
  /// **'Child Profiles'**
  String get childProfiles;

  /// No description provided for @addChild.
  ///
  /// In en, this message translates to:
  /// **'Add Child'**
  String get addChild;

  /// No description provided for @growthData.
  ///
  /// In en, this message translates to:
  /// **'Growth Data'**
  String get growthData;

  /// No description provided for @adminPanel.
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get adminPanel;

  /// No description provided for @centralConsole.
  ///
  /// In en, this message translates to:
  /// **'Central Monitoring Console'**
  String get centralConsole;

  /// No description provided for @realtimeOverview.
  ///
  /// In en, this message translates to:
  /// **'Real-time overview of all connected schools'**
  String get realtimeOverview;

  /// No description provided for @totalSchools.
  ///
  /// In en, this message translates to:
  /// **'Total Schools'**
  String get totalSchools;

  /// No description provided for @childrenMonitored.
  ///
  /// In en, this message translates to:
  /// **'Children Monitored'**
  String get childrenMonitored;

  /// No description provided for @highRiskCases.
  ///
  /// In en, this message translates to:
  /// **'High Risk Cases'**
  String get highRiskCases;

  /// No description provided for @malnutrition.
  ///
  /// In en, this message translates to:
  /// **'Malnutrition'**
  String get malnutrition;

  /// No description provided for @feverAlerts.
  ///
  /// In en, this message translates to:
  /// **'Fever Alerts'**
  String get feverAlerts;

  /// No description provided for @envIssues.
  ///
  /// In en, this message translates to:
  /// **'Env. Issues'**
  String get envIssues;

  /// No description provided for @highRiskChildren.
  ///
  /// In en, this message translates to:
  /// **'High Risk Children (Action Required)'**
  String get highRiskChildren;

  /// No description provided for @exportExcel.
  ///
  /// In en, this message translates to:
  /// **'Export Excel'**
  String get exportExcel;

  /// No description provided for @riskScore.
  ///
  /// In en, this message translates to:
  /// **'Risk Score'**
  String get riskScore;

  /// No description provided for @generatingReport.
  ///
  /// In en, this message translates to:
  /// **'Generating Excel Report... Please wait.'**
  String get generatingReport;

  /// No description provided for @exportSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Export Successful'**
  String get exportSuccessful;

  /// No description provided for @reportGenerated.
  ///
  /// In en, this message translates to:
  /// **'Report generated'**
  String get reportGenerated;

  /// No description provided for @fileSaved.
  ///
  /// In en, this message translates to:
  /// **'File saved to device downloads.'**
  String get fileSaved;

  /// No description provided for @openFile.
  ///
  /// In en, this message translates to:
  /// **'Open File'**
  String get openFile;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @assessments.
  ///
  /// In en, this message translates to:
  /// **'Assessments'**
  String get assessments;

  /// No description provided for @interventions.
  ///
  /// In en, this message translates to:
  /// **'Interventions'**
  String get interventions;

  /// No description provided for @redFlags.
  ///
  /// In en, this message translates to:
  /// **'Red Flags'**
  String get redFlags;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @highRisk.
  ///
  /// In en, this message translates to:
  /// **'High Risk'**
  String get highRisk;

  /// No description provided for @lastVisitReminder.
  ///
  /// In en, this message translates to:
  /// **'children not seen in >30 days'**
  String get lastVisitReminder;

  /// No description provided for @scheduleVisit.
  ///
  /// In en, this message translates to:
  /// **'Schedule a home visit soon.'**
  String get scheduleVisit;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'VIEW'**
  String get view;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @quickAdd.
  ///
  /// In en, this message translates to:
  /// **'Quick Add'**
  String get quickAdd;

  /// No description provided for @scanDocument.
  ///
  /// In en, this message translates to:
  /// **'Scan Document'**
  String get scanDocument;

  /// No description provided for @autofillId.
  ///
  /// In en, this message translates to:
  /// **'Auto-fill details from ID card'**
  String get autofillId;

  /// No description provided for @quickAddFast.
  ///
  /// In en, this message translates to:
  /// **'Quick Add (Ultra Fast)'**
  String get quickAddFast;

  /// No description provided for @enterDetailsOnly.
  ///
  /// In en, this message translates to:
  /// **'Enter Name, Age, Weight only'**
  String get enterDetailsOnly;

  /// No description provided for @selectMode.
  ///
  /// In en, this message translates to:
  /// **'Select Mode'**
  String get selectMode;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @classroom.
  ///
  /// In en, this message translates to:
  /// **'Classroom'**
  String get classroom;

  /// No description provided for @featureUnderDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Feature under development'**
  String get featureUnderDevelopment;

  /// No description provided for @noAlerts.
  ///
  /// In en, this message translates to:
  /// **'No alerts at this time'**
  String get noAlerts;

  /// No description provided for @allMonitored.
  ///
  /// In en, this message translates to:
  /// **'All children are being monitored.'**
  String get allMonitored;

  /// No description provided for @childAlerts.
  ///
  /// In en, this message translates to:
  /// **'Child Alerts'**
  String get childAlerts;

  /// No description provided for @alertsAttention.
  ///
  /// In en, this message translates to:
  /// **'alerts require attention'**
  String get alertsAttention;

  /// No description provided for @riskHigh.
  ///
  /// In en, this message translates to:
  /// **'High Risk'**
  String get riskHigh;

  /// No description provided for @riskModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get riskModerate;

  /// No description provided for @riskMild.
  ///
  /// In en, this message translates to:
  /// **'Mild'**
  String get riskMild;

  /// No description provided for @riskNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get riskNormal;

  /// No description provided for @interventionRequired.
  ///
  /// In en, this message translates to:
  /// **'Intervention Plan'**
  String get interventionRequired;

  /// No description provided for @noInterventionRequired.
  ///
  /// In en, this message translates to:
  /// **'No Intervention Required'**
  String get noInterventionRequired;

  /// No description provided for @savePlan.
  ///
  /// In en, this message translates to:
  /// **'Save Plan'**
  String get savePlan;

  /// No description provided for @suggestedExercises.
  ///
  /// In en, this message translates to:
  /// **'Suggested Exercises'**
  String get suggestedExercises;

  /// No description provided for @referralRequired.
  ///
  /// In en, this message translates to:
  /// **'Referral Required'**
  String get referralRequired;

  /// No description provided for @followUpSchedule.
  ///
  /// In en, this message translates to:
  /// **'Follow-up Schedule'**
  String get followUpSchedule;

  /// No description provided for @tapToSchedule.
  ///
  /// In en, this message translates to:
  /// **'Tap to schedule follow-up visit'**
  String get tapToSchedule;

  /// No description provided for @followUpOn.
  ///
  /// In en, this message translates to:
  /// **'Follow-up on'**
  String get followUpOn;

  /// No description provided for @scanDocSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-fill details from ID card'**
  String get scanDocSubtitle;

  /// No description provided for @quickAddSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter Name, Age, Weight only'**
  String get quickAddSubtitle;

  /// No description provided for @riskHighHeartRate.
  ///
  /// In en, this message translates to:
  /// **'High Heart Rate'**
  String get riskHighHeartRate;

  /// No description provided for @riskLowSpo2.
  ///
  /// In en, this message translates to:
  /// **'Low SpO2'**
  String get riskLowSpo2;

  /// No description provided for @riskSevereMalnutrition.
  ///
  /// In en, this message translates to:
  /// **'Severe Malnutrition'**
  String get riskSevereMalnutrition;

  /// No description provided for @riskHighFever.
  ///
  /// In en, this message translates to:
  /// **'High Fever'**
  String get riskHighFever;

  /// No description provided for @riskIrregularEcg.
  ///
  /// In en, this message translates to:
  /// **'Irregular ECG'**
  String get riskIrregularEcg;

  /// No description provided for @ageLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get ageLabel;

  /// No description provided for @idLabel.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get idLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @startIntervention.
  ///
  /// In en, this message translates to:
  /// **'Start Intervention'**
  String get startIntervention;

  /// No description provided for @interventionSaved.
  ///
  /// In en, this message translates to:
  /// **'Intervention plan saved for'**
  String get interventionSaved;

  /// No description provided for @exercisesHearing.
  ///
  /// In en, this message translates to:
  /// **'Sound localization games|Music and rhythm activities|Name-calling response exercises|Follow simple verbal commands'**
  String get exercisesHearing;

  /// No description provided for @exercisesSpeech.
  ///
  /// In en, this message translates to:
  /// **'Daily storytelling sessions|Repeat-after-me activities|Singing nursery rhymes|Picture naming games|Encourage conversation during play'**
  String get exercisesSpeech;

  /// No description provided for @exercisesMotor.
  ///
  /// In en, this message translates to:
  /// **'Crawling obstacle courses|Ball rolling/throwing games|Standing with support practice|Hand-eye coordination activities|Walking assistance exercises'**
  String get exercisesMotor;

  /// No description provided for @exercisesNutrition.
  ///
  /// In en, this message translates to:
  /// **'Regular meal schedule (5-6 times daily)|High-protein foods (dal, eggs, milk)|Fresh fruits and vegetables|Monitor weight weekly|Consult nutritionist for meal plan'**
  String get exercisesNutrition;

  /// No description provided for @exercisesDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Shape sorting activities|Color recognition games|Building blocks play|Interactive puzzle solving|Social interaction with peers'**
  String get exercisesDevelopment;

  /// No description provided for @exercisesDefault.
  ///
  /// In en, this message translates to:
  /// **'Regular play activities|Interactive games|Daily monitoring'**
  String get exercisesDefault;

  /// No description provided for @referralHearing.
  ///
  /// In en, this message translates to:
  /// **'Refer to Audiologist at nearest PHC'**
  String get referralHearing;

  /// No description provided for @referralSpeech.
  ///
  /// In en, this message translates to:
  /// **'Refer to Speech Therapist immediately'**
  String get referralSpeech;

  /// No description provided for @referralMotor.
  ///
  /// In en, this message translates to:
  /// **'Refer to Pediatric Physiotherapist'**
  String get referralMotor;

  /// No description provided for @referralNutrition.
  ///
  /// In en, this message translates to:
  /// **'Immediate medical intervention at PHC'**
  String get referralNutrition;

  /// No description provided for @referralDefault.
  ///
  /// In en, this message translates to:
  /// **'Consult with Medical Officer at PHC'**
  String get referralDefault;

  /// No description provided for @offlineModeActive.
  ///
  /// In en, this message translates to:
  /// **'Offline Mode Active - Data saving locally'**
  String get offlineModeActive;

  /// No description provided for @startMonitoringSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start monitoring child health with these quick actions.'**
  String get startMonitoringSubtitle;

  /// No description provided for @startScreening.
  ///
  /// In en, this message translates to:
  /// **'Start Screening'**
  String get startScreening;

  /// No description provided for @selectAssessmentType.
  ///
  /// In en, this message translates to:
  /// **'Select an assessment type below'**
  String get selectAssessmentType;

  /// No description provided for @aiPoweredScreenings.
  ///
  /// In en, this message translates to:
  /// **'AI Powered Screenings'**
  String get aiPoweredScreenings;

  /// No description provided for @motorDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Motor Development'**
  String get motorDevelopment;

  /// No description provided for @poseDetection.
  ///
  /// In en, this message translates to:
  /// **'Pose Detection'**
  String get poseDetection;

  /// No description provided for @hearingTest.
  ///
  /// In en, this message translates to:
  /// **'Hearing Test'**
  String get hearingTest;

  /// No description provided for @audioToneAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Audio Tone Analysis'**
  String get audioToneAnalysis;

  /// No description provided for @speechAndFluency.
  ///
  /// In en, this message translates to:
  /// **'Speech & Fluency'**
  String get speechAndFluency;

  /// No description provided for @voiceAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Voice Analysis'**
  String get voiceAnalysis;

  /// No description provided for @physicalHealth.
  ///
  /// In en, this message translates to:
  /// **'Physical Health'**
  String get physicalHealth;

  /// No description provided for @bodyAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Body Analysis (Future)'**
  String get bodyAnalysis;

  /// No description provided for @generalAssessment.
  ///
  /// In en, this message translates to:
  /// **'General Assessment (Standard)'**
  String get generalAssessment;

  /// No description provided for @chooseAgeRange.
  ///
  /// In en, this message translates to:
  /// **'Choose Age Range'**
  String get chooseAgeRange;

  /// No description provided for @noChildrenFound.
  ///
  /// In en, this message translates to:
  /// **'No children found'**
  String get noChildrenFound;

  /// No description provided for @plzSelectAge.
  ///
  /// In en, this message translates to:
  /// **'Please select an age group first.'**
  String get plzSelectAge;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @loadingData.
  ///
  /// In en, this message translates to:
  /// **'Loading data...'**
  String get loadingData;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available.'**
  String get noDataAvailable;

  /// No description provided for @selectAge.
  ///
  /// In en, this message translates to:
  /// **'Select Age Range'**
  String get selectAge;

  /// No description provided for @selectChild.
  ///
  /// In en, this message translates to:
  /// **'Select Child'**
  String get selectChild;

  /// No description provided for @motorSkills.
  ///
  /// In en, this message translates to:
  /// **'Motor Skills'**
  String get motorSkills;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @village.
  ///
  /// In en, this message translates to:
  /// **'Village'**
  String get village;

  /// No description provided for @childHealthDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Child Health & Development'**
  String get childHealthDevelopment;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @searchChild.
  ///
  /// In en, this message translates to:
  /// **'Search child by name...'**
  String get searchChild;

  /// No description provided for @totalChildren.
  ///
  /// In en, this message translates to:
  /// **'Total Children'**
  String get totalChildren;

  /// No description provided for @needAssessment.
  ///
  /// In en, this message translates to:
  /// **'Need Assessment'**
  String get needAssessment;

  /// No description provided for @atRisk.
  ///
  /// In en, this message translates to:
  /// **'At Risk'**
  String get atRisk;

  /// No description provided for @addChildPrompt.
  ///
  /// In en, this message translates to:
  /// **'Add a child to get started'**
  String get addChildPrompt;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @healthDevelopmentSuite.
  ///
  /// In en, this message translates to:
  /// **'HEALTH & DEVELOPMENT SUITE'**
  String get healthDevelopmentSuite;

  /// No description provided for @heartRateVitals.
  ///
  /// In en, this message translates to:
  /// **'HEART RATE & VITALS (LIVE)'**
  String get heartRateVitals;

  /// No description provided for @visionTest.
  ///
  /// In en, this message translates to:
  /// **'VISION TEST'**
  String get visionTest;

  /// No description provided for @noAssessment.
  ///
  /// In en, this message translates to:
  /// **'NO ASSESSMENT'**
  String get noAssessment;

  /// No description provided for @addNewChild.
  ///
  /// In en, this message translates to:
  /// **'Add New Child'**
  String get addNewChild;

  /// No description provided for @childName.
  ///
  /// In en, this message translates to:
  /// **'Child Name'**
  String get childName;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth (YYYY-MM-DD)'**
  String get dateOfBirth;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @added.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get added;

  /// No description provided for @filterOptions.
  ///
  /// In en, this message translates to:
  /// **'Filter Options'**
  String get filterOptions;

  /// No description provided for @allChildren.
  ///
  /// In en, this message translates to:
  /// **'All Children'**
  String get allChildren;

  /// No description provided for @mediumRisk.
  ///
  /// In en, this message translates to:
  /// **'Medium Risk'**
  String get mediumRisk;

  /// No description provided for @lowRisk.
  ///
  /// In en, this message translates to:
  /// **'Low Risk'**
  String get lowRisk;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @developmental.
  ///
  /// In en, this message translates to:
  /// **'Developmental'**
  String get developmental;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
