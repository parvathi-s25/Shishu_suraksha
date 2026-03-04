import 'dart:typed_data';
import 'dart:math';
import '../models/assessment_models.dart';

/// Speech & Language Assessment Service
/// 
/// Analyzes child speech patterns including clarity, vocabulary, 
/// pronunciation, and fluency using audio feature extraction.
class SpeechLanguageAssessmentService {
  
  // Language-specific age benchmarks (in months)
  static const Map<String, Map<int, int>> vocabularyBenchmarks = {
    'hindi': {
      12: 50,    // 12 months: ~50 words
      18: 150,   // 18 months: ~150 words
      24: 250,   // 2 years: ~250 words
      30: 500,   // 30 months: ~500 words
      36: 900,   // 3 years: ~900 words
      48: 2000,  // 4 years: ~2000 words
      60: 2500,  // 5 years: ~2500 words
    },
    'telugu': {
      12: 45, 18: 140, 24: 240, 30: 480, 36: 850, 48: 1900, 60: 2400,
    },
    'tamil': {
      12: 50, 18: 150, 24: 250, 30: 500, 36: 900, 48: 2000, 60: 2500,
    },
    'kannada': {
      12: 48, 18: 145, 24: 245, 30: 490, 36: 875, 48: 1950, 60: 2450,
    },
    'malayalam': {
      12: 52, 18: 155, 24: 255, 30: 510, 36: 920, 48: 2050, 60: 2550,
    },
    'bengali': {
      12: 50, 18: 150, 24: 250, 30: 500, 36: 900, 48: 2000, 60: 2500,
    },
  };

  // Phoneme inventories by age
  static const Map<int, int> expectedPhonemeCount = {
    12: 5,   // 12 months
    18: 15,  // 18 months
    24: 25,  // 2 years
    36: 40,  // 3 years
    48: 45,  // 4 years
    60: 50,  // 5 years
  };

  /// Analyzes word clarity and pronunciation
  /// 
  /// Input: audio features (MFCC, spectrogram)
  /// Output: clarity and pronunciation scores
  static SpeechAnalysisResult analyzeWordClarity({
    required List<double> mfccFeatures,
    required List<double> spectrogramData,
    required String language,
    required int ageMonths,
  }) {
    // SNR (Signal-to-Noise Ratio) calculation
    final snr = _calculateSNR(spectrogramData);

    // Clarity score (0-100) based on SNR
    // Higher SNR = clearer speech
    double clarityScore = 20 + (snr / 40 * 80).clamp(0, 80);

    // Pronunciation accuracy (0-100)
    // Based on expected phoneme production for age
    final expectedPhonemes = expectedPhonemeCount[ageMonths] ?? 40;
    final detectedPhonemes = _detectPhonemes(mfccFeatures);
    final pronunciationAccuracy =
        (detectedPhonemes / expectedPhonemes * 100).clamp(0.0, 100.0);

    return SpeechAnalysisResult(
      wordClarity: clarityScore,
      snr: snr,
      pronunciationAccuracy: pronunciationAccuracy,
      phonemesDetected: detectedPhonemes,
      expectedPhonemes: expectedPhonemes,
    );
  }

  /// Analyzes vocabulary level
  /// 
  /// Input: transcribed words or word patterns detected in audio
  /// Output: vocabulary size estimate and age equivalence
  static SpeechAnalysisResult analyzeVocabularyLevel({
    required List<String> detectedWords,
    required String language,
    required int ageMonths,
  }) {
    // Count unique words (vocabulary size)
    final vocabularySize = detectedWords.toSet().length;

    // Get age-appropriate benchmark
    final benchmark =
        vocabularyBenchmarks[language]?[ageMonths] ?? 500;

    // Vocabulary score (0-100)
    double vocabularyScore = 20.0;
    if (vocabularySize < benchmark * 0.5) {
      vocabularyScore = (vocabularySize / (benchmark * 0.5) * 30).clamp(0, 30);
    } else if (vocabularySize < benchmark) {
      vocabularyScore = 30 + (vocabularySize - benchmark * 0.5) / (benchmark * 0.5) * 40;
    } else {
      vocabularyScore = 70 + ((vocabularySize - benchmark) / benchmark * 30)
          .clamp(0, 30);
    }

    // Calculate vocabulary age equivalent
    final vocabularyAge = _calculateVocabularyAge(
      vocabularySize,
      language,
    );

    return SpeechAnalysisResult(
      vocabularySize: vocabularySize,
      vocabularyScore: vocabularyScore,
      vocabularyAge: vocabularyAge,
    );
  }

