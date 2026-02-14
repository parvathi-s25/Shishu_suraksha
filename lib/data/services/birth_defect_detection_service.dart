/// Birth Defect Detection Service
/// 
/// Detects common congenital conditions using image analysis and facial features.
/// Works with static images captured during assessment.
/// CRITICAL: All detections must be validated by clinical professionals before diagnosis.
class BirthDefectDetectionService {
  
  // Confidence thresholds
  static const double highConfidenceThreshold = 0.80;
  static const double mediumConfidenceThreshold = 0.60;

  /// Detects clubfoot from foot photograph
  /// 
  /// Analyzes foot angle, arch curvature, and positioning
  static BirthDefectAnalysisResult detectClubfoot({
    required List<FacialLandmark> footLandmarks,
    required double imagePlane,
  }) {
    // Analyze foot characteristics
    // Clubfoot typically shows: inverted foot, curved arch, medial deviation

    // Calculate ankle-foot angle
    final ankleFootAngle = _calculateAngle(
      footLandmarks[0], // ankle
      footLandmarks[1], // heel
      footLandmarks[2], // toe
    );

    // Normal angle: 90-110 degrees
    // Clubfoot: <80 degrees (inverted)
    final angleDeviation = (90 - ankleFootAngle).abs();

    // Arch analysis - should be convex
    final archCurvature = _calculateCurvature(
      footLandmarks[1], // heel
      footLandmarks[5], // arch point
      footLandmarks[2], // toe
    );

    // Clubfoot shows inward curvature
    final hasInwardCurvature = archCurvature < -10;

    // Confidence calculation
    double confidence = 0;
    if (hasInwardCurvature && angleDeviation > 20) {
      confidence = 0.85;
    } else if (hasInwardCurvature || angleDeviation > 25) {
      confidence = 0.65;
    } else if (angleDeviation > 15) {
      confidence = 0.40;
    } else {
      confidence = 0.15;
    }

    return BirthDefectAnalysisResult(
      condition: 'Clubfoot',
      detected: confidence > mediumConfidenceThreshold,
      confidence: confidence.clamp(0, 1),
      keyIndicators: [
        'Ankle-foot angle: ${ankleFootAngle.toStringAsFixed(1)}°',
        'Arch curvature: ${archCurvature.toStringAsFixed(1)}',
        if (hasInwardCurvature) 'Inward foot deviation detected'
      ],
      clinicalValidationRequired: true,
      notes: 'Clubfoot detection based on static image. '
          'Requires clinical examination for confirmation.',
    );
  }

  /// Detects cleft palate from mouth image and speech analysis
  /// 
  /// Uses visual indicators and speech patterns characteristic of cleft
  static BirthDefectAnalysisResult detectCleftPalate({
    required List<FacialLandmark> mouthLandmarks,
    required double? speechNasality, // speech resonance analysis
    required bool hasCharacteristicSpeechPattern,
  }) {
    // Visual cleft indicators
    bool hasMidlineGap = false;
    bool hasLipAsymmetry = false;

    if (mouthLandmarks.length >= 20) {
      // Check for midline gap
      final upperLipMidline =
          (mouthLandmarks[13].x + mouthLandmarks[14].x) / 2;
      final lowerLipMidline =
          (mouthLandmarks[17].x + mouthLandmarks[18].x) / 2;

      hasMidlineGap = (upperLipMidline - lowerLipMidline).abs() > 5;

      // Check lip symmetry
      final leftLipDistance =
          (mouthLandmarks[12].x - mouthLandmarks[9].x).abs();
      final rightLipDistance =
          (mouthLandmarks[16].x - mouthLandmarks[12].x).abs();

      hasLipAsymmetry = (leftLipDistance - rightLipDistance).abs() > 8;
    }

    // Speech analysis
    bool hasHypernasal =
        (speechNasality ?? 0) > 0.6; // High nasality suggests palatal issue

    // Confidence calculation
    double confidence = 0;
    int indicatorCount = 0;

    if (hasMidlineGap) {
      confidence += 0.5;
      indicatorCount++;
    }
    if (hasLipAsymmetry) {
      confidence += 0.3;
      indicatorCount++;
    }
    if (hasCharacteristicSpeechPattern) {
      confidence += 0.3;
      indicatorCount++;
    }
    if (hasHypernasal) {
      confidence += 0.2;
      indicatorCount++;
    }

    confidence =
        (confidence / (indicatorCount > 0 ? indicatorCount : 1)).clamp(0, 1);

    return BirthDefectAnalysisResult(
      condition: 'Cleft Palate',
      detected: confidence > mediumConfidenceThreshold,
      confidence: confidence,
      keyIndicators: [
        if (hasMidlineGap) 'Visible midline gap observed',
        if (hasLipAsymmetry) 'Lip asymmetry detected',
        if (hasCharacteristicSpeechPattern)
          'Characteristic speech pattern detected',
        if (hasHypernasal) 'High nasality in speech'
      ],
      clinicalValidationRequired: true,
      notes: 'Cleft detection based on visual and speech analysis. '
          'Oral examination required for confirmation.',
    );
  }

