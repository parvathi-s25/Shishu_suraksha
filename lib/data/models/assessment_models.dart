import 'package:hive/hive.dart';

// ============================================================================
// ASSESSMENT ENUMS & CONSTANTS
// ============================================================================

enum AssessmentType {
  motorSkills,
  speechLanguage,
  cognitive,
  socialEmotional,
  visionHearing,
  anemia,
  birthDefects,
}

enum RiskLevel {
  low, // Green
  medium, // Yellow
  high, // Red
}

enum BirthDefectType {
  clubfoot,
  cleftPalate,
  downSyndrome,
  congenitalHeartDefect,
  none,
}

// ============================================================================
// MOTOR SKILLS ASSESSMENT MODEL
// ============================================================================

@HiveType(typeId: 2)
class MotorSkillsAssessment extends HiveObject {
  @HiveField(0)
  final DateTime assessmentDate;

  @HiveField(1)
  final double jumpHeight; // in cm, 0-100

  @HiveField(2)
  final double jumpScore; // 0-100

  @HiveField(3)
  final double armSwingQuality; // 0-100

  @HiveField(4)
  final double landingStability; // 0-100

  @HiveField(5)
  final double singleLegStandDuration; // in seconds, 0-120

  @HiveField(6)
  final int wobbleCount; // number of wobbles during stand

  @HiveField(7)
  final double balanceScore; // 0-100

  @HiveField(8)
  final double gaitSymmetry; // 0-100 (left-right symmetry)

  @HiveField(9)
  final double stepCoordination; // 0-100

  @HiveField(10)
  final double walkScore; // 0-100

  @HiveField(11)
  final double eyeHandCoordination; // 0-100

  @HiveField(12)
  final double throwCatchTiming; // 0-100

  @HiveField(13)
  final double throwCatchScore; // 0-100

  @HiveField(14)
  final double overallMotorScore; // 0-100

  @HiveField(15)
  final int developmentalAgeMonths; // age equivalent in months

  @HiveField(16)
  final String notes;

  MotorSkillsAssessment({
    required this.assessmentDate,
    required this.jumpHeight,
    required this.jumpScore,
    required this.armSwingQuality,
    required this.landingStability,
    required this.singleLegStandDuration,
    required this.wobbleCount,
    required this.balanceScore,
    required this.gaitSymmetry,
    required this.stepCoordination,
    required this.walkScore,
    required this.eyeHandCoordination,
    required this.throwCatchTiming,
    required this.throwCatchScore,
    required this.overallMotorScore,
    required this.developmentalAgeMonths,
    this.notes = '',
  });
}

class MotorSkillsAssessmentAdapter extends TypeAdapter<MotorSkillsAssessment> {
  @override
  final int typeId = 2;

  @override
  MotorSkillsAssessment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MotorSkillsAssessment(
      assessmentDate: fields[0] as DateTime,
      jumpHeight: fields[1] as double,
      jumpScore: fields[2] as double,
      armSwingQuality: fields[3] as double,
      landingStability: fields[4] as double,
      singleLegStandDuration: fields[5] as double,
      wobbleCount: fields[6] as int,
      balanceScore: fields[7] as double,
      gaitSymmetry: fields[8] as double,
      stepCoordination: fields[9] as double,
      walkScore: fields[10] as double,
      eyeHandCoordination: fields[11] as double,
      throwCatchTiming: fields[12] as double,
      throwCatchScore: fields[13] as double,
      overallMotorScore: fields[14] as double,
      developmentalAgeMonths: fields[15] as int,
      notes: fields[16] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, MotorSkillsAssessment obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.assessmentDate)
      ..writeByte(1)
      ..write(obj.jumpHeight)
      ..writeByte(2)
      ..write(obj.jumpScore)
      ..writeByte(3)
      ..write(obj.armSwingQuality)
      ..writeByte(4)
      ..write(obj.landingStability)
      ..writeByte(5)
      ..write(obj.singleLegStandDuration)
      ..writeByte(6)
      ..write(obj.wobbleCount)
      ..writeByte(7)
      ..write(obj.balanceScore)
      ..writeByte(8)
      ..write(obj.gaitSymmetry)
      ..writeByte(9)
      ..write(obj.stepCoordination)
      ..writeByte(10)
      ..write(obj.walkScore)
      ..writeByte(11)
      ..write(obj.eyeHandCoordination)
      ..writeByte(12)
      ..write(obj.throwCatchTiming)
      ..writeByte(13)
      ..write(obj.throwCatchScore)
      ..writeByte(14)
      ..write(obj.overallMotorScore)
      ..writeByte(15)
      ..write(obj.developmentalAgeMonths)
      ..writeByte(16)
      ..write(obj.notes);
  }
}