  /// Analyzes sentence formation and syntax
  /// 
  /// Input: transcribed sentences
  /// Output: sentence complexity and grammar scores
  static SpeechAnalysisResult analyzeSentenceFormation({
    required List<String> detectedSentences,
    required int ageMonths,
  }) {
    if (detectedSentences.isEmpty) {
      return SpeechAnalysisResult(
        sentenceFormation: 0,
        averageSentenceLength: 0,
      );
    }

    // Analyze sentence complexity
    final sentenceLengths = detectedSentences
        .map((s) => s.split(' ').length)
        .toList();

    final averageLength =
        sentenceLengths.reduce((a, b) => a + b) / sentenceLengths.length;

    // Age-appropriate sentence length
    double expectedLength = 2.0;
    if (ageMonths >= 24) expectedLength = 3.0;
    if (ageMonths >= 36) expectedLength = 5.0;
    if (ageMonths >= 48) expectedLength = 7.0;
    if (ageMonths >= 60) expectedLength = 9.0;

    // Sentence formation score (0-100)
    double formationScore = (averageLength / expectedLength * 80)
        .clamp(0, 100)
        .toDouble();

    // Grammar error detection (simplified)
    final grammarErrors =
        _countGrammarErrors(detectedSentences);
    if (grammarErrors > 0) {
      formationScore = (formationScore * (1 - grammarErrors * 0.1))
          .clamp(0, 100);
    }

    return SpeechAnalysisResult(
      sentenceFormation: formationScore,
      averageSentenceLength: averageLength,
      grammarErrors: grammarErrors,
    );
  }

  /// Analyzes fluency and rhythm
  /// 
  /// Input: audio timing data, speech rate
  /// Output: fluency and rhythm scores
  static SpeechAnalysisResult analyzeFluency({
    required List<double> speechTimingData,
    required double speechRateWPM,
    required int ageMonths,
  }) {
    // Stuttering/disfluency detection
    final disfluencyRate = _calculateDisfluencyRate(speechTimingData);

    // Age-appropriate speech rate (words per minute)
    double expectedWPM = 100;
    if (ageMonths < 24) expectedWPM = 80;
    if (ageMonths >= 48) expectedWPM = 120;
    if (ageMonths >= 60) expectedWPM = 140;

    // Fluency score (0-100)
    double fluencyScore = (100 - disfluencyRate * 100).clamp(0, 100);

    // Rhythm regularity (0-100)
    final rhythmRegularity = _calculateRhytmRegularity(speechTimingData);

    return SpeechAnalysisResult(
      fluencyScore: fluencyScore,
      disfluencyRate: disfluencyRate,
      speechRateWPM: speechRateWPM,
      expectedWPM: expectedWPM,
      rhythmRegularity: rhythmRegularity,
    );
  }

  /// Detects articulation issues
  /// 
  /// Input: audio features, detected phonemes
  /// Output: articulation analysis
  static SpeechAnalysisResult detectArticulationIssues({
    required List<double> mfccFeatures,
    required List<String> detectedPhonemes,
    required int ageMonths,
  }) {
    // Map developmental articulation errors by age
    final expectedErrors = _getExpectedArticulationErrors(ageMonths);

    // Find errors not expected for this age
    final unexpectedErrors = <String>[];
    for (final phoneme in detectedPhonemes) {
      if (!expectedErrors.contains(phoneme)) {
        unexpectedErrors.add(phoneme);
      }
    }

    // Articulation score
    final errorRate =
        (unexpectedErrors.length / detectedPhonemes.length).clamp(0.0, 1.0);
    final articulationScore = (100 - errorRate * 100).clamp(0.0, 100.0);

    return SpeechAnalysisResult(
      articulationScore: articulationScore,
      unexpectedArticulationErrors: unexpectedErrors,
      hasArticulationIssues: unexpectedErrors.isNotEmpty,
    );
  }

  /// Detects speech delay indicators
  /// 
  /// Input: overall speech metrics
  /// Output: delay detection result
  static SpeechAnalysisResult detectSpeechDelay({
    required double vocabularyScore,
    required double pronunciationAccuracy,
    required double sentenceFormation,
    required double fluencyScore,
    required int ageMonths,
  }) {
    // Average of all scores
    final averageScore =
        (vocabularyScore + pronunciationAccuracy + sentenceFormation + fluencyScore) / 4;

    // Speech delay thresholds by age
    const delayThreshold = 25.0; // Below 25% threshold = delay indicated

    final hasDelay = (averageScore < delayThreshold);

    // Specific delay types
    final delayTypes = <String>[];
    if (vocabularyScore < 30) delayTypes.add('expressive');
    if (pronunciationAccuracy < 30) delayTypes.add('articulation');
    if (sentenceFormation < 30) delayTypes.add('syntax');
    if (fluencyScore < 30) delayTypes.add('fluency');

    return SpeechAnalysisResult(
      overallSpeechScore: averageScore,
      hasDelay: hasDelay,
      delayTypes: delayTypes,
    );
  }

  // ========================================================================
  // PRIVATE HELPER METHODS
  // ========================================================================

  static double _calculateSNR(List<double> spectrogramData) {
    // Signal-to-Noise Ratio calculation
    if (spectrogramData.isEmpty) return 0;

    final signal = spectrogramData.reduce((a, b) => a + b) / spectrogramData.length;
    final noise = spectrogramData
            .map((x) => (x - signal) * (x - signal))
            .reduce((a, b) => a + b) /
        spectrogramData.length;

    return 10 * log((signal / (noise + 0.00001)).abs()) / 2.303; // 20*log10
  }

