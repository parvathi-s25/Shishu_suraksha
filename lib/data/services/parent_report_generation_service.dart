
import '../../core/data/models/child_model.dart'
    hide
        Activity,
        ActivitySession,
        ActivityCategory,
        ActivityDifficulty,
        ActivityMaterial,
        ProgressMilestone;
import '../models/assessment_models.dart';
import '../models/assessment_result_models.dart';
import '../models/intervention_models.dart';

/// Parent Report Generation Service
/// 
/// Generates child assessment reports for parent/caregiver communication.
/// Reports are designed to be simple, non-technical, and actionable.
/// Supports multiple languages.
class ParentReportGenerationService {
  
  // Risk level descriptions for parents (simple language)
  static const Map<String, Map<String, String>> riskDescriptions = {
    'en': {
      'low': 'Your child is developing well for their age. Keep up the great work!',
      'medium':
          'Your child shows some areas that need extra practice. We have activities to help.',
      'high':
          'Your child needs special support. We recommend seeing a specialist doctor.',
    },
    'hi': {
      'low': 'आपका बच्चा अपनी उम्र के लिए ठीक से विकसित हो रहा है। बढ़िया काम जारी रखें।',
      'medium': 'आपके बच्चे में कुछ ऐसे क्षेत्र हैं जिन्हें अतिरिक्त अभ्यास की आवश्यकता है।',
      'high':
          'आपके बच्चे को विशेष समर्थन की आवश्यकता है। हम किसी विशेषज्ञ डॉक्टर को देखने की सलाह देते हैं।',
    },
    'te': {
      'low': 'మీ సంतానం వయస్సుకు సరిగ్గా ఆధ్యుత్వంతో ఉన్నారు. గొప్ప పని కొనసాగించండి.',
      'medium': 'మీ సంతానకు కొన్ని ప్రాంతాలకు అదనపు సాధన అవసరం. మేము సహాయక కార్యకలాపాలను కలిగి ఉన్నాము.',
      'high':
          'మీ సంతానకు ప్రత్యేక సమర్థన అవసరం. మేము ఒక నిపుణ డాక్టర్‌ను చూడాలని సిఫారసు చేస్తున్నాము.',
    },
  };

  /// Generates parent-friendly assessment report
  static ParentAssessmentReport generateParentReport({
    required ComprehensiveAssessmentResult assessmentResult,
    required ChildModel child,
    required String language, // 'en', 'hi', 'te', etc.
    required String region,
  }) {
    final riskText = _getRiskLevelDescription(
      assessmentResult.overallRiskLevel,
      language,
    );

    final scores = _formatScoresForParents(assessmentResult);

    final recommendations = _generateParentRecommendations(
      assessmentResult: assessmentResult,
      language: language,
    );

    final activitySuggestions = _getTop5ActivitySuggestions(
      assessmentResult: assessmentResult,
      region: region,
    );

    return ParentAssessmentReport(
      childId: child.id,
      childName: child.name,
      reportDate: DateTime.now(),
      childAge: '${assessmentResult.chronologicalAgeMonths ~/ 12} years ${assessmentResult.chronologicalAgeMonths % 12} months',
      riskLevel: assessmentResult.overallRiskLevel,
      riskLevelDescription: riskText,
      developmentalScores: scores,
      keyStrengths: _identifyStrengths(assessmentResult),
      areasForImprovement:
          _identifyAreasForImprovement(assessmentResult),
      topRecommendations: recommendations,
      suggestedActivitiesForHome: activitySuggestions,
      nextFollowUpDate: assessmentResult.nextAssessmentDate ?? DateTime.now(),
      language: language,
    );
  }

  /// Generates SMS/WhatsApp activity reminder
  static String generateActivityReminder({
    required Activity activity,
    required String childName,
    required String language,
  }) {
    final example = switch (language) {
      'hi' => 'हाय! कृपया ${childName} के साथ "${activity.title['hi']}" खेल कल 15 मिनट के लिए खेलें। धन्यवाद!',
      'te' => 'హాయ్! దయచేసి ${childName} తో "${activity.title['te']}" 15 నిమిషాల పాటు చేయండి.',
      'ta' => 'வணக்கம்! ${childName} உடன் "${activity.title['en']}" ${activity.durationMinutes} நிమிషங்களை செய்யுங்கள்.',
      _ =>
        'Hi! Please do "${activity.title['en']}" with ${childName} for ${activity.durationMinutes} minutes. Thanks!',
    };

    return example;
  }

