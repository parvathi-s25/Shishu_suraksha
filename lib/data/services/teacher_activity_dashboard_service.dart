import '../models/intervention_models.dart';
import '../models/assessment_result_models.dart';

/// Teacher Activity Dashboard Service
/// 
/// Manages activity sessions, tracks progress, and provides insights
/// to Anganwadi workers on intervention effectiveness.
class TeacherActivityDashboardService {
  
  /// Records a completed activity session
  static ActivitySession recordActivitySession({
    required String sessionId,
    required String childId,
    required String activityId,
    required int durationMinutes,
    required bool completed,
    required double childEngagementScore, // 0-100
    required double performanceScore, // 0-100
    required String workerNotes,
  }) {
    return ActivitySession(
      sessionId: sessionId,
      childId: childId,
      activityId: activityId,
      sessionDate: DateTime.now(),
      durationMinutes: durationMinutes,
      completed: completed,
      childEngagementScore: childEngagementScore,
      performanceScore: performanceScore,
      workerNotes: workerNotes,
      requiresFollowUp: performanceScore < 40 || !completed,
      nextSessionScheduled: _calculateNextSessionDate(completed),
    );
  }

  /// Analyzes progress over multiple sessions
  static ActivityProgressAnalysis analyzeSessionProgress({
    required List<ActivitySession> sessions,
    required String childId,
    required String activityId,
  }) {
    // Filter sessions for this activity
    final activitySessions = sessions
        .where((s) => s.childId == childId && s.activityId == activityId)
        .toList()
      ..sort((a, b) => a.sessionDate.compareTo(b.sessionDate));

    if (activitySessions.isEmpty) {
      return ActivityProgressAnalysis(
        activityId: activityId,
        totalSessions: 0,
        completionRate: 0,
        averageEngagement: 0,
        averagePerformance: 0,
        trend: 'No data',
      );
    }

    // Calculate metrics
    final completedCount =
        activitySessions.where((s) => s.completed).length;
    final completionRate = completedCount / activitySessions.length;

    final engagementScores =
        activitySessions.map((s) => s.childEngagementScore).toList();
    final averageEngagement =
        engagementScores.reduce((a, b) => a + b) / engagementScores.length;

    final performanceScores =
        activitySessions.map((s) => s.performanceScore).toList();
    final averagePerformance =
        performanceScores.reduce((a, b) => a + b) / performanceScores.length;

    // Determine trend
    final trend = _calculateTrend(performanceScores);

    // Days since first session
    final firstSession = activitySessions.first;
    final lastSession = activitySessions.last;
    final daysSinceStart = lastSession.sessionDate
        .difference(firstSession.sessionDate)
        .inDays;

    return ActivityProgressAnalysis(
      activityId: activityId,
      totalSessions: activitySessions.length,
      completionRate: completionRate,
      averageEngagement: averageEngagement,
      averagePerformance: averagePerformance,
      trend: trend,
      daysSinceStart: daysSinceStart,
      firstPerformance: performanceScores.first,
      lastPerformance: performanceScores.last,
    );
  }