  static int _detectPhonemes(List<double> mfccFeatures) {
    // Simplified phoneme detection based on MFCC feature count
    // In practice, this would use a trained model
    if (mfccFeatures.isEmpty) return 0;

    // Estimate phoneme count from unique MFCC patterns
    final uniquePatterns = <int>{};
    for (int i = 0; i < mfccFeatures.length - 1; i++) {
      final pattern = (mfccFeatures[i] * 100).toInt();
      uniquePatterns.add(pattern);
    }

    return (uniquePatterns.length * 0.5).toInt().clamp(0, 50);
  }

  static int _calculateVocabularyAge(
    int vocabularySize,
    String language,
  ) {
    // Find closest age match for vocabulary size
    final benchmark =
        vocabularyBenchmarks[language] ??
        vocabularyBenchmarks['hindi']!;

    int closestAge = 12;
    int closestDiff = (benchmark[12]! - vocabularySize).abs();

    benchmark.forEach((age, vocabSize) {
      final diff = (vocabSize - vocabularySize).abs();
      if (diff < closestDiff) {
        closestDiff = diff;
        closestAge = age;
      }
    });

    return closestAge;
  }

  static int _countGrammarErrors(List<String> sentences) {
    int errors = 0;

    for (final sentence in sentences) {
      final words = sentence.split(' ');

      // Simple grammar checks
      // Subject-verb agreement
      if (words.length >= 2) {
        // Simplified check
        errors += 0; // Could be implemented with NLP
      }
    }

    return errors;
  }

  static double _calculateDisfluencyRate(List<double> timingData) {
    // Calculate rate of stuttering/disfluency
    // Based on pause irregularities
    if (timingData.length < 2) return 0;

    int disfluencies = 0;
    for (int i = 1; i < timingData.length; i++) {
      final pauseDuration = timingData[i] - timingData[i - 1];

      // Pause > 500ms in speech = disfluency
      if (pauseDuration > 0.5) {
        disfluencies++;
      }
    }

    return (disfluencies / timingData.length).clamp(0, 1);
  }

  static double _calculateRhytmRegularity(List<double> timingData) {
    // Calculate regular spacing of speech units
    if (timingData.length < 3) return 0;

    final intervals = <double>[];
    for (int i = 1; i < timingData.length; i++) {
      intervals.add(timingData[i] - timingData[i - 1]);
    }

    final mean =
        intervals.reduce((a, b) => a + b) / intervals.length;
    final variance = intervals
            .map((x) => (x - mean) * (x - mean))
            .reduce((a, b) => a + b) /
        intervals.length;

    final stdDev = sqrt(variance);

    // CV (Coefficient of Variation) - lower is more regular
    final cv = stdDev / (mean + 0.00001);

    // Convert to 0-100 score (lower CV = higher regularity)
    return (100 - (cv * 50).clamp(0.0, 100.0)).clamp(0.0, 100.0);
  }

  static List<String> _getExpectedArticulationErrors(int ageMonths) {
    // Phonemes expected to still have errors by age
    // Based on developmental articulation standards

    if (ageMonths < 24) {
      return [
        'th', 'zh', 'sh', 'ch', 'r', 'l', 'consonant_clusters'
      ];
    } else if (ageMonths < 36) {
      return ['th', 'zh', 'sh', 'r', 'l', 'consonant_clusters'];
    } else if (ageMonths < 48) {
      return ['th', 'zh', 'r', 'l', 'consonant_clusters'];
    } else if (ageMonths < 60) {
      return ['th', 'zh'];
    } else {
      return [];
    }
  }
}

// ============================================================================
// HELPER MODELS
// ============================================================================

/// Speech analysis result data
class SpeechAnalysisResult {
  final double? wordClarity;
  final double? snr;
  final double? pronunciationAccuracy;
  final int? phonemesDetected;
  final int? expectedPhonemes;
  final int? vocabularySize;
  final double? vocabularyScore;
  final int? vocabularyAge;
  final double? sentenceFormation;
  final double? averageSentenceLength;
  final int? grammarErrors;
  final double? fluencyScore;
  final double? disfluencyRate;
  final double? speechRateWPM;
  final double? expectedWPM;
  final double? rhythmRegularity;
  final double? articulationScore;
  final List<String>? unexpectedArticulationErrors;
  final bool? hasArticulationIssues;
  final double? overallSpeechScore;
  final bool? hasDelay;
  final List<String>? delayTypes;

  SpeechAnalysisResult({
    this.wordClarity,
    this.snr,
    this.pronunciationAccuracy,
    this.phonemesDetected,
    this.expectedPhonemes,
    this.vocabularySize,
    this.vocabularyScore,
    this.vocabularyAge,
    this.sentenceFormation,
    this.averageSentenceLength,
    this.grammarErrors,
    this.fluencyScore,
    this.disfluencyRate,
    this.speechRateWPM,
    this.expectedWPM,
    this.rhythmRegularity,
    this.articulationScore,
    this.unexpectedArticulationErrors,
    this.hasArticulationIssues,
    this.overallSpeechScore,
    this.hasDelay,
    this.delayTypes,
  });
}
