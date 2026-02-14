import '../models/intervention_models.dart';
import '../models/assessment_result_models.dart';

/// Intervention Recommendation Engine
/// 
/// Generates personalized intervention activity recommendations based on
/// comprehensive assessment results. Uses AI to match activities to child needs.
class InterventionRecommendationEngine {
  
  // Activity catalog (seed data - in production loaded from database)
  static final List<Activity> activityCatalog = _initializeActivityCatalog();

  /// Main recommendation engine
  /// 
  /// Input: Child's assessment result
  /// Output: Top 10 personalized activities ranked by expected impact
  static Future<PersonalizedInterventionPlan> generateInterventionPlan({
    required String childId,
    required ComprehensiveAssessmentResult assessmentResult,
    required String region, // for cultural adaptation
  }) async {
    final planId = 'PLAN_${childId}_${DateTime.now().millisecondsSinceEpoch}';
    
    // Identify priority areas based on assessment
    final priorityAreas =
        _identifyPriorityAreas(assessmentResult);

    // Filter activities by age and priority areas
    final candidateActivities = _filterActivitiesByAgeAndPriority(
      ageMonths: assessmentResult.chronologicalAgeMonths,
      priorityAreas: priorityAreas,
    );

    // Rank activities using ML-inspired scoring
    final rankedActivities = _rankActivitiesByExpectedImpact(
      activities: candidateActivities,
      assessmentResult: assessmentResult,
      region: region,
    );

    // Select top 10 activities
    final recommendedActivities = rankedActivities.take(10).toList();

    // Calculate intervention metrics
    final estimatedWeeklyHours = _calculateWeeklyHours(
      priorityAreas: priorityAreas,
      activityCount: recommendedActivities.length,
    );

    final expectedProgressRate = _estimateProgressRate(
      assessmentResult: assessmentResult,
      activityCount: recommendedActivities.length,
    );

    return PersonalizedInterventionPlan(
      planId: planId,
      childId: childId,
      createdDate: DateTime.now(),
      validUntil: DateTime.now().add(Duration(days: 30)),
      recommendedActivities: recommendedActivities,
      priorityAreas: priorityAreas,
      interventionRationale: _generateRationale(
        priorityAreas: priorityAreas,
        assessmentResult: assessmentResult,
      ),
      estimatedWeeklyHours: estimatedWeeklyHours,
      expectedProgressRate: expectedProgressRate,
      active: true,
      followUpAssessmentWeeks: assessmentResult.overallRiskLevel == RiskLevel.high ? 2 : 4,
    );
  }

  // ========================================================================
  // PRIVATE HELPER METHODS
  // ========================================================================

  static List<String> _identifyPriorityAreas(
    ComprehensiveAssessmentResult result,
  ) {
    final priorities = <String>[];

    // Threshold for identifying priority areas
    const priorityThreshold = 60.0;

    if (result.motorScore < priorityThreshold) {
      priorities.add('motor_skills');
    }
    if (result.speechScore < priorityThreshold) {
      priorities.add('speech_language');
    }
    if (result.cognitiveScore < priorityThreshold) {
      priorities.add('cognitive');
    }
    if (result.socialEmotionalScore < priorityThreshold) {
      priorities.add('social_emotional');
    }

    // If no priorities identified (all scores good), focus on enrichment
    if (priorities.isEmpty) {
      priorities.add('cognitive');
      priorities.add('creative');
    }

    return priorities;
  }

  static List<Activity> _filterActivitiesByAgeAndPriority({
    required int ageMonths,
    required List<String> priorityAreas,
  }) {
    return activityCatalog
        .where((activity) {
          // Age-appropriate
          final ageMatch =
              ageMonths >= activity.minAgeMonths &&
              ageMonths <= activity.maxAgeMonths;

          // Priority match
          final categoryMatch =
              activity.targetSkills.any((skill) => priorityAreas.contains(skill));

          return ageMatch && categoryMatch;
        })
        .toList();
  }

