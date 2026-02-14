import 'package:flutter/material.dart';
import '../../../core/data/models/intervention_models.dart';
import '../../../core/data/models/child_model.dart';
import '../../../core/data/services/teacher_activity_dashboard_service.dart';
import '../../../app/theme/colors.dart';

/// Session Recording Screen
/// Allows teachers to record an activity session with engagement, performance and notes.
class SessionRecordingScreen extends StatefulWidget {
  final ChildModel child;
  final Activity activity;

  const SessionRecordingScreen({
    Key? key,
    required this.child,
    required this.activity,
  }) : super(key: key);

  @override
  State<SessionRecordingScreen> createState() => _SessionRecordingScreenState();
}

class _SessionRecordingScreenState extends State<SessionRecordingScreen> {
  double _engagement = 75;
  double _performance = 70;
  final TextEditingController _notesController = TextEditingController();
  bool _completed = true;

  final TeacherActivityDashboardService _service = TeacherActivityDashboardService();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _saveSession() {
    // Build ActivitySession model (simple, without Hive persistence here)
    final session = ActivitySession(
      sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
      childId: widget.child.id,
      activityId: widget.activity.activityId,
      completed: _completed,
      sessionDate: DateTime.now(),
      engagement: _engagement,
      performance: _performance,
      workerNotes: _notesController.text,
      followUpNeeded: _performance < 50 || _engagement < 50,
    );

    // Record via service (service may persist to Hive)
    try {
      _service.recordActivitySession(session);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session recorded')),
      );
      Navigator.pop(context, session);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save session: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Record Session - ${widget.activity.title['en'] ?? 'Activity'}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Child: ${widget.child.name}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Engagement (0-100)', style: TextStyle(fontWeight: FontWeight.bold)),
                    Slider(
                      value: _engagement,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      label: '${_engagement.toStringAsFixed(0)}%',
                      onChanged: (v) => setState(() => _engagement = v),
                    ),
                    const SizedBox(height: 8),
                    const Text('Performance (0-100)', style: TextStyle(fontWeight: FontWeight.bold)),
                    Slider(
                      value: _performance,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      label: '${_performance.toStringAsFixed(0)}%',
                      onChanged: (v) => setState(() => _performance = v),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Worker notes',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Checkbox(
                          value: _completed,
                          onChanged: (v) => setState(() => _completed = v ?? true),
                        ),
                        const SizedBox(width: 8),
                        const Text('Session completed'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveSession,
                        icon: const Icon(Icons.save),
                        label: const Text('Save Session'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
