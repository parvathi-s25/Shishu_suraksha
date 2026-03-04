import 'package:cloud_firestore/cloud_firestore.dart';

class VisionResultModel {
  final String id;
  final String childId;
  final String conductedBy;
  final DateTime timestamp;
  final AcuityResult? acuityResult;
  final StrabismusResult? strabismusResult;
  final ColorVisionResult? colorResult;
  final PupilReflexResult? pupilResult;
  final FieldOfVisionResult? fieldResult;
  final RefractionResult? refractionResult;
  final double riskScore;
  final String riskLabel;

  VisionResultModel({
    required this.id,
    required this.childId,
    required this.conductedBy,
    required this.timestamp,
    this.acuityResult,
    this.strabismusResult,
    this.colorResult,
    this.pupilResult,
    this.fieldResult,
    this.refractionResult,
    this.riskScore = 0.0,
    this.riskLabel = 'Pending',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'conductedBy': conductedBy,
      'timestamp': Timestamp.fromDate(timestamp),
      'acuityResult': acuityResult?.toJson(),
      'strabismusResult': strabismusResult?.toJson(),
      'colorResult': colorResult?.toJson(),
      'pupilResult': pupilResult?.toJson(),
      'fieldResult': fieldResult?.toJson(),
      'refractionResult': refractionResult?.toJson(),
      'riskScore': riskScore,
      'riskLabel': riskLabel,
    };
  }

  factory VisionResultModel.fromJson(Map<String, dynamic> json) {
    return VisionResultModel(
      id: json['id'] ?? '',
      childId: json['childId'] ?? '',
      conductedBy: json['conductedBy'] ?? '',
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      acuityResult: json['acuityResult'] != null
          ? AcuityResult.fromJson(json['acuityResult'])
          : null,
      strabismusResult: json['strabismusResult'] != null
          ? StrabismusResult.fromJson(json['strabismusResult'])
          : null,
      colorResult: json['colorResult'] != null
          ? ColorVisionResult.fromJson(json['colorResult'])
          : null,
      pupilResult: json['pupilResult'] != null
          ? PupilReflexResult.fromJson(json['pupilResult'])
          : null,
      fieldResult: json['fieldResult'] != null
          ? FieldOfVisionResult.fromJson(json['fieldResult'])
          : null,
      refractionResult: json['refractionResult'] != null
          ? RefractionResult.fromJson(json['refractionResult'])
          : null,
      riskScore: (json['riskScore'] ?? 0.0).toDouble(),
      riskLabel: json['riskLabel'] ?? 'Pending',
    );
  }
}

class AcuityResult {
  final String leftEyeScore;
  final String rightEyeScore;
  final double distanceCm;

  AcuityResult({
    required this.leftEyeScore,
    required this.rightEyeScore,
    required this.distanceCm,
  });

  Map<String, dynamic> toJson() => {
        'leftEyeScore': leftEyeScore,
        'rightEyeScore': rightEyeScore,
        'distanceCm': distanceCm,
      };

  factory AcuityResult.fromJson(Map<String, dynamic> json) => AcuityResult(
        leftEyeScore: json['leftEyeScore'] ?? 'Unknown',
        rightEyeScore: json['rightEyeScore'] ?? 'Unknown',
        distanceCm: (json['distanceCm'] ?? 0.0).toDouble(),
      );
}

class StrabismusResult {
  final double leftEyeDeviation;
  final double rightEyeDeviation;
  final bool isAbnormal;
  final double headTilt;
  final double headTurnRatio;
  final bool isHeadPositionCorrect;

  StrabismusResult({
    required this.leftEyeDeviation,
    required this.rightEyeDeviation,
    required this.isAbnormal,
    this.headTilt = 0.0,
    this.headTurnRatio = 1.0,
    this.isHeadPositionCorrect = true,
  });

  Map<String, dynamic> toJson() => {
        'leftEyeDeviation': leftEyeDeviation,
        'rightEyeDeviation': rightEyeDeviation,
        'isAbnormal': isAbnormal,
        'headTilt': headTilt,
        'headTurnRatio': headTurnRatio,
        'isHeadPositionCorrect': isHeadPositionCorrect,
      };