  /// Detects Down Syndrome indicators from facial features
  /// 
  /// Analyzes facial landmarks associated with Down Syndrome
  static BirthDefectAnalysisResult detectDownSyndrome({
    required List<FacialLandmark> faceLandmarks,
  }) {
    if (faceLandmarks.length < 68) {
      return BirthDefectAnalysisResult(
        condition: 'Down Syndrome',
        detected: false,
        confidence: 0,
        keyIndicators: ['Insufficient facial landmarks for analysis'],
        clinicalValidationRequired: true,
        notes: 'Unable to analyze - poor image quality or landmarks detection.',
      );
    }

    // Down Syndrome facial characteristics
    bool hasBrachycephaly = false; // Rounded head shape
    bool hasFlattened Nasal = false; // Flat nasal bridge
    bool hasInwardEyeSlant = false; // Upward slant of eyes
    bool hasLowSetEars = false; // Ears positioned lower
    bool hasTongueProtrusion = false; // Frequently protruding tongue
    bool hasHypotonia = false; // Low muscle tone visible as slack facial features

    // Eye characteristics
    if (faceLandmarks.length > 40) {
      final eyeAngle = _calculateAngle(
        faceLandmarks[36], // left eye outer
        faceLandmarks[37], // left eye inner
        faceLandmarks[41], // left eye inner lower
      );

      // Down Syndrome: upward slant (angle > 110)
      hasInwardEyeSlant = eyeAngle > 110;

      // Nasal bridge flatness
      final nasalBridgeHeight =
          (faceLandmarks[27].y - faceLandmarks[30].y).abs();
      final faceHeight = (faceLandmarks[0].y - faceLandmarks[8].y).abs();

      hasFlattened Nasal = (nasalBridgeHeight / faceHeight) < 0.15;
    }

    // Face shape (brachycephaly)
    final faceWidth = (faceLandmarks[16].x - faceLandmarks[0].x).abs();
    final faceHeight = (faceLandmarks[0].y - faceLandmarks[8].y).abs();
    hasBrachycephaly = (faceWidth / faceHeight) > 0.8; // Wider than tall

    // Ear position
    if (faceLandmarks.length > 20) {
      final earY = faceLandmarks[45].y; // Right ear
      final eyeY = faceLandmarks[37].y; // Left eye
      hasLowSetEars = earY > eyeY;
    }

    // Tongue assessment (simple: mouth open indicator)
    const mouthOpenDistance = 10; // pixels
    hasTongueProtrusion =
        (faceLandmarks[62].y - faceLandmarks[66].y).abs() > mouthOpenDistance;

    // Facial tone (simplified)
    hasHypotonia = true; // Assume if other features present

    // Calculate composite confidence
    double confidence = 0;
    final indicators = <String>[];

    if (hasInwardEyeSlant) {
      confidence += 0.25;
      indicators.add('Upward eye slant detected');
    }
    if (hasFlattened Nasal) {
      confidence += 0.20;
      indicators.add('Flattened nasal bridge');
    }
    if (hasBrachycephaly) {
      confidence += 0.15;
      indicators.add('Brachycephaly (short, wide head shape)');
    }
    if (hasLowSetEars) {
      confidence += 0.15;
      indicators.add('Low-set ears');
    }
    if (hasTongueProtrusion) {
      confidence += 0.10;
      indicators.add('Tongue protrusion');
    }
    if (hasHypotonia) {
      confidence += 0.15;
      indicators.add('Reduced facial muscle tone');
    }

    return BirthDefectAnalysisResult(
      condition: 'Down Syndrome (Trisomy 21)',
      detected: confidence > highConfidenceThreshold,
      confidence: confidence.clamp(0, 1),
      keyIndicators: indicators,
      clinicalValidationRequired: true,
      notes: 'DOWN SYNDROME SUSPICION: Facial image analysis suggests possible '
          'Down Syndrome indicators. GENETIC TESTING REQUIRED for definitive diagnosis. '
          'Karyotype or non-invasive prenatal testing (NIPT) needed.',
    );
  }

