import 'package:hive/hive.dart';

// ============================================================================
// INTERVENTION & ACTIVITY MODELS (Section B Integration)
// ============================================================================

enum ActivityCategory {
  motorSkills,
  speechLanguage,
  cognitive,
  socialEmotional,
  creative,
}

enum ActivityDifficulty {
  easy,
  medium,
  hard,
}

@HiveType(typeId: 13)
class ActivityMaterial extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final bool isRequired;

  @HiveField(2)
  final String localAlternative; // e.g., "chalk or rope" for marker

  ActivityMaterial({
    required this.name,
    required this.isRequired,
    required this.localAlternative,
  });
}

class ActivityMaterialAdapter extends TypeAdapter<ActivityMaterial> {
  @override
  final int typeId = 13;

  @override
  ActivityMaterial read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActivityMaterial(
      name: fields[0] as String,
      isRequired: fields[1] as bool,
      localAlternative: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ActivityMaterial obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.isRequired)
      ..writeByte(2)
      ..write(obj.localAlternative);
  }
}

@HiveType(typeId: 14)
class CulturalAdaptation extends HiveObject {
  @HiveField(0)
  final String region; // e.g., 'telangana', 'tamil_nadu', 'kerala'

  @HiveField(1)
  final String tip; // localized tip

  @HiveField(2)
  final String localContext; // e.g., "Like walking on kolam lines"

  CulturalAdaptation({
    required this.region,
    required this.tip,
    required this.localContext,
  });
}

class CulturalAdaptationAdapter extends TypeAdapter<CulturalAdaptation> {
  @override
  final int typeId = 14;

  @override
  CulturalAdaptation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CulturalAdaptation(
      region: fields[0] as String,
      tip: fields[1] as String,
      localContext: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CulturalAdaptation obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.region)
      ..writeByte(1)
      ..write(obj.tip)
      ..writeByte(2)
      ..write(obj.localContext);
  }
}

@HiveType(typeId: 15)
class ProgressMilestone extends HiveObject {
  @HiveField(0)
  final int dayNumber; // day 1, 7, 14, 21, 28

  @HiveField(1)
  final String expectedOutcome; // e.g., "Can walk 1 meter"

  ProgressMilestone({
    required this.dayNumber,
    required this.expectedOutcome,
  });
}

class ProgressMilestoneAdapter extends TypeAdapter<ProgressMilestone> {
  @override
  final int typeId = 15;

  @override
  ProgressMilestone read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProgressMilestone(
      dayNumber: fields[0] as int,
      expectedOutcome: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ProgressMilestone obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.dayNumber)
      ..writeByte(1)
      ..write(obj.expectedOutcome);
  }
}

@HiveType(typeId: 16)
class Activity extends HiveObject {
  @HiveField(0)
  final String activityId; // e.g., "ACT_MOTOR_BALANCE_012"

  @HiveField(1)
  final Map<String, String> title; // multilingual titles

  @HiveField(2)
  final ActivityCategory category;

  @HiveField(3)
  final String subCategory; // e.g., "balance", "gross_motor"

  @HiveField(4)
  final int minAgeMonths;

  @HiveField(5)
  final int maxAgeMonths;

  @HiveField(6)
  final ActivityDifficulty difficulty;

  @HiveField(7)
  final List<ActivityMaterial> requiredMaterials;

  @HiveField(8)
  final List<ActivityMaterial> optionalMaterials;

  @HiveField(9)
  final Map<String, String> instructions; // multilingual instructions

  @HiveField(10)
  final String videoUrl; // URL to instructional video

  @HiveField(11)
  final int durationMinutes; // 10-15, 20-30, etc.

  @HiveField(12)
  final Map<String, CulturalAdaptation> culturalAdaptations;

  @HiveField(13)
  final List<String> targetSkills; // ["balance", "focus", "gross_motor"]

  @HiveField(14)
  final String expectedImprovement; // "+8-12 points in balance score"

  @HiveField(15)
  final List<ProgressMilestone> progressTracking;

  @HiveField(16)
  final List<String> safetyTips;

  @HiveField(17)
  final String scientificBasis; // reference to methodology/guidelines