  /// Generates activity performance report for a child
  static ChildActivityReport generateChildActivityReport({
    required String childId,
    required List<ActivitySession> allSessions,
    required List<Activity> assignedActivities,
  }) {
    final childSessions = allSessions.where((s) => s.childId == childId).toList();

    // Analyze each activity
    final activityAnalyses = <ActivityProgressAnalysis>[];
    for (final activity in assignedActivities) {
      final analysis = analyzeSessionProgress(
        sessions: allSessions,
        childId: childId,
        activityId: activity.activityId,
      );
      activityAnalyses.add(analysis);
    }

    // Calculate overall metrics
    final totalCompletedSessions =
        childSessions.where((s) => s.completed).length;
    final overallCompletionRate = childSessions.isEmpty
        ? 0
        : totalCompletedSessions / childSessions.length;

    final totalEngagement = childSessions.isEmpty
        ? 0
        : childSessions
                .map((s) => s.childEngagementScore)
                .reduce((a, b) => a + b) /
            childSessions.length;

    final totalPerformance = childSessions.isEmpty
        ? 0
        : childSessions
                .map((s) => s.performanceScore)
                .reduce((a, b) => a + b) /
            childSessions.length;

    // Most and least effective activities
    final mostEffectiveActivity = activityAnalyses.reduce((a, b) =>
        a.averagePerformance > b.averagePerformance ? a : b);
    final leastEffectiveActivity = activityAnalyses.reduce((a, b) =>
        a.averagePerformance < b.averagePerformance ? a : b);

    // Recommendations
    final recommendations = _generateActivityRecommendations(
      activityAnalyses: activityAnalyses,
      overallPerformance: totalPerformance,
    );

    return ChildActivityReport(
      childId: childId,
      reportDate: DateTime.now(),
      totalSessionsCompleted: totalCompletedSessions,
      overallCompletionRate: overallCompletionRate,
      averageEngagementScore: totalEngagement,
      averagePerformanceScore: totalPerformance,
      mostEffectiveActivityId: mostEffectiveActivity.activityId,
      leastEffectiveActivityId: leastEffectiveActivity.activityId,
      activityAnalyses: activityAnalyses,
      recommendations: recommendations,
    );
  }

  /// Gets activities that need adjustment or follow-up
  static List<ActivitySession> getFollowUpActivities({
    required List<ActivitySession> sessions,
    required String childId,
  }) {
    return sessions
        .where((s) =>
            s.childId == childId &&
            (s.requiresFollowUp || !s.completed))
        .toList();
  }

  /// Calculates engagement metrics by activity category
  static Map<String, double> getEngagementByCategory({
    required List<ActivitySession> sessions,
    required String childId,
    required List<Activity> activities,
  }) {
    final result = <String, double>{};

    final childSessions =
        sessions.where((s) => s.childId == childId).toList();

    for (final activity in activities) {
      final activitySessions = childSessions
          .where((s) => s.activityId == activity.activityId)
          .toList();

      if (activitySessions.isNotEmpty) {
        final avgEngagement = activitySessions
                .map((s) => s.childEngagementScore)
                .reduce((a, b) => a + b) /
            activitySessions.length;

        final categoryName =
            activity.category.toString().split('.').last;
        result[categoryName] = avgEngagement;
      }
    }

    return result;
  }

  /// Generates weekly activity schedule for teacher
  static List<ScheduledActivity> generateWeeklySchedule({
    required List<Activity> assignedActivities,
    required List<ActivitySession> completedSessions,
    required String childId,
  }) {
    final schedule = <ScheduledActivity>[];

    // Distribute activities across week
    const daysPerWeek = 5; // activities on weekdays
    final activitiesPerDay =
        (assignedActivities.length / daysPerWeek).ceil();

    for (int day = 0; day < daysPerWeek; day++) {
      final dayActivities = assignedActivities
          .skip(day * activitiesPerDay)
          .take(activitiesPerDay)
          .toList();

      for (int i = 0; i < dayActivities.length; i++) {
        final activity = dayActivities[i];
        final hour = 9 + (i * 0.5); // Start at 9 AM, 30 min activities

        schedule.add(
          ScheduledActivity(
            dayOfWeek: day,
            activity: activity,
            scheduledTime: '$hour:00',
            childId: childId,
          ),
        );
      }
    }

    return schedule;
  }

  // ========================================================================
  // PRIVATE HELPER METHODS
  // ========================================================================

  static DateTime _calculateNextSessionDate(bool completed) {
    if (completed) {
      return DateTime.now().add(Duration(days: 2)); // Repeat in 2 days if successful
    } else {
      return DateTime.now().add(Duration(days: 1)); // Retry next day if not completed
    }
  }