  /// Generates weekly progress summary for parent
  static String generateWeeklyProgressSummary({
    required String childName,
    required List<ActivitySession> weeklyActivities,
    required double averageEngagement,
    required double averagePerformance,
    required String language,
  }) {
    final completedCount =
        weeklyActivities.where((a) => a.completed).length;

    return switch (language) {
      'hi' => '''
${childName} की साप्ताहिक प्रगति:
✓ $completedCount गतिविधियाँ पूरी हुईं
😊 औसत भाग लेना: ${averageEngagement.toStringAsFixed(0)}%
⭐ प्रदर्शन: ${averagePerformance.toStringAsFixed(0)}%

अच्छा काम जारी रखें! 🎉
''',
      'te' => '''
${childName} సాప్తాహిక పురోగति:
✓ $completedCount కార్యకలాపాలు పూర్తయాయి
😊 సగటు పాల్గొనిక: ${averageEngagement.toStringAsFixed(0)}%
⭐ పనితీరు: ${averagePerformance.toStringAsFixed(0)}%

గొప్ప పని కొనసాగించండి! 🎉
''',
      _ => '''
${childName}'s Weekly Progress:
✓ $completedCount activities completed
😊 Average engagement: ${averageEngagement.toStringAsFixed(0)}%
⭐ Performance: ${averagePerformance.toStringAsFixed(0)}%

Keep up the great work! 🎉
''',
    };
  }

  // ========================================================================
  // PRIVATE HELPER METHODS
  // ========================================================================

  static String _getRiskLevelDescription(
    RiskLevel riskLevel,
    String language,
  ) {
    final levelKey = riskLevel.toString().split('.').last.toLowerCase();
    return riskDescriptions[language]?[levelKey] ??
        riskDescriptions['en']![levelKey]!;
  }

  static Map<String, String> _formatScoresForParents(
    ComprehensiveAssessmentResult result,
  ) {
    return {
      'Motor Skills': _scoreToSimpleFormat(result.motorScore),
      'Speech & Language': _scoreToSimpleFormat(result.speechScore),
      'Thinking & Learning': _scoreToSimpleFormat(result.cognitiveScore),
      'Social & Emotions': _scoreToSimpleFormat(result.socialEmotionalScore),
      'Health': _scoreToSimpleFormat(result.healthScore),
    };
  }

  static String _scoreToSimpleFormat(double score) {
    if (score >= 80) {
      return '✓ Excellent';
    } else if (score >= 60) {
      return '✓ Good';
    } else if (score >= 40) {
      return '⚠️ Needs practice';
    } else {
      return '🔴 Needs help';
    }
  }

  static List<String> _generateParentRecommendations({
    required ComprehensiveAssessmentResult assessmentResult,
    required String language,
  }) {
    final recommendations = <String>[];

    const enRecommendations = [
      'Play games with your child every day (at least 30 minutes)',
      'Talk to your child and listen to them speak',
      'Read or tell stories together',
      'Give your child time to play with other children',
      'Provide healthy food (fruits, vegetables, eggs, milk)',
      'Make sure your child gets enough sleep (10-12 hours)',
    ];

    const hiRecommendations = [
      'हर दिन अपने बच्चे के साथ खेलें (कम से कम 30 मिनट)',
      'अपने बच्चे से बात करें और उन्हें सुनें',
      'एक साथ कहानियां पढ़ें या सुनाएं',
      'अपने बच्चे को अन्य बच्चों के साथ खेलने का समय दें',
      'स्वस्थ खाना दें (फल, सब्जियां, अंडे, दूध)',
      'सुनिश्चित करें कि आपका बच्चा पर्याप्त नींद ले (10-12 घंटे)',
    ];

    const teRecommendations = [
      'ప్రతిరోజూ మీ శిశువுతో ఆట ఆడండి (కనీసం 30 నిమిషాలు)',
      'మీ బిడ్డతో మాట్లాడండి మరియు వారు మాట్లాడటం వినండి',
      'కథలను కలిసి చదవండి లేదా చెప్పండి',
      'మీ బిడ్డకు ఇతర పిల్లలతో ఆడటానికి సమయం ఇవండి',
      'ఆరోగ్యకరమైన ఆहार ఇవండి (పండ్లు, కూరగాయలు, గుడ్డు, పాలు)',
      'మీ బిడ్డ తగినంత నిద్ర పొందేలా చూసుకోండి (10-12 గంటలు)',
    ];

    final currentRecommendations = switch (language) {
      'hi' => hiRecommendations,
      'te' => teRecommendations,
      _ => enRecommendations,
    };

    // Add personalized recommendations based on weak areas
    if (assessmentResult.motorScore < 60) {
      currentRecommendations.add(
        language == 'hi'
            ? 'अपने बच्चे को अधिक खेल और व्यायाम करने दें'
            : language == 'te'
                ? 'మీ బిడ్డకు ఎక్కువ ఆట మరియు వ్యాయామం చేయనివ్వండి'
                : 'Let your child play and exercise more',
      );
    }

    if (assessmentResult.speechScore < 60) {
      currentRecommendations.add(
        language == 'hi'
            ? 'अपने बच्चे से बहुत बात करें और गीत गाएं'
            : language == 'te'
                ? 'అपনके బిడ్డకు నిరంతరం కిందటూ చెప్పండి మరియు పాటలు పాడండి'
                : 'Talk to your child constantly and sing songs',
      );
    }

    return currentRecommendations;
  }

