import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/models/child_model.dart';
import '../../../core/data/models/intervention_models.dart';
import '../../../core/data/services/teacher_activity_dashboard_service.dart';
import '../../../app/theme/colors.dart';

/// Teacher Activity Dashboard - Track interventions and child progress
/// 
/// Displays:
/// - Personalized activities for each child
/// - Session recording and performance tracking
/// - Engagement and performance metrics
/// - Weekly activity schedule
/// - Progress trends
class TeacherActivityDashboard extends ConsumerStatefulWidget {
  final ChildModel child;

  const TeacherActivityDashboard({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  ConsumerState<TeacherActivityDashboard> createState() =>
      _TeacherActivityDashboardState();
}

class _TeacherActivityDashboardState
    extends ConsumerState<TeacherActivityDashboard> {
  late TeacherActivityDashboardService _dashboardService;
  int _selectedTab = 0;

  // Mock activities for demonstration
  late List<Activity> _mockActivities;
  late List<ActivitySession> _mockSessions;

  @override
  void initState() {
    super.initState();
    _dashboardService = TeacherActivityDashboardService();
    _initializeMockData();
  }

  void _initializeMockData() {
    // Create mock activities
    _mockActivities = [
      Activity(
        activityId: 'act_001',
        title: {
          'en': 'Rainbow Bridge Walking',
          'hi': 'इंद्रधनुष पुल पर चलना',
          'te': 'ఇంద్రధనస్ వేలు నడక'
        },
        category: ActivityCategory.motorSkills,
        minAgeMonths: 18,
        maxAgeMonths: 60,
        difficulty: ActivityDifficulty.easy,
        materials: [
          ActivityMaterial(
            name: 'Painted tape or chalk line',
            isRequired: true,
            localAlternative: 'Flour line or rope',
          ),
        ],
        instructions: {
          'en': '1. Draw a curved line\n2. Ask child to walk along it\n3. Vary the line shape',
          'hi': '1. एक घुमावदार लाइन खींचें\n2. बच्चे से इसके साथ चलने के लिए कहें',
        },
        targetSkills: ['Balance', 'Coordination', 'Proprioception'],
        expectedImprovement: [
          ProgressMilestone(
            dayNumber: 1,
            expectedOutcome: 'Can walk straight line for 3 meters',
          ),
          ProgressMilestone(
            dayNumber: 7,
            expectedOutcome: 'Can walk curved line with minimal wobbles',
          ),
        ],
        recommendationScore: 0.85,
      ),
      Activity(
        activityId: 'act_002',
        title: {
          'en': 'Picture Story Telling',
          'hi': 'चित्र कहानी सुनाना',
          'te': 'చిత్ర కథ చెప్పటం'
        },
        category: ActivityCategory.speechLanguage,
        minAgeMonths: 24,
        maxAgeMonths: 60,
        difficulty: ActivityDifficulty.easy,
        materials: [
          ActivityMaterial(
            name: 'Picture cards or story books',
            isRequired: true,
            localAlternative: 'Hand-drawn pictures',
          ),
        ],
        instructions: {
          'en': '1. Show picture cards\n2. Ask "What do you see?"\n3. Encourage description',
        },
        targetSkills: ['Vocabulary', 'Sentence Formation', 'Imagination'],
        expectedImprovement: [
          ProgressMilestone(
            dayNumber: 1,
            expectedOutcome: 'Can name 5 objects in picture',
          ),
          ProgressMilestone(
            dayNumber: 7,
            expectedOutcome: 'Can form simple sentences about picture',
          ),
        ],
        recommendationScore: 0.78,
      ),
      Activity(
        activityId: 'act_003',
        title: {
          'en': 'Shape Memory Game',
          'hi': 'आकार स्मृति खेल',
          'te': 'ఆకారం జ్ఞాపక గేమ్'
        },
        category: ActivityCategory.cognitive,
        minAgeMonths: 24,
        maxAgeMonths: 60,
        difficulty: ActivityDifficulty.medium,
        materials: [
          ActivityMaterial(
            name: 'Colored shapes or paper cutouts',
            isRequired: true,
            localAlternative: 'Draw shapes with chalk',
          ),
        ],
        instructions: {
          'en': '1. Show 3-5 shapes for 20 seconds\n2. Hide them\n3. Ask child to recall',
        },
        targetSkills: ['Memory', 'Attention', 'Pattern Recognition'],
        expectedImprovement: [
          ProgressMilestone(
            dayNumber: 1,
            expectedOutcome: 'Can recall 2 out of 3 shapes',
          ),
          ProgressMilestone(
            dayNumber: 7,
            expectedOutcome: 'Can recall 4 out of 5 shapes',
          ),
        ],
        recommendationScore: 0.72,
      ),
    ];

    // Create mock sessions
    _mockSessions = [
      ActivitySession(
        sessionId: 'sess_001',
        childId: widget.child.id,
        activityId: 'act_001',
        completed: true,
        sessionDate: DateTime.now().subtract(const Duration(days: 3)),
        engagement: 85,
        performance: 78,
        workerNotes: 'Child very enthusiastic, excellent balance',
        followUpNeeded: false,
      ),
      ActivitySession(
        sessionId: 'sess_002',
        childId: widget.child.id,
        activityId: 'act_002',
        completed: true,
        sessionDate: DateTime.now().subtract(const Duration(days: 2)),
        engagement: 72,
        performance: 65,
        workerNotes: 'Shy initially but opened up',
        followUpNeeded: true,
      ),
      ActivitySession(
        sessionId: 'sess_003',
        childId: widget.child.id,
        activityId: 'act_003',
        completed: true,
        sessionDate: DateTime.now().subtract(const Duration(days: 1)),
        engagement: 90,
        performance: 82,
        workerNotes: 'Quick learner, excellent memory',
        followUpNeeded: false,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activities - ${widget.child.name}'),
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: _getTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = [
      ('Recommended', Icons.assignment),
      ('Progress', Icons.trending_up),
      ('Schedule', Icons.calendar_today),
      ('History', Icons.history),
    ];

    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            tabs.length,
            (index) {
              final isSelected = _selectedTab == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedTab = index),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        tabs[index].$2,
                        color: isSelected ? AppColors.primary : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tabs[index].$1,
                        style: TextStyle(
                          color: isSelected ? AppColors.primary : Colors.grey,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _getTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildRecommendedActivities();
      case 1:
        return _buildProgressTab();
      case 2:
        return _buildScheduleTab();
      case 3:
        return _buildHistoryTab();
      default:
        return Container();
    }
  }

  Widget _buildRecommendedActivities() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _mockActivities.length,
      itemBuilder: (context, index) {
        final activity = _mockActivities[index];
        return _buildActivityCard(activity);
      },
    );
  }

  Widget _buildActivityCard(Activity activity) {
    final categoryColor = _getCategoryColor(activity.category);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(activity.category),
                    color: categoryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title['en'] ?? 'Activity',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        _getCategoryName(activity.category),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${(activity.recommendationScore * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (activity.targetSkills.isNotEmpty) ...[
              Wrap(
                spacing: 6,
                children: activity.targetSkills
                    .take(3)
                    .map((skill) => Chip(
                          label: Text(
                            skill,
                            style: const TextStyle(fontSize: 11),
                          ),
                          backgroundColor: categoryColor.withOpacity(0.2),
                          labelStyle: TextStyle(color: categoryColor),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              height: 36,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _viewActivityDetails(activity),
                      icon: const Icon(Icons.info_outline, size: 16),
                      label: const Text('Details'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _recordSession(activity),
                      icon: const Icon(Icons.play_arrow, size: 16),
                      label: const Text('Start'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: categoryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressMetricsCard(),
          const SizedBox(height: 20),
          _buildEngagementChart(),
          const SizedBox(height: 20),
          _buildActivityEffectivenessCard(),
        ],
      ),
    );
  }

  Widget _buildProgressMetricsCard() {
    final avgEngagement =
        (_mockSessions.fold<double>(0, (sum, s) => sum + s.engagement) /
                _mockSessions.length)
            .toStringAsFixed(1);
    final avgPerformance =
        (_mockSessions.fold<double>(0, (sum, s) => sum + s.performance) /
                _mockSessions.length)
            .toStringAsFixed(1);
    final completedSessions = _mockSessions.where((s) => s.completed).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progress Metrics',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricTile(
                  'Sessions\nCompleted',
                  '$completedSessions',
                  Colors.green,
                ),
                _buildMetricTile(
                  'Avg Engagement',
                  '$avgEngagement%',
                  Colors.blue,
                ),
                _buildMetricTile(
                  'Avg Performance',
                  '$avgPerformance%',
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEngagementChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Engagement & Performance Trend',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) {
                    final session = _mockSessions[index];
                    return Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text(
                            'Session ${index + 1}',
                            style:
                                Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                flex: session.engagement.toInt(),
                                child: Container(
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                flex: 100 - session.engagement.toInt(),
                                child: Container(
                                  height: 20,
                                  color: Colors.grey[200],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 40,
                          child: Text(
                            '${session.engagement.toStringAsFixed(0)}%',
                            style: const TextStyle(fontSize: 12),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityEffectivenessCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity Effectiveness',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ..._mockActivities.map((activity) {
              final avgPerformance = _mockSessions
                      .where((s) => s.activityId == activity.activityId)
                      .isEmpty
                  ? 0.0
                  : _mockSessions
                          .where((s) => s.activityId == activity.activityId)
                          .fold<double>(0, (sum, s) => sum + s.performance) /
                      _mockSessions
                          .where((s) => s.activityId == activity.activityId)
                          .length;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        activity.title['en'] ?? 'Activity',
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: avgPerformance / 100,
                          minHeight: 8,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getPerformanceColor(avgPerformance),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 35,
                      child: Text(
                        '${avgPerformance.toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Schedule',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ..._buildWeeklySchedule(),
        ],
      ),
    );
  }

  List<Widget> _buildWeeklySchedule() {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    final schedules = [
      [0, 1],
      [2],
      [1],
      [0, 2],
      [1, 2],
    ];

    return List.generate(
      days.length,
      (dayIndex) {
        final dayActivities = schedules[dayIndex]
            .map((actIndex) => _mockActivities[actIndex])
            .toList();

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  days[dayIndex],
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ...dayActivities.asMap().entries.map((entry) {
                  final time = '${9 + entry.key}:00 AM';
                  final activity = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(activity.category)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 70,
                            child: Text(
                              time,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              activity.title['en'] ?? '',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          Icon(
                            _getCategoryIcon(activity.category),
                            size: 16,
                            color: _getCategoryColor(activity.category),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _mockSessions.length,
      itemBuilder: (context, index) {
        final session = _mockSessions[index];
        final activity = _mockActivities
            .firstWhere((a) => a.activityId == session.activityId);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      activity.title['en'] ?? 'Activity',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: session.completed
                            ? Colors.green[100]
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        session.completed ? 'Completed' : 'Pending',
                        style: TextStyle(
                          fontSize: 11,
                          color: session.completed
                              ? Colors.green[700]
                              : Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Date: ${session.sessionDate.toString().split(' ')[0]}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Engagement',
                            style: TextStyle(fontSize: 11),
                          ),
                          Text(
                            '${session.engagement.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Performance',
                            style: TextStyle(fontSize: 11),
                          ),
                          Text(
                            '${session.performance.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (session.followUpNeeded)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.flag,
                          size: 16,
                          color: Colors.orange,
                        ),
                      ),
                  ],
                ),
                if (session.workerNotes?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Notes:',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          session.workerNotes!,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getCategoryColor(ActivityCategory category) {
    switch (category) {
      case ActivityCategory.motorSkills:
        return Colors.green;
      case ActivityCategory.speechLanguage:
        return Colors.blue;
      case ActivityCategory.cognitive:
        return Colors.purple;
      case ActivityCategory.socialEmotional:
        return Colors.orange;
      case ActivityCategory.creative:
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(ActivityCategory category) {
    switch (category) {
      case ActivityCategory.motorSkills:
        return Icons.directions_run;
      case ActivityCategory.speechLanguage:
        return Icons.mic;
      case ActivityCategory.cognitive:
        return Icons.school;
      case ActivityCategory.socialEmotional:
        return Icons.sentiment_satisfied;
      case ActivityCategory.creative:
        return Icons.palette;
      default:
        return Icons.assignment;
    }
  }

  String _getCategoryName(ActivityCategory category) {
    switch (category) {
      case ActivityCategory.motorSkills:
        return 'Motor Skills';
      case ActivityCategory.speechLanguage:
        return 'Speech & Language';
      case ActivityCategory.cognitive:
        return 'Cognitive';
      case ActivityCategory.socialEmotional:
        return 'Social-Emotional';
      case ActivityCategory.creative:
        return 'Creative';
      default:
        return 'Activity';
    }
  }

  Color _getPerformanceColor(double performance) {
    if (performance >= 80) return Colors.green;
    if (performance >= 60) return Colors.orange;
    return Colors.red;
  }

  void _viewActivityDetails(Activity activity) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              activity.title['en'] ?? 'Activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Target Skills',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: activity.targetSkills
                  .map((skill) => Chip(label: Text(skill)))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Text(
              'Duration',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              '${activity.durationMinutes ?? 15} minutes',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _recordSession(activity);
                },
                child: const Text('Start Activity'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _recordSession(Activity activity) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting ${activity.title['en']}...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
