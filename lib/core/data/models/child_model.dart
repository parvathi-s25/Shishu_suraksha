

class GrowthRecord {
  final DateTime date;
  final double height; // cm
  final double weight; // kg
  
  GrowthRecord({required this.date, required this.height, required this.weight});
  
  double get bmi => weight / ((height / 100) * (height / 100));
}

class ChildModel {
  final String id;
  final String name;
  final int? age;
  final DateTime? dob;
  final String? gender;
  final String? anganwadi;
  final List<GrowthRecord> growthHistory; // New field

  ChildModel({
    required this.id,
    required this.name,
    this.age,
    this.dob,
    this.gender,
    this.anganwadi,
    List<GrowthRecord>? growthHistory,
  }) : growthHistory = growthHistory ?? [];

  int get ageMonths {
    if (dob != null) {
      final months = DateTime.now().difference(dob!).inDays ~/ 30;
      return months;
    }
    if (age != null) {
      return age! * 12;
    }
    return 0;
  }
}

enum ActivityCategory { motorSkills, speechLanguage, cognitive, socialEmotional, creative }

enum ActivityDifficulty { easy, medium, hard }

class ActivityMaterial {
  final String name;
  final bool isRequired;
  final String? localAlternative;

  ActivityMaterial({
    required this.name,
    required this.isRequired,
    this.localAlternative,
  });
}

class ProgressMilestone {
  final int dayNumber;
  final String expectedOutcome;

  ProgressMilestone({
    required this.dayNumber,
    required this.expectedOutcome,
  });
}

class Activity {
  final String activityId;
  final Map<String, String> title;
  final ActivityCategory category;
  final int minAgeMonths;
  final int maxAgeMonths;
  final ActivityDifficulty difficulty;
  final List<ActivityMaterial> materials;
  final Map<String, String> instructions;
  final List<String> targetSkills;
  final List<ProgressMilestone> expectedImprovement;
  final double recommendationScore;
  final int? durationMinutes;

  Activity({
    required this.activityId,
    required this.title,
    required this.category,
    required this.minAgeMonths,
    required this.maxAgeMonths,
    required this.difficulty,
    required this.materials,
    required this.instructions,
    required this.targetSkills,
    required this.expectedImprovement,
    required this.recommendationScore,
    this.durationMinutes,
  });
}

class ActivitySession {
  final String sessionId;
  final String childId;
  final String activityId;
  final bool completed;
  final DateTime sessionDate;
  final double engagement;
  final double performance;
  final String workerNotes;
  final bool followUpNeeded;

  ActivitySession({
    required this.sessionId,
    required this.childId,
    required this.activityId,
    required this.completed,
    required this.sessionDate,
    required this.engagement,
    required this.performance,
    required this.workerNotes,
    required this.followUpNeeded,
  });
}