  static List<Activity> _rankActivitiesByExpectedImpact({
    required List<Activity> activities,
    required ComprehensiveAssessmentResult assessmentResult,
    required String region,
  }) {
    // Score each activity based on multiple factors
    final scoredActivities = activities.map((activity) {
      double score = 0;

      // 1. Impact on priority areas (40%)
      final impactScore =
          _calculateImpactScore(activity, assessmentResult);
      score += impactScore * 0.40;

      // 2. Cultural relevance (20%)
      final culturalRelevance =
          activity.culturalAdaptations.containsKey(region) ? 1.0 : 0.6;
      score += culturalRelevance * 0.20;

      // 3. Difficulty progression (15%)
      final difficultyScore =
          _calculateDifficultyScore(activity, assessmentResult);
      score += difficultyScore * 0.15;

      // 4. Engagement potential (15%)
      const engagementScore = 0.8; // Estimated
      score += engagementScore * 0.15;

      // 5. Material availability (10%)
      final materialScore =
          _calculateMaterialAvailability(activity);
      score += materialScore * 0.10;

      // Store score for sorting
      activity.recommendationScore = score;
      return activity;
    }).toList();

    // Sort by score (descending)
    scoredActivities.sort((a, b) =>
        (b.recommendationScore).compareTo(a.recommendationScore));

    return scoredActivities;
  }

  static double _calculateImpactScore(
    Activity activity,
    ComprehensiveAssessmentResult result,
  ) {
    // Higher impact on areas where child is weakest
    double impact = 0;
    int areas = 0;

    for (final skill in activity.targetSkills) {
      if (skill.contains('motor')) {
        impact += (100 - result.motorScore) / 100;
        areas++;
      }
      if (skill.contains('speech')) {
        impact += (100 - result.speechScore) / 100;
        areas++;
      }
      if (skill.contains('cognitive')) {
        impact += (100 - result.cognitiveScore) / 100;
        areas++;
      }
      if (skill.contains('social') || skill.contains('emotional')) {
        impact += (100 - result.socialEmotionalScore) / 100;
        areas++;
      }
    }

    return areas > 0 ? (impact / areas).clamp(0, 1) : 0.5;
  }

  static double _calculateDifficultyScore(
    Activity activity,
    ComprehensiveAssessmentResult result,
  ) {
    // Activities should be slightly challenging but achievable
    // "Zone of Proximal Development" principle

    final overallScore = result.overallDevelopmentalScore;

    const easyThreshold = 40.0;
    const mediumThreshold = 60.0;
    const hardThreshold = 80.0;

    double difficultyMatch = 0;

    if (overallScore < easyThreshold) {
      // Child needs easy activities
      difficultyMatch =
          (activity.difficulty == ActivityDifficulty.easy) ? 1.0 : 0.5;
    } else if (overallScore < mediumThreshold) {
      // Child needs medium activities
      difficultyMatch =
          (activity.difficulty == ActivityDifficulty.medium) ? 1.0 : 0.7;
    } else if (overallScore < hardThreshold) {
      // Child benefits from harder activities
      difficultyMatch =
          (activity.difficulty == ActivityDifficulty.hard) ? 1.0 : 0.8;
    } else {
      // High-performing child
      difficultyMatch =
          (activity.difficulty == ActivityDifficulty.hard) ? 1.0 : 0.6;
    }

    return difficultyMatch;
  }

  static double _calculateMaterialAvailability(Activity activity) {
    // Required materials lower availability score
    final requiredCount = activity.requiredMaterials.length;
    final optionalCount = activity.optionalMaterials.length;

    // Penalize activities needing many materials
    double score = 1.0;
    score -= (requiredCount * 0.1).clamp(0, 0.5);
    score -= (optionalCount * 0.02).clamp(0, 0.2);

    return score.clamp(0, 1);
  }

  static int _calculateWeeklyHours({
    required List<String> priorityAreas,
    required int activityCount,
  }) {
    // Base hours: 1 hour per priority area per week
    int baseHours = priorityAreas.length;

    // Additional hours based on number of activities
    int additionalHours = (activityCount / 5).ceil();

    return (baseHours + additionalHours).clamp(3, 10);
  }

