/// Cognitive Assessment Service
/// 
/// Assesses cognitive abilities including memory, pattern recognition,
/// problem-solving, and attention span.
class CognitiveAssessmentService {
  
  // Age-appropriate cognitive benchmarks
  static const Map<int, Map<String, double>> cognitiveBenchmarks = {
    12: {
      'memory': 30.0,
      'pattern_recognition': 20.0,
      'problem_solving': 15.0,
      'attention_span': 30.0, // seconds
    },
    18: {
      'memory': 45.0,
      'pattern_recognition': 35.0,
      'problem_solving': 25.0,
      'attention_span': 45.0,
    },
    24: {
      'memory': 60.0,
      'pattern_recognition': 50.0,
      'problem_solving': 40.0,
      'attention_span': 60.0,
    },
    36: {
      'memory': 75.0,
      'pattern_recognition': 70.0,
      'problem_solving': 65.0,
      'attention_span': 120.0,
    },
    48: {
      'memory': 85.0,
      'pattern_recognition': 85.0,
      'problem_solving': 80.0,
      'attention_span': 180.0,
    },
    60: {
      'memory': 95.0,
      'pattern_recognition': 95.0,
      'problem_solving': 90.0,
      'attention_span': 240.0,
    },
  };

  /// Analyzes memory performance
  /// 
  /// Input: recall test results (shapes, colors, sequences)
  /// Output: memory score
  static CognitiveAnalysisResult analyzeMemory({
    required List<String> presentedItems,
    required List<String> recalledItems,
    required int ageMonths,
    required String testType, // 'immediate', 'delayed'
  }) {
    // Calculate recall rate
    int correctRecalls = 0;
    for (final item in recalledItems) {
      if (presentedItems.contains(item)) {
        correctRecalls++;
      }
    }

    final recallRate = (correctRecalls / presentedItems.length).clamp(0, 1);

    // Get age benchmark
    final benchmark = cognitiveBenchmarks[_getClosestAge(ageMonths)]?['memory'] ?? 60.0;

    // Memory score (0-100)
    double memoryScore = (recallRate * 100).clamp(0, 100);

    // Adjust for test type
    if (testType == 'delayed') {
      memoryScore = (memoryScore * 0.9)
          .clamp(0, 100); // Delayed recall typically slightly lower
    }

    return CognitiveAnalysisResult(
      memoryScore: memoryScore,
      recallRate: recallRate,
      correctRecalls: correctRecalls,
      totalItems: presentedItems.length,
      testType: testType,
    );
  }

  /// Analyzes pattern recognition abilities
  /// 
  /// Input: pattern completion test results
  /// Output: pattern recognition score
  static CognitiveAnalysisResult analyzePatternRecognition({
    required List<Pattern> patterns,
    required List<String> childResponses,
    required int ageMonths,
  }) {
    // Evaluate each pattern response
    int correctPatterns = 0;
    for (int i = 0; i < patterns.length; i++) {
      if (i < childResponses.length) {
        if (patterns[i].isCorrect(childResponses[i])) {
          correctPatterns++;
        }
      }
    }

    final patternAccuracy =
        (correctPatterns / patterns.length).clamp(0, 1);

    // Pattern recognition score (0-100)
    double patternScore = (patternAccuracy * 100);

    // Difficulty adjustment
    final averageDifficulty =
        patterns.map((p) => p.difficulty).reduce((a, b) => a + b) /
        patterns.length;
    patternScore = patternScore * (0.8 + averageDifficulty * 0.4);

    return CognitiveAnalysisResult(
      patternRecognitionScore: (patternScore).clamp(0, 100),
      patternAccuracy: patternAccuracy,
      correctPatterns: correctPatterns,
      totalPatterns: patterns.length,
    );
  }

  /// Analyzes problem-solving ability
  /// 
  /// Input: problem completion data
  /// Output: problem-solving score
  static CognitiveAnalysisResult analyzeProblemSolving({
    required List<Problem> problems,
    required List<String> solutions,
    required List<int> solutionTimes, // seconds taken per problem
    required int ageMonths,
  }) {
    // Evaluate solutions
    int correctSolutions = 0;
    double totalTimeEfficiency = 0;

    for (int i = 0; i < problems.length; i++) {
      if (i < solutions.length) {
        if (problems[i].isCorrectSolution(solutions[i])) {
          correctSolutions++;

          // Time efficiency (faster = better, but not if incorrect)
          final timeExpected =
              problems[i].expectedCompletionTime; // in seconds
          if (i < solutionTimes.length && solutionTimes[i] > 0) {
            final efficiency =
                (timeExpected / solutionTimes[i]).clamp(0.5, 2.0);
            totalTimeEfficiency += efficiency;
          }
        }
      }
    }

    final solutionAccuracy =
        (correctSolutions / problems.length).clamp(0, 1);
    final timeEfficiency =
        (totalTimeEfficiency / correctSolutions).clamp(0, 2);

    // Problem-solving score combines accuracy and efficiency
    double problemScore =
        (solutionAccuracy * 80) + (timeEfficiency / 2 * 20);

    return CognitiveAnalysisResult(
      problemSolvingScore: (problemScore).clamp(0, 100),
      solutionAccuracy: solutionAccuracy,
      correctSolutions: correctSolutions,
      totalProblems: problems.length,
      averageCompletionTime:
          solutionTimes.isEmpty ? 0 : solutionTimes.reduce((a, b) => a + b) / solutionTimes.length,
    );
  }