  static List<ActivityForParent> _getTop5ActivitySuggestions({
    required ComprehensiveAssessmentResult assessmentResult,
    required String region,
  }) {
    // Placeholder - would be populated with real activity data
    return [
      ActivityForParent(
        title: 'Playing with blocks or building toys',
        description: 'Helps develop thinking and planning skills',
        duration: 20,
        materials: 'Blocks, cups, or wooden pieces',
        howToDoIt: 'Let your child stack, build, and knock down. Ask questions like "What did you build?"',
      ),
      ActivityForParent(
        title: 'Singing and dancing together',
        description: 'Helps language and physical development',
        duration: 15,
        materials: 'No special materials needed',
        howToDoIt: 'Play simple songs or nursery rhymes. Move and dance together.',
      ),
      ActivityForParent(
        title: 'Picture talking',
        description: 'Builds vocabulary and language skills',
        duration: 15,
        materials: 'Pictures from magazines or newspapers',
        howToDoIt: 'Show pictures and ask "What is this?" Help your child name things.',
      ),
      ActivityForParent(
        title: 'Playing with sand or water',
        description: 'Develops fine motor skills and creativity',
        duration: 20,
        materials: 'Sand, water, cups, spoons',
        howToDoIt: 'Let your child play freely. Talk about what they are doing.',
      ),
      ActivityForParent(
        title: 'Ball games',
        description: 'Develops coordination and motor skills',
        duration: 15,
        materials: 'A soft ball or rolled cloth',
        howToDoIt: 'Roll or throw the ball gently. Let your child catch and throw back.',
      ),
    ];
  }

  static List<String> _identifyStrengths(
    ComprehensiveAssessmentResult result,
  ) {
    const strengths = <String>[];

    if (result.motorScore >= 70) {
      strengths.add('Good movement and coordination');
    }
    if (result.speechScore >= 70) {
      strengths.add('Good language skills');
    }
    if (result.cognitiveScore >= 70) {
      strengths.add('Good learning ability');
    }
    if (result.socialEmotionalScore >= 70) {
      strengths.add('Good social skills');
    }

    return strengths.isEmpty ? ['Your child has their own unique strengths'] : strengths;
  }

  static List<String> _identifyAreasForImprovement(
    ComprehensiveAssessmentResult result,
  ) {
    const areas = <String>[];

    if (result.motorScore < 60) {
      areas.add('Movement and coordination (balance, running, jumping)');
    }
    if (result.speechScore < 60) {
      areas.add('Speech and language (talking, understanding words)');
    }
    if (result.cognitiveScore < 60) {
      areas.add('Thinking and learning');
    }
    if (result.socialEmotionalScore < 60) {
      areas.add('Playing and interacting with others');
    }

    return areas;
  }
}

// ============================================================================
// HELPER MODELS
// ============================================================================

/// Parent-friendly assessment report
class ParentAssessmentReport {
  final String childId;
  final String childName;
  final DateTime reportDate;
  final String childAge;
  final RiskLevel riskLevel;
  final String riskLevelDescription;
  final Map<String, String> developmentalScores;
  final List<String> keyStrengths;
  final List<String> areasForImprovement;
  final List<String> topRecommendations;
  final List<ActivityForParent> suggestedActivitiesForHome;
  final DateTime nextFollowUpDate;
  final String language;

  ParentAssessmentReport({
    required this.childId,
    required this.childName,
    required this.reportDate,
    required this.childAge,
    required this.riskLevel,
    required this.riskLevelDescription,
    required this.developmentalScores,
    required this.keyStrengths,
    required this.areasForImprovement,
    required this.topRecommendations,
    required this.suggestedActivitiesForHome,
    required this.nextFollowUpDate,
    required this.language,
  });

  String generateSimpleText() {
    final buffer = StringBuffer();

    buffer.writeln('==== $childName\'s Development Report ====\n');
    buffer.writeln('Age: $childAge');
    buffer.writeln('Report Date: ${reportDate.day}/${reportDate.month}/${reportDate.year}\n');

    buffer.writeln('Overall Status: $riskLevelDescription\n');

    buffer.writeln('Skills Review:');
    developmentalScores.forEach((skill, score) {
      buffer.writeln('• $skill: $score');
    });

    buffer.writeln('\nWhat your child does well:');
    for (final strength in keyStrengths) {
      buffer.writeln('✓ $strength');
    }

    buffer.writeln('\nAreas to practice:');
    for (final area in areasForImprovement) {
      buffer.writeln('• $area');
    }

    buffer.writeln('\nRecommendations:');
    for (int i = 0; i < topRecommendations.length; i++) {
      buffer.writeln('${i + 1}. ${topRecommendations[i]}');
    }

    buffer.writeln('\nSimple activities to do at home:');
    for (final activity in suggestedActivitiesForHome) {
      buffer.writeln('\n• ${activity.title}');
      buffer.writeln('  How: ${activity.howToDoIt}');
      buffer.writeln('  Time: ${activity.duration} minutes');
    }

    buffer.writeln('\n\nNext check-up: ${nextFollowUpDate.day}/${nextFollowUpDate.month}/${nextFollowUpDate.year}');

    return buffer.toString();
  }
}

/// Activity suggestion for parent
class ActivityForParent {
  final String title;
  final String description;
  final int duration; // in minutes
  final String materials;
  final String howToDoIt;

  ActivityForParent({
    required this.title,
    required this.description,
    required this.duration,
    required this.materials,
    required this.howToDoIt,
  });
}