  static double _estimateProgressRate({
    required ComprehensiveAssessmentResult assessmentResult,
    required int activityCount,
  }) {
    // Children with moderate delays show best progress
    final overallScore = assessmentResult.overallDevelopmentalScore;

    double baseRate = 0.3; // minimum expected progress

    if (overallScore >= 75) {
      baseRate = 0.3; // Minor improvements in typically developing child
    } else if (overallScore >= 50) {
      baseRate = 0.7; // Good progress potential
    } else if (overallScore >= 30) {
      baseRate = 0.5; // Moderate progress
    } else {
      baseRate = 0.3; // Severe delays may progress slower
    }

    // More activities = better outcomes
    final activityBonus =
        (activityCount / 10 * 0.2).clamp(0, 0.2);

    return (baseRate + activityBonus).clamp(0, 1);
  }

  static String _generateRationale({
    required List<String> priorityAreas,
    required ComprehensiveAssessmentResult assessmentResult,
  }) {
    final buffer = StringBuffer();

    buffer.writeln(
      'INTERVENTION PLAN RATIONALE\n',
    );

    buffer.writeln('Priority Focus Areas:');
    for (final area in priorityAreas) {
      buffer.writeln('• ${_humanizeArea(area)}');
    }

    buffer.writeln(
      '\nAssessment Details:',
    );
    buffer.writeln('• Overall Score: ${assessmentResult.overallDevelopmentalScore.toStringAsFixed(1)}/100');
    buffer.writeln('• Risk Level: ${assessmentResult.overallRiskLevel.toString().split('.').last}');
    buffer.writeln('• Delayed Areas: ${assessmentResult.numberOfDelayedAreas}');

    buffer.writeln(
      '\nRecommended Approach:',
    );
    buffer.writeln(
      '• Activities are tailored to child\'s current level and needs',
    );
    buffer.writeln(
      '• Focus on zone of proximal development (challenging but achievable)',
    );
    buffer.writeln(
      '• Culturally appropriate and locally resourced activities',
    );
    buffer.writeln(
      '• Progress tracking every 2 weeks to adjust interventions as needed',
    );

    return buffer.toString();
  }