// ============================================================================
// SPEECH & LANGUAGE ASSESSMENT MODEL
// ============================================================================

@HiveType(typeId: 3)
class SpeechLanguageAssessment extends HiveObject {
  @HiveField(0)
  final DateTime assessmentDate;

  @HiveField(1)
  final double wordClarity; // 0-100

  @HiveField(2)
  final int vocabularyLevel; // age equivalent in months

  @HiveField(3)
  final double sentenceFormation; // 0-100 (for 3+ years)

  @HiveField(4)
  final double pronunciationAccuracy; // 0-100

  @HiveField(5)
  final double fluencyScore; // 0-100 (fluency and rhythm)

  @HiveField(6)
  final double overallSpeechScore; // 0-100

  @HiveField(7)
  final String language; // 'Hindi', 'Telugu', 'Tamil', etc.

  @HiveField(8)
  final String audioRecordingPath; // local path to stored audio

  @HiveField(9)
  final bool articulation; // issues detected?

  @HiveField(10)
  final bool delayDetected; // speech delay detected?

  @HiveField(11)
  final String notes;

  SpeechLanguageAssessment({
    required this.assessmentDate,
    required this.wordClarity,
    required this.vocabularyLevel,
    required this.sentenceFormation,
    required this.pronunciationAccuracy,
    required this.fluencyScore,
    required this.overallSpeechScore,
    required this.language,
    required this.audioRecordingPath,
    required this.articulation,
    required this.delayDetected,
    this.notes = '',
  });
}

class SpeechLanguageAssessmentAdapter
    extends TypeAdapter<SpeechLanguageAssessment> {
  @override
  final int typeId = 3;

  @override
  SpeechLanguageAssessment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SpeechLanguageAssessment(
      assessmentDate: fields[0] as DateTime,
      wordClarity: fields[1] as double,
      vocabularyLevel: fields[2] as int,
      sentenceFormation: fields[3] as double,
      pronunciationAccuracy: fields[4] as double,
      fluencyScore: fields[5] as double,
      overallSpeechScore: fields[6] as double,
      language: fields[7] as String,
      audioRecordingPath: fields[8] as String,
      articulation: fields[9] as bool,
      delayDetected: fields[10] as bool,
      notes: fields[11] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, SpeechLanguageAssessment obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.assessmentDate)
      ..writeByte(1)
      ..write(obj.wordClarity)
      ..writeByte(2)
      ..write(obj.vocabularyLevel)
      ..writeByte(3)
      ..write(obj.sentenceFormation)
      ..writeByte(4)
      ..write(obj.pronunciationAccuracy)
      ..writeByte(5)
      ..write(obj.fluencyScore)
      ..writeByte(6)
      ..write(obj.overallSpeechScore)
      ..writeByte(7)
      ..write(obj.language)
      ..writeByte(8)
      ..write(obj.audioRecordingPath)
      ..writeByte(9)
      ..write(obj.articulation)
      ..writeByte(10)
      ..write(obj.delayDetected)
      ..writeByte(11)
      ..write(obj.notes);
  }
}

// ============================================================================
// COGNITIVE ASSESSMENT MODEL
// ============================================================================

@HiveType(typeId: 4)
class CognitiveAssessment extends HiveObject {
  @HiveField(0)
  final DateTime assessmentDate;

  @HiveField(1)
  final double memoryScore; // shape/color recall 0-100

  @HiveField(2)
  final double patternRecognition; // 0-100

  @HiveField(3)
  final double problemSolving; // 0-100

  @HiveField(4)
  final double attentionSpan; // duration in seconds

  @HiveField(5)
  final double concentrationScore; // 0-100

  @HiveField(6)
  final double overallCognitiveScore; // 0-100

  @HiveField(7)
  final int cognitiveAgeMonths; // age equivalent in months

  @HiveField(8)
  final String notes;

  CognitiveAssessment({
    required this.assessmentDate,
    required this.memoryScore,
    required this.patternRecognition,
    required this.problemSolving,
    required this.attentionSpan,
    required this.concentrationScore,
    required this.overallCognitiveScore,
    required this.cognitiveAgeMonths,
    this.notes = '',
  });
}

class CognitiveAssessmentAdapter extends TypeAdapter<CognitiveAssessment> {
  @override
  final int typeId = 4;