  /// Analyzes attention span
  /// 
  /// Input: task engagement data, duration maintained
  /// Output: attention score
  static CognitiveAnalysisResult analyzeAttentionSpan({
    required double taskDurationSeconds,
    required List<int> attentionPoints, // 1=attentive, 0=distracted, per second
    required int ageMonths,
  }) {
    // Calculate sustained attention percentage
    final totalAttentive =
        attentionPoints.where((p) => p == 1).length;
    final attentionRate =
        (totalAttentive / attentionPoints.length).clamp(0, 1);

    // Get age benchmark
    final benchmark =
        cognitiveBenchmarks[_getClosestAge(ageMonths)]?['attention_span'] ?? 60.0;

    // Attention score (0-100)
    double attentionScore = 20.0; // minimum

    if (taskDurationSeconds < benchmark * 0.25) {
      attentionScore = 20.0;
    } else if (taskDurationSeconds < benchmark * 0.5) {
      attentionScore = 40.0;
    } else if (taskDurationSeconds < benchmark * 0.75) {
      attentionScore = 60.0;
    } else if (taskDurationSeconds < benchmark) {
      attentionScore = 80.0;
    } else {
      attentionScore = 100.0;
    }

    // Adjust based on sustained attention quality
    attentionScore = (attentionScore * attentionRate).clamp(0, 100);

    return CognitiveAnalysisResult(
      attentionScore: attentionScore,
      taskDuraation: taskDurationSeconds,
      attentionRate: attentionRate,
      attentionBenchmark: benchmark,
    );
  }

  /// Calculates overall cognitive score
  static double calculateOverallCognitiveScore({
    required double memoryScore,
    required double patternScore,
    required double problemScore,
    required double attentionScore,
  }) {
    // Weighted average: 25% each
    return (memoryScore * 0.25 +
            patternScore * 0.25 +
            problemScore * 0.25 +
            attentionScore * 0.25)
        .clamp(0, 100);
  }

  /// Calculates cognitive developmental age
  static int calculateCognitiveAge(
    double cognitiveScore,
    int chronologicalAge,
  ) {
    // Map cognitive score to developmental age
    if (cognitiveScore >= 95) {
      return chronologicalAge;
    } else if (cognitiveScore >= 85) {
      return (chronologicalAge * 0.95).toInt();
    } else if (cognitiveScore >= 75) {
      return (chronologicalAge * 0.90).toInt();
    } else if (cognitiveScore >= 65) {
      return (chronologicalAge * 0.80).toInt();
    } else if (cognitiveScore >= 50) {
      return (chronologicalAge * 0.70).toInt();
    } else {
      return (chronologicalAge * 0.60).toInt();
    }
  }

  // Helper method to get closest age from benchmarks
  static int _getClosestAge(int ageMonths) {
    final ages = cognitiveBenchmarks.keys.toList()..sort();

    if (ageMonths <= ages.first) return ages.first;
    if (ageMonths >= ages.last) return ages.last;

    for (int i = 0; i < ages.length - 1; i++) {
      if (ageMonths >= ages[i] && ageMonths < ages[i + 1]) {
        final diff1 = (ageMonths - ages[i]).abs();
        final diff2 = (ages[i + 1] - ageMonths).abs();
        return diff1 < diff2 ? ages[i] : ages[i + 1];
      }
    }

    return ages.last;
  }
}

// ============================================================================
// HELPER MODELS
// ============================================================================

/// Represents a pattern in pattern recognition test
class Pattern {
  final String id;
  final String description;
  final double difficulty; // 0-1 (0=easy, 1=hard)
  final String correctAnswer;

  Pattern({
    required this.id,
    required this.description,
    required this.difficulty,
    required this.correctAnswer,
  });

  bool isCorrect(String response) {
    return response.toLowerCase() == correctAnswer.toLowerCase();
  }
}

/// Represents a problem in problem-solving test
class Problem {
  final String id;
  final String description;
  final double difficulty; // 0-1
  final String correctSolution;
  final int expectedCompletionTime; // in seconds

  Problem({
    required this.id,
    required this.description,
    required this.difficulty,
    required this.correctSolution,
    required this.expectedCompletionTime,
  });

  bool isCorrectSolution(String solution) {
    return solution.toLowerCase() ==
        correctSolution.toLowerCase();
  }
}

/// Cognitive analysis result data
class CognitiveAnalysisResult {
  final double? memoryScore;
  final double? recallRate;
  final int? correctRecalls;
  final int? totalItems;
  final String? testType;
  
  final double? patternRecognitionScore;
  final double? patternAccuracy;
  final int? correctPatterns;
  final int? totalPatterns;
  
  final double? problemSolvingScore;
  final double? solutionAccuracy;
  final int? correctSolutions;
  final int? totalProblems;
  final double? averageCompletionTime;
  
  final double? attentionScore;
  final double? taskDuraation;
  final double? attentionRate;
  final double? attentionBenchmark;

  CognitiveAnalysisResult({
    this.memoryScore,
    this.recallRate,
    this.correctRecalls,
    this.totalItems,
    this.testType,
    this.patternRecognitionScore,
    this.patternAccuracy,
    this.correctPatterns,
    this.totalPatterns,
    this.problemSolvingScore,
    this.solutionAccuracy,
    this.correctSolutions,
    this.totalProblems,
    this.averageCompletionTime,
    this.attentionScore,
    this.taskDuraation,
    this.attentionRate,
    this.attentionBenchmark,
  });
}