  static String _calculateTrend(List<double> performanceScores) {
    if (performanceScores.length < 2) {
      return 'insufficient_data';
    }

    final recent = performanceScores.sublist(
        (performanceScores.length / 2).toInt());
    final earlier = performanceScores.sublist(
        0,
        (performanceScores.length / 2).toInt());

    final recentAvg =
        recent.reduce((a, b) => a + b) / recent.length;
    final earlierAvg =
        earlier.reduce((a, b) => a + b) / earlier.length;

    final improvement = recentAvg - earlierAvg;

    if (improvement > 10) {
      return 'improving';
    } else if (improvement < -10) {
      return 'declining';
    } else {
      return 'stable';
    }
  }

  static List<String> _generateActivityRecommendations({
    required List<ActivityProgressAnalysis> activityAnalyses,
    required double overallPerformance,
  }) {
    final recommendations = <String>[];

    // Find struggling activities
    final strugglingActivities = activityAnalyses
        .where((a) => a.averagePerformance < 40)
        .toList();

    if (strugglingActivities.isNotEmpty) {
      recommendations.add(
        '⚠️ ${strugglingActivities.length} activities have low performance scores. '
        'Consider simplifying or breaking into smaller steps.',
      );
    }

    // Low engagement
    final lowEngagementActivities = activityAnalyses
        .where((a) => a.averageEngagement < 50)
        .toList();

    if (lowEngagementActivities.isNotEmpty) {
      recommendations.add(
        '📌 Low engagement detected in ${lowEngagementActivities.length} activities. '
        'Try making activities more game-like or add social elements.',
      );
    }

    // High completion activities
    final highCompletionActivities = activityAnalyses
        .where((a) => a.completionRate > 0.8)
        .toList();

    if (highCompletionActivities.isNotEmpty) {
      recommendations.add(
        '✓ Excellent completion rate in ${highCompletionActivities.length} activities. '
        'Increase difficulty or add variations.',
      );
    }

    // Overall progress
    if (overallPerformance >= 75) {
      recommendations.add(
        '🎉 Overall performance is strong. Child is ready for more challenging activities.',
      );
    } else if (overallPerformance >= 50) {
      recommendations.add(
        '📊 Child is making steady progress. Continue current activities with adjustments.',
      );
    } else {
      recommendations.add(
        '⚠️ Overall performance is below expectations. Review and simplify activities. '
        'Increase one-on-one support.',
      );
    }

    return recommendations;
  }
}

// ============================================================================
// HELPER MODELS
// ============================================================================

/// Activity progress analysis
class ActivityProgressAnalysis {
  final String activityId;
  final int totalSessions;
  final double completionRate; // 0-1
  final double averageEngagement; // 0-100
  final double averagePerformance; // 0-100
  final String trend; // 'improving', 'stable', 'declining'
  final int? daysSinceStart;
  final double? firstPerformance;
  final double? lastPerformance;

  ActivityProgressAnalysis({
    required this.activityId,
    required this.totalSessions,
    required this.completionRate,
    required this.averageEngagement,
    required this.averagePerformance,
    required this.trend,
    this.daysSinceStart,
    this.firstPerformance,
    this.lastPerformance,
  });
}

/// Child's activity report summary
class ChildActivityReport {
  final String childId;
  final DateTime reportDate;
  final int totalSessionsCompleted;
  final double overallCompletionRate;
  final double averageEngagementScore;
  final double averagePerformanceScore;
  final String mostEffectiveActivityId;
  final String leastEffectiveActivityId;
  final List<ActivityProgressAnalysis> activityAnalyses;
  final List<String> recommendations;

  ChildActivityReport({
    required this.childId,
    required this.reportDate,
    required this.totalSessionsCompleted,
    required this.overallCompletionRate,
    required this.averageEngagementScore,
    required this.averagePerformanceScore,
    required this.mostEffectiveActivityId,
    required this.leastEffectiveActivityId,
    required this.activityAnalyses,
    required this.recommendations,
  });
}

/// Scheduled activity
class ScheduledActivity {
  final int dayOfWeek; // 0=Monday, 4=Friday
  final Activity activity;
  final String scheduledTime; // HH:MM format
  final String childId;

  ScheduledActivity({
    required this.dayOfWeek,
    required this.activity,
    required this.scheduledTime,
    required this.childId,
  });

  String getDayName() {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    return days[dayOfWeek];
  }
}