  @override
  CognitiveAssessment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CognitiveAssessment(
      assessmentDate: fields[0] as DateTime,
      memoryScore: fields[1] as double,
      patternRecognition: fields[2] as double,
      problemSolving: fields[3] as double,
      attentionSpan: fields[4] as double,
      concentrationScore: fields[5] as double,
      overallCognitiveScore: fields[6] as double,
      cognitiveAgeMonths: fields[7] as int,
      notes: fields[8] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, CognitiveAssessment obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.assessmentDate)
      ..writeByte(1)
      ..write(obj.memoryScore)
      ..writeByte(2)
      ..write(obj.patternRecognition)
      ..writeByte(3)
      ..write(obj.problemSolving)
      ..writeByte(4)
      ..write(obj.attentionSpan)
      ..writeByte(5)
      ..write(obj.concentrationScore)
      ..writeByte(6)
      ..write(obj.overallCognitiveScore)
      ..writeByte(7)
      ..write(obj.cognitiveAgeMonths)
      ..writeByte(8)
      ..write(obj.notes);
  }
}

// ============================================================================
// SOCIAL-EMOTIONAL ASSESSMENT MODEL
// ============================================================================

@HiveType(typeId: 5)
class SocialEmotionalAssessment extends HiveObject {
  @HiveField(0)
  final DateTime assessmentDate;

  @HiveField(1)
  final double eyeContactScore; // 0-100

  @HiveField(2)
  final double facialExpressionScore; // 0-100

  @HiveField(3)
  final double socialCueResponse; // 0-100

  @HiveField(4)
  final double interactionScore; // 0-100 (with worker/peers)

  @HiveField(5)
  final double emotionalRegulation; // 0-100

  @HiveField(6)
  final double overallSocialScore; // 0-100

  @HiveField(7)
  final bool limitedEyeContact; // autism indicator

  @HiveField(8)
  final bool delayedEmotionalResponse; // autism indicator

  @HiveField(9)
  final bool repetitiveBehaviors; // autism indicator

  @HiveField(10)
  final String notes;

  SocialEmotionalAssessment({
    required this.assessmentDate,
    required this.eyeContactScore,
    required this.facialExpressionScore,
    required this.socialCueResponse,
    required this.interactionScore,
    required this.emotionalRegulation,
    required this.overallSocialScore,
    required this.limitedEyeContact,
    required this.delayedEmotionalResponse,
    required this.repetitiveBehaviors,
    this.notes = '',
  });
}

class SocialEmotionalAssessmentAdapter
    extends TypeAdapter<SocialEmotionalAssessment> {
  @override
  final int typeId = 5;

  @override
  SocialEmotionalAssessment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SocialEmotionalAssessment(
      assessmentDate: fields[0] as DateTime,
      eyeContactScore: fields[1] as double,
      facialExpressionScore: fields[2] as double,
      socialCueResponse: fields[3] as double,
      interactionScore: fields[4] as double,
      emotionalRegulation: fields[5] as double,
      overallSocialScore: fields[6] as double,
      limitedEyeContact: fields[7] as bool,
      delayedEmotionalResponse: fields[8] as bool,
      repetitiveBehaviors: fields[9] as bool,
      notes: fields[10] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, SocialEmotionalAssessment obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.assessmentDate)
      ..writeByte(1)
      ..write(obj.eyeContactScore)
      ..writeByte(2)
      ..write(obj.facialExpressionScore)
      ..writeByte(3)
      ..write(obj.socialCueResponse)
      ..writeByte(4)
      ..write(obj.interactionScore)
      ..writeByte(5)
      ..write(obj.emotionalRegulation)
      ..writeByte(6)
      ..write(obj.overallSocialScore)
      ..writeByte(7)
      ..write(obj.limitedEyeContact)
      ..writeByte(8)
      ..write(obj.delayedEmotionalResponse)
      ..writeByte(9)
      ..write(obj.repetitiveBehaviors)
      ..writeByte(10)
      ..write(obj.notes);
  }
}

// ============================================================================
// HEALTH SCREENING MODELS
// ============================================================================

@HiveType(typeId: 6)
class VisionHearingAssessment extends HiveObject {
  @HiveField(0)
  final DateTime assessmentDate;

  @HiveField(1)
  final double visionScore; // 0-100

  @HiveField(2)
  final double eyeTrackingScore; // 0-100

  @HiveField(3)
  final double objectFollowing; // 0-100

  @HiveField(4)
  final double hearingScore; // 0-100

  @HiveField(5)
  final bool soundResponseNormal; // normal hearing?

  @HiveField(6)
  final double audioFrequencyRange; // Hz range 0-20000

  @HiveField(7)
  final String notes;

