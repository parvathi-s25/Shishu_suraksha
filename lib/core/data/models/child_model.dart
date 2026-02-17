

class GrowthRecord {
  final DateTime date;
  final double height; // cm
  final double weight; // kg
  
  GrowthRecord({required this.date, required this.height, required this.weight});
  
  double get bmi => weight / ((height / 100) * (height / 100));

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'height': height,
    'weight': weight,
  };

  factory GrowthRecord.fromJson(Map<String, dynamic> json) => GrowthRecord(
    date: DateTime.parse(json['date']),
    height: json['height'].toDouble(),
    weight: json['weight'].toDouble(),
  );
}

class ChildModel {
  final String id;
  final String name;
  final int? age;
  final DateTime? dob;
  final String? gender;
  final String? anganwadi;
  final List<GrowthRecord> growthHistory;
  final double? speechScore; // New
  final String? hearingStatus; // New
  final DateTime? lastAssessmentDate; // New

  ChildModel({
    required this.id,
    required this.name,
    this.age,
    this.dob,
    this.gender,
    this.anganwadi,
    List<GrowthRecord>? growthHistory,
    this.speechScore,
    this.hearingStatus,
    this.lastAssessmentDate,
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'age': age,
    'dob': dob?.toIso8601String(),
    'gender': gender,
    'anganwadi': anganwadi,
    'growthHistory': growthHistory.map((e) => e.toJson()).toList(),
    'speechScore': speechScore,
    'hearingStatus': hearingStatus,
    'lastAssessmentDate': lastAssessmentDate?.toIso8601String(),
  };

  factory ChildModel.fromJson(Map<String, dynamic> json) => ChildModel(
    id: json['id'],
    name: json['name'],
    age: json['age'],
    dob: json['dob'] != null ? DateTime.parse(json['dob']) : null,
    gender: json['gender'],
    anganwadi: json['anganwadi'],
    growthHistory: json['growthHistory'] != null 
      ? (json['growthHistory'] as List).map((e) => GrowthRecord.fromJson(e)).toList() 
      : [],
    speechScore: json['speechScore']?.toDouble(),
    hearingStatus: json['hearingStatus'],
    lastAssessmentDate: json['lastAssessmentDate'] != null ? DateTime.parse(json['lastAssessmentDate']) : null,
  );
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