  @HiveField(18)
  final double recommendationScore; // 0-1 based on child's profile match

  Activity({
    required this.activityId,
    required this.title,
    required this.category,
    required this.subCategory,
    required this.minAgeMonths,
    required this.maxAgeMonths,
    required this.difficulty,
    required this.requiredMaterials,
    required this.optionalMaterials,
    required this.instructions,
    required this.videoUrl,
    required this.durationMinutes,
    required this.culturalAdaptations,
    required this.targetSkills,
    required this.expectedImprovement,
    required this.progressTracking,
    required this.safetyTips,
    required this.scientificBasis,
    this.recommendationScore = 0.0,
  });
}

class ActivityAdapter extends TypeAdapter<Activity> {
  @override
  final int typeId = 16;

  @override
  Activity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Activity(
      activityId: fields[0] as String,
      title: (fields[1] as Map?)?.cast<String, String>() ?? {},
      category: fields[2] as ActivityCategory,
      subCategory: fields[3] as String,
      minAgeMonths: fields[4] as int,
      maxAgeMonths: fields[5] as int,
      difficulty: fields[6] as ActivityDifficulty,
      requiredMaterials: (fields[7] as List?)?.cast<ActivityMaterial>() ?? [],
      optionalMaterials: (fields[8] as List?)?.cast<ActivityMaterial>() ?? [],
      instructions: (fields[9] as Map?)?.cast<String, String>() ?? {},
      videoUrl: fields[10] as String,
      durationMinutes: fields[11] as int,
      culturalAdaptations: (fields[12] as Map?)?.cast<String, CulturalAdaptation>() ?? {},
      targetSkills: (fields[13] as List?)?.cast<String>() ?? [],
      expectedImprovement: fields[14] as String,
      progressTracking: (fields[15] as List?)?.cast<ProgressMilestone>() ?? [],
      safetyTips: (fields[16] as List?)?.cast<String>() ?? [],
      scientificBasis: fields[17] as String,
      recommendationScore: fields[18] as double? ?? 0.0,
    );
  }

  @override
  void write(BinaryWriter writer, Activity obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.activityId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.subCategory)
      ..writeByte(4)
      ..write(obj.minAgeMonths)
      ..writeByte(5)
      ..write(obj.maxAgeMonths)
      ..writeByte(6)
      ..write(obj.difficulty)
      ..writeByte(7)
      ..write(obj.requiredMaterials)
      ..writeByte(8)
      ..write(obj.optionalMaterials)
      ..writeByte(9)
      ..write(obj.instructions)
      ..writeByte(10)
      ..write(obj.videoUrl)
      ..writeByte(11)
      ..write(obj.durationMinutes)
      ..writeByte(12)
      ..write(obj.culturalAdaptations)
      ..writeByte(13)
      ..write(obj.targetSkills)
      ..writeByte(14)
      ..write(obj.expectedImprovement)
      ..writeByte(15)
      ..write(obj.progressTracking)
      ..writeByte(16)
      ..write(obj.safetyTips)
      ..writeByte(17)
      ..write(obj.scientificBasis)
      ..writeByte(18)
      ..write(obj.recommendationScore);
  }
}

// ============================================================================
// INTERVENTION SESSION & TRACKING MODELS
// ============================================================================

@HiveType(typeId: 17)
class ActivitySession extends HiveObject {
  @HiveField(0)
  final String sessionId;

  @HiveField(1)
  final String childId;

  @HiveField(2)
  final String activityId;

  @HiveField(3)
  final DateTime sessionDate;

  @HiveField(4)
  final int durationMinutes;

  @HiveField(5)
  final bool completed; // was the activity completed?

  @HiveField(6)
  final double childEngagementScore; // 0-100 (teacher's observation)

  @HiveField(7)
  final double performanceScore; // 0-100 (how well child performed)

  @HiveField(8)
  final String workerNotes;

  @HiveField(9)
  final bool requiresFollowUp;

  @HiveField(10)
  final DateTime? nextSessionScheduled;

  ActivitySession({
    required this.sessionId,
    required this.childId,
    required this.activityId,
    required this.sessionDate,
    required this.durationMinutes,
    required this.completed,
    required this.childEngagementScore,
    required this.performanceScore,
    required this.workerNotes,
    required this.requiresFollowUp,
    this.nextSessionScheduled,
  });
}