  static String _humanizeArea(String area) {
    return area
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  // ========================================================================
  // ACTIVITY CATALOG INITIALIZATION
  // ========================================================================

  static List<Activity> _initializeActivityCatalog() {
    return [
      // Motor Skills Activities
      Activity(
        activityId: 'ACT_MOTOR_BALANCE_001',
        title: {
          'en': 'Rainbow Bridge Walking',
          'hi': 'इंद्रधनुष पुल चलना',
          'te': 'ఇంద్రధనుస్సు వంతెన నడక'
        },
        category: ActivityCategory.motorSkills,
        subCategory: 'balance',
        minAgeMonths: 30,
        maxAgeMonths: 60,
        difficulty: ActivityDifficulty.medium,
        requiredMaterials: [
          ActivityMaterial(
            name: 'chalk or rope',
            isRequired: true,
            localAlternative: 'floor dust or stick'
          )
        ],
        optionalMaterials: [
          ActivityMaterial(
            name: 'soft toys',
            isRequired: false,
            localAlternative: 'cloth balls'
          )
        ],
        instructions: {
          'en': 'Draw a straight line on the ground. Ask child to walk on the line without stepping off. Start with 3 meters, gradually increase.',
          'hi': 'जमीन पर एक सीधी रेखा खींचें। बच्चे को रेखा पर चलने के लिए कहें। 3 मीटर से शुरू करें और धीरे-धीरे बढ़ाएं।',
        },
        videoUrl: 'https://storage.googleapis.com/videos/balance_walk_en.mp4',
        durationMinutes: 15,
        culturalAdaptations: {
          'telangana': CulturalAdaptation(
            region: 'telangana',
            tip: 'Sing "Jalli Jalli" rhyme while walking',
            localContext: 'Like walking on kolam lines'
          ),
          'tamil_nadu': CulturalAdaptation(
            region: 'tamil_nadu',
            tip: 'Use rangoli patterns instead of straight line',
            localContext: 'Practice during Pongal festival prep'
          ),
        },
        targetSkills: ['balance', 'focus', 'gross_motor'],
        expectedImprovement: '+8-12 points in balance score',
        progressTracking: [
          ProgressMilestone(dayNumber: 1, expectedOutcome: 'Can walk 1 meter'),
          ProgressMilestone(dayNumber: 7, expectedOutcome: 'Can walk 3 meters'),
          ProgressMilestone(dayNumber: 14, expectedOutcome: 'Can walk backwards'),
        ],
        safetyTips: [
          'Ensure flat surface',
          'No sharp objects nearby',
          'Parent supervision required'
        ],
        scientificBasis: 'Based on Montessori method + WHO gross motor guidelines',
      ),

      // Speech & Language Activities
      Activity(
        activityId: 'ACT_SPEECH_VOCAB_001',
        title: {
          'en': 'Picture Story Telling',
          'hi': 'चित्र कहानी सुनाना',
          'te': 'చిత్ర కథ చెప్పడం'
        },
        category: ActivityCategory.speechLanguage,
        subCategory: 'vocabulary',
        minAgeMonths: 24,
        maxAgeMonths: 48,
        difficulty: ActivityDifficulty.medium,
        requiredMaterials: [
          ActivityMaterial(
            name: 'picture cards',
            isRequired: true,
            localAlternative: 'draw on paper or use old magazines'
          )
        ],
        optionalMaterials: [],
        instructions: {
          'en': 'Show picture cards to child. Ask child to name objects and create stories. Correct gently and expand responses.',
          'hi': 'बच्चे को चित्र दिखाएं। बच्चे से कहानियां बनाने के लिए कहें। धीरे से सुधारें।',
        },
        videoUrl: 'https://storage.googleapis.com/videos/story_telling_en.mp4',
        durationMinutes: 20,
        culturalAdaptations: {
          'all_regions': CulturalAdaptation(
            region: 'all_regions',
            tip: 'Use local folktales and traditional stories',
            localContext: 'Connect to cultural narratives'
          ),
        },
        targetSkills: ['vocabulary', 'speech', 'narrative'],
        expectedImprovement: '+10-15 points in speech score',
        progressTracking: [
          ProgressMilestone(dayNumber: 7, expectedOutcome: 'Labels 10 objects'),
          ProgressMilestone(dayNumber: 14, expectedOutcome: 'Forms 2-word phrases'),
          ProgressMilestone(dayNumber: 21, expectedOutcome: 'Tells simple sentences'),
        ],
        safetyTips: ['Use large, non-toxic images'],
        scientificBasis: 'Vocabulary expansion through visual scaffolding',
      ),

      // Cognitive Activities
      Activity(
        activityId: 'ACT_COGNITIVE_MEMORY_001',
        title: {
          'en': 'Shape Memory Game',
          'hi': 'आकार स्मृति खेल',
          'te': 'ఆకారం మెమరీ గేమ్'
        },
        category: ActivityCategory.cognitive,
        subCategory: 'memory',
        minAgeMonths: 24,
        maxAgeMonths: 60,
        difficulty: ActivityDifficulty.easy,
        requiredMaterials: [
          ActivityMaterial(
            name: 'shape cards',
            isRequired: true,
            localAlternative: 'draw shapes on paper'
          )
        ],
        optionalMaterials: [],
        instructions: {
          'en': 'Show 3-5 shapes for 30 seconds. Cover them. Ask child to recall. Start with 3, increase to 5.',
          'hi': '3-5 आकार दिखाएं। उन्हें ढकें। बच्चे को याद दिलाने के लिए पूछें।',
        },
        videoUrl: 'https://storage.googleapis.com/videos/memory_game_en.mp4',
        durationMinutes: 10,
        culturalAdaptations: {},
        targetSkills: ['memory', 'attention', 'cognitive'],
        expectedImprovement: '+5-8 points in memory score',
        progressTracking: [
          ProgressMilestone(dayNumber: 1, expectedOutcome: 'Recalls 2 shapes'),
          ProgressMilestone(dayNumber: 7, expectedOutcome: 'Recalls 3-4 shapes'),
          ProgressMilestone(dayNumber: 14, expectedOutcome: 'Recalls 5 shapes'),
        ],
        safetyTips: [],
        scientificBasis: 'Memory capacity development through practice',
      ),

      // Social-Emotional Activities
      Activity(
        activityId: 'ACT_SOCIAL_EMOTION_001',
        title: {
          'en': 'Emotion Recognition Games',
          'hi': 'भावना पहचान खेल',
          'te': 'భావన గుర్తింపు గేమ్‌లు'
        },
        category: ActivityCategory.socialEmotional,
        subCategory: 'emotion',
        minAgeMonths: 24,
        maxAgeMonths: 60,
        difficulty: ActivityDifficulty.easy,
        requiredMaterials: [
          ActivityMaterial(
            name: 'emotion face cards',
            isRequired: true,
            localAlternative: 'draw faces or use simple expressions'
          )
        ],
        optionalMaterials: [],
        instructions: {
          'en': 'Show emotion faces. Ask child to identify (happy, sad, angry, scared). Role-play emotions together.',
          'hi': 'भावना का चेहरा दिखाएं। बच्चे से पहचानने के लिए कहें। एक साथ भावनाओं का अभिनय करें।',
        },
        videoUrl: 'https://storage.googleapis.com/videos/emotion_game_en.mp4',
        durationMinutes: 15,
        culturalAdaptations: {},
        targetSkills: ['emotion', 'social', 'empathy'],
        expectedImprovement: '+6-10 points in social-emotional score',
        progressTracking: [
          ProgressMilestone(dayNumber: 7, expectedOutcome: 'Identifies 2 emotions'),
          ProgressMilestone(dayNumber: 14, expectedOutcome: 'Identifies 4-5 emotions'),
          ProgressMilestone(dayNumber: 21, expectedOutcome: 'Labels own emotions'),
        ],
        safetyTips: ['Create safe, supportive environment'],
        scientificBasis: 'Emotional literacy development through recognition and labeling',
      ),

      // Creative Activities
      Activity(
        activityId: 'ACT_CREATIVE_ART_001',
        title: {
          'en': 'Free Drawing & Coloring',
          'hi': 'मुक्त आरेखण और रंग',
          'te': 'ఉచిత డ్రాయింగ్ & రంగు'
        },
        category: ActivityCategory.creative,
        subCategory: 'art',
        minAgeMonths: 18,
        maxAgeMonths: 60,
        difficulty: ActivityDifficulty.easy,
        requiredMaterials: [
          ActivityMaterial(
            name: 'paper and crayons',
            isRequired: true,
            localAlternative: 'charcoal or natural pigments'
          )
        ],
        optionalMaterials: [
          ActivityMaterial(
            name: 'washable paints',
            isRequired: false,
            localAlternative: 'flour paste with natural dyes'
          )
        ],
        instructions: {
          'en': 'Provide paper and colors. Let child draw freely. Praise effort and creativity. Talk about what they created.',
          'hi': 'कागज और रंग दें। बच्चे को स्वतंत्र रूप से आकर्षित करने दें। प्रशंसा करें और चर्चा करें।',
        },
        videoUrl: 'https://storage.googleapis.com/videos/art_activity_en.mp4',
        durationMinutes: 20,
        culturalAdaptations: {},
        targetSkills: ['fine_motor', 'creativity', 'expression'],
        expectedImprovement: '+3-7 points in motor coordination',
        progressTracking: [
          ProgressMilestone(dayNumber: 1, expectedOutcome: 'Holds crayon with fist'),
          ProgressMilestone(dayNumber: 7, expectedOutcome: 'Makes marks on paper'),
          ProgressMilestone(dayNumber: 21, expectedOutcome: 'Draws recognizable shapes'),
        ],
        safetyTips: ['Use non-toxic materials', 'Wash hands after activity'],
        scientificBasis: 'Fine motor and creative development through art',
      ),
    ];
  }
}