  VisionHearingAssessment({
    required this.assessmentDate,
    required this.visionScore,
    required this.eyeTrackingScore,
    required this.objectFollowing,
    required this.hearingScore,
    required this.soundResponseNormal,
    required this.audioFrequencyRange,
    this.notes = '',
  });
}

class VisionHearingAssessmentAdapter
    extends TypeAdapter<VisionHearingAssessment> {
  @override
  final int typeId = 6;

  @override
  VisionHearingAssessment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VisionHearingAssessment(
      assessmentDate: fields[0] as DateTime,
      visionScore: fields[1] as double,
      eyeTrackingScore: fields[2] as double,
      objectFollowing: fields[3] as double,
      hearingScore: fields[4] as double,
      soundResponseNormal: fields[5] as bool,
      audioFrequencyRange: fields[6] as double,
      notes: fields[7] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, VisionHearingAssessment obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.assessmentDate)
      ..writeByte(1)
      ..write(obj.visionScore)
      ..writeByte(2)
      ..write(obj.eyeTrackingScore)
      ..writeByte(3)
      ..write(obj.objectFollowing)
      ..writeByte(4)
      ..write(obj.hearingScore)
      ..writeByte(5)
      ..write(obj.soundResponseNormal)
      ..writeByte(6)
      ..write(obj.audioFrequencyRange)
      ..writeByte(7)
      ..write(obj.notes);
  }
}

@HiveType(typeId: 7)
class AnemiaAssessment extends HiveObject {
  @HiveField(0)
  final DateTime assessmentDate;

  @HiveField(1)
  final String photoPath; // nail bed or eyelid photo

  @HiveField(2)
  final double predictedHemoglobin; // g/dL

  @HiveField(3)
  final String severity; // 'Normal', 'Mild', 'Moderate', 'Severe'

  @HiveField(4)
  final double colorSaturation; // RGB to Lab color analysis

  @HiveField(5)
  final String notes;

  AnemiaAssessment({
    required this.assessmentDate,
    required this.photoPath,
    required this.predictedHemoglobin,
    required this.severity,
    required this.colorSaturation,
    this.notes = '',
  });
}

class AnemiaAssessmentAdapter extends TypeAdapter<AnemiaAssessment> {
  @override
  final int typeId = 7;

  @override
  AnemiaAssessment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AnemiaAssessment(
      assessmentDate: fields[0] as DateTime,
      photoPath: fields[1] as String,
      predictedHemoglobin: fields[2] as double,
      severity: fields[3] as String,
      colorSaturation: fields[4] as double,
      notes: fields[5] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, AnemiaAssessment obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.assessmentDate)
      ..writeByte(1)
      ..write(obj.photoPath)
      ..writeByte(2)
      ..write(obj.predictedHemoglobin)
      ..writeByte(3)
      ..write(obj.severity)
      ..writeByte(4)
      ..write(obj.colorSaturation)
      ..writeByte(5)
      ..write(obj.notes);
  }
}

@HiveType(typeId: 8)
class BirthDefectAssessment extends HiveObject {
  @HiveField(0)
  final DateTime assessmentDate;

  @HiveField(1)
  final List<BirthDefectType> detectedDefects; // list of detected defects

  @HiveField(2)
  final Map<String, double> confidenceScores; // defect -> confidence %

  @HiveField(3)
  final List<String> imagePaths; // paths to analysis images

  @HiveField(4)
  final bool requiresClinicalValidation;

  @HiveField(5)
  final String notes;

  BirthDefectAssessment({
    required this.assessmentDate,
    required this.detectedDefects,
    required this.confidenceScores,
    required this.imagePaths,
    required this.requiresClinicalValidation,
    this.notes = '',
  });
}

class BirthDefectAssessmentAdapter extends TypeAdapter<BirthDefectAssessment> {
  @override
  final int typeId = 8;

  @override
  BirthDefectAssessment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BirthDefectAssessment(
      assessmentDate: fields[0] as DateTime,
      detectedDefects:
          (fields[1] as List?)?.cast<BirthDefectType>() ?? [],
      confidenceScores: (fields[2] as Map?)?.cast<String, double>() ?? {},
      imagePaths: (fields[3] as List?)?.cast<String>() ?? [],
      requiresClinicalValidation: fields[4] as bool,
      notes: fields[5] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, BirthDefectAssessment obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.assessmentDate)
      ..writeByte(1)
      ..write(obj.detectedDefects)
      ..writeByte(2)
      ..write(obj.confidenceScores)
      ..writeByte(3)
      ..write(obj.imagePaths)
      ..writeByte(4)
      ..write(obj.requiresClinicalValidation)
      ..writeByte(5)
      ..write(obj.notes);
  }
}