class ActivitySessionAdapter extends TypeAdapter<ActivitySession> {
  @override
  final int typeId = 17;

  @override
  ActivitySession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActivitySession(
      sessionId: fields[0] as String,
      childId: fields[1] as String,
      activityId: fields[2] as String,
      sessionDate: fields[3] as DateTime,
      durationMinutes: fields[4] as int,
      completed: fields[5] as bool,
      childEngagementScore: fields[6] as double,
      performanceScore: fields[7] as double,
      workerNotes: fields[8] as String,
      requiresFollowUp: fields[9] as bool,
      nextSessionScheduled: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ActivitySession obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.sessionId)
      ..writeByte(1)
      ..write(obj.childId)
      ..writeByte(2)
      ..write(obj.activityId)
      ..writeByte(3)
      ..write(obj.sessionDate)
      ..writeByte(4)
      ..write(obj.durationMinutes)
      ..writeByte(5)
      ..write(obj.completed)
      ..writeByte(6)
      ..write(obj.childEngagementScore)
      ..writeByte(7)
      ..write(obj.performanceScore)
      ..writeByte(8)
      ..write(obj.workerNotes)
      ..writeByte(9)
      ..write(obj.requiresFollowUp)
      ..writeByte(10)
      ..write(obj.nextSessionScheduled);
  }
}

@HiveType(typeId: 18)
class PersonalizedInterventionPlan extends HiveObject {
  @HiveField(0)
  final String planId;

  @HiveField(1)
  final String childId;

  @HiveField(2)
  final DateTime createdDate;

  @HiveField(3)
  final DateTime validUntil;

  @HiveField(4)
  final List<Activity> recommendedActivities; // top 10 personalized activities

  @HiveField(5)
  final List<String> priorityAreas; // skill gaps to work on

  @HiveField(6)
  final String interventionRationale; // why these activities?

  @HiveField(7)
  final int estimatedWeeklyHours;

  @HiveField(8)
  final double expectedProgressRate; // 0-1 (how quickly should child improve)

  @HiveField(9)
  final bool active; // is this plan currently active?

  @HiveField(10)
  final int followUpAssessmentWeeks; // repeat assessment after X weeks

  PersonalizedInterventionPlan({
    required this.planId,
    required this.childId,
    required this.createdDate,
    required this.validUntil,
    required this.recommendedActivities,
    required this.priorityAreas,
    required this.interventionRationale,
    required this.estimatedWeeklyHours,
    required this.expectedProgressRate,
    required this.active,
    required this.followUpAssessmentWeeks,
  });
}

class PersonalizedInterventionPlanAdapter
    extends TypeAdapter<PersonalizedInterventionPlan> {
  @override
  final int typeId = 18;

  @override
  PersonalizedInterventionPlan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PersonalizedInterventionPlan(
      planId: fields[0] as String,
      childId: fields[1] as String,
      createdDate: fields[2] as DateTime,
      validUntil: fields[3] as DateTime,
      recommendedActivities: (fields[4] as List?)?.cast<Activity>() ?? [],
      priorityAreas: (fields[5] as List?)?.cast<String>() ?? [],
      interventionRationale: fields[6] as String,
      estimatedWeeklyHours: fields[7] as int,
      expectedProgressRate: fields[8] as double,
      active: fields[9] as bool,
      followUpAssessmentWeeks: fields[10] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PersonalizedInterventionPlan obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.planId)
      ..writeByte(1)
      ..write(obj.childId)
      ..writeByte(2)
      ..write(obj.createdDate)
      ..writeByte(3)
      ..write(obj.validUntil)
      ..writeByte(4)
      ..write(obj.recommendedActivities)
      ..writeByte(5)
      ..write(obj.priorityAreas)
      ..writeByte(6)
      ..write(obj.interventionRationale)
      ..writeByte(7)
      ..write(obj.estimatedWeeklyHours)
      ..writeByte(8)
      ..write(obj.expectedProgressRate)
      ..writeByte(9)
      ..write(obj.active)
      ..writeByte(10)
      ..write(obj.followUpAssessmentWeeks);
  }
}