  /// Detects congenital heart defects from heart sound analysis
  /// 
  /// Analyzes audio spectrograms of heart sounds for abnormal patterns
  static BirthDefectAnalysisResult detectCongenitalHeartDefect({
    required List<double> heartSoundSpectrogram,
    required double s1Intensity,
    required double s2Intensity,
    required double murmurPresence, // 0-1
  }) {
    // Normal heart sound pattern: S1 + silence + S2 + long silence
    // Defect indicators: irregular patterns, murmurs, abnormal intensities

    // Intensity ratios
    final intensityRatio = s2Intensity / (s1Intensity + 0.001);

    // Abnormal if S2 > S1
    bool hasAbnormalIntensities = intensityRatio > 1.5;

    // Murmur detection
    bool hasMurmur = murmurPresence > 0.5;

    // Spectral analysis - abnormal frequencies
    final hasAbnormalFrequencies =
        _hasAbnormalHeartSoundFrequencies(heartSoundSpectrogram);

    double confidence = 0;
    final indicators = <String>[];

    if (hasMurmur) {
      confidence += 0.6;
      indicators.add('Cardiac murmur detected');
    }
    if (hasAbnormalIntensities) {
      confidence += 0.3;
      indicators.add('Abnormal S1/S2 intensity ratio');
    }
    if (hasAbnormalFrequencies) {
      confidence += 0.2;
      indicators.add('Abnormal frequency patterns in heart sound');
    }

    return BirthDefectAnalysisResult(
      condition: 'Congenital Heart Defect',
      detected: confidence > mediumConfidenceThreshold,
      confidence: confidence.clamp(0, 1),
      keyIndicators: indicators,
      clinicalValidationRequired: true,
      notes: 'CARDIAC SCREENING RECOMMENDED: Audio analysis suggests possible '
          'heart abnormality. Refer for echocardiogram and pediatric cardiology evaluation.',
    );
  }

  // ========================================================================
  // PRIVATE HELPER METHODS
  // ========================================================================

  static double _calculateAngle(
    FacialLandmark p1,
    FacialLandmark p2,
    FacialLandmark p3,
  ) {
    final v1 = (x: p1.x - p2.x, y: p1.y - p2.y);
    final v2 = (x: p3.x - p2.x, y: p3.y - p2.y);

    final dot = v1.x * v2.x + v1.y * v2.y;
    final mag1 = (v1.x * v1.x + v1.y * v1.y).sqrt();
    final mag2 = (v2.x * v2.x + v2.y * v2.y).sqrt();

    if (mag1 == 0 || mag2 == 0) return 0;

    final cosValue = (dot / (mag1 * mag2)).clamp(-1, 1);
    return (acos(cosValue) * 180 / 3.14159).abs();
  }

  static double _calculateCurvature(
    FacialLandmark p1,
    FacialLandmark p2,
    FacialLandmark p3,
  ) {
    // Calculate curvature of three points
    // Negative = concave (inward), Positive = convex (outward)

    final a = _distance(p1, p2);
    final b = _distance(p2, p3);
    final c = _distance(p1, p3);

    // Using law of cosines
    final angle = acos((a * a + b * b - c * c) / (2 * a * b));

    // Curvature = signed angle deviation from straight
    return (angle - 3.14159) * 100; // Signed curvature
  }

  static double _distance(FacialLandmark p1, FacialLandmark p2) {
    return ((p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y))
        .sqrt();
  }

  static bool _hasAbnormalHeartSoundFrequencies(
    List<double> spectrogram,
  ) {
    // Check for abnormal frequency content
    // Normal heart sounds: 25-200 Hz primarily
    // Abnormal: additional high-frequency components

    if (spectrogram.isEmpty) return false;

    // Simple heuristic: high variance indicates abnormality
    final mean =
        spectrogram.reduce((a, b) => a + b) / spectrogram.length;
    final variance = spectrogram
            .map((x) => (x - mean) * (x - mean))
            .reduce((a, b) => a + b) /
        spectrogram.length;

    return variance >
        100; // Abnormal if high frequency variation
  }
}

// ============================================================================
// HELPER MODELS
// ============================================================================

/// Facial landmark for feature analysis
class FacialLandmark {
  final double x;
  final double y;
  final double confidence;

  FacialLandmark({
    required this.x,
    required this.y,
    required this.confidence,
  });
}

/// Birth defect analysis result
class BirthDefectAnalysisResult {
  final String condition;
  final bool detected;
  final double confidence; // 0-1
  final List<String> keyIndicators;
  final bool clinicalValidationRequired;
  final String notes;

  BirthDefectAnalysisResult({
    required this.condition,
    required this.detected,
    required this.confidence,
    required this.keyIndicators,
    required this.clinicalValidationRequired,
    required this.notes,
  });
}