  factory StrabismusResult.fromJson(Map<String, dynamic> json) =>
      StrabismusResult(
        leftEyeDeviation: (json['leftEyeDeviation'] ?? 0.0).toDouble(),
        rightEyeDeviation: (json['rightEyeDeviation'] ?? 0.0).toDouble(),
        isAbnormal: json['isAbnormal'] ?? false,
        headTilt: (json['headTilt'] ?? 0.0).toDouble(),
        headTurnRatio: (json['headTurnRatio'] ?? 1.0).toDouble(),
        isHeadPositionCorrect: json['isHeadPositionCorrect'] ?? true,
      );
}

class ColorVisionResult {
  final int score;
  final int totalPlates;
  final String type; // Red-Green, Blue-Yellow, None

  ColorVisionResult({
    required this.score,
    required this.totalPlates,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'score': score,
        'totalPlates': totalPlates,
        'type': type,
      };

  factory ColorVisionResult.fromJson(Map<String, dynamic> json) =>
      ColorVisionResult(
        score: json['score'] ?? 0,
        totalPlates: json['totalPlates'] ?? 0,
        type: json['type'] ?? 'None',
      );
}

class PupilReflexResult {
  final double reactionTimeMs;
  final bool isNormal;
  final double constrictionRatio;

  PupilReflexResult({
    required this.reactionTimeMs,
    required this.isNormal,
    required this.constrictionRatio,
  });

  Map<String, dynamic> toJson() => {
        'reactionTimeMs': reactionTimeMs,
        'isNormal': isNormal,
        'constrictionRatio': constrictionRatio,
      };

  factory PupilReflexResult.fromJson(Map<String, dynamic> json) =>
      PupilReflexResult(
        reactionTimeMs: (json['reactionTimeMs'] ?? 0.0).toDouble(),
        isNormal: json['isNormal'] ?? false,
        constrictionRatio: (json['constrictionRatio'] ?? 0.0).toDouble(),
      );
}

class FieldOfVisionResult {
  final int detectedStimuli;
  final int totalStimuli;
  final double averageReactionTimeMs;
  final String locationDeficits; // "Left-Top", "Right-Bottom", etc.

  FieldOfVisionResult({
    required this.detectedStimuli,
    required this.totalStimuli,
    required this.averageReactionTimeMs,
    this.locationDeficits = '',
  });

  Map<String, dynamic> toJson() => {
        'detectedStimuli': detectedStimuli,
        'totalStimuli': totalStimuli,
        'averageReactionTimeMs': averageReactionTimeMs,
        'locationDeficits': locationDeficits,
      };

  factory FieldOfVisionResult.fromJson(Map<String, dynamic> json) =>
      FieldOfVisionResult(
        detectedStimuli: json['detectedStimuli'] ?? 0,
        totalStimuli: json['totalStimuli'] ?? 0,
        averageReactionTimeMs: (json['averageReactionTimeMs'] ?? 0.0).toDouble(),
        locationDeficits: json['locationDeficits'] ?? '',
      );
}

class RefractionResult {
  final double estimatedSphereOD;
  final double estimatedSphereOS;
  final String riskLabel; // High Myopia Risk, etc.

  RefractionResult({
    required this.estimatedSphereOD,
    required this.estimatedSphereOS,
    required this.riskLabel,
  });

  Map<String, dynamic> toJson() => {
        'estimatedSphereOD': estimatedSphereOD,
        'estimatedSphereOS': estimatedSphereOS,
        'riskLabel': riskLabel,
      };

  factory RefractionResult.fromJson(Map<String, dynamic> json) =>
      RefractionResult(
        estimatedSphereOD: (json['estimatedSphereOD'] ?? 0.0).toDouble(),
        estimatedSphereOS: (json['estimatedSphereOS'] ?? 0.0).toDouble(),
        riskLabel: json['riskLabel'] ?? 'Unknown',
      );
}
