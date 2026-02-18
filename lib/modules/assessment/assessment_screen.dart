import 'package:flutter/material.dart';
import '../../services/module_status_service.dart';
import 'assessment_state.dart';
import '../vision/vision_home.dart';
import '../pose/pose_screen.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  final _modules = [
    'Pose',
    'Vision',
    'Hearing',
    'Speech',
    'Injury',
    'Signs',
    'Thermal'
  ];

  @override
  Widget build(BuildContext context) {
    final status = ModuleStatusService.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Assessment')),
      body: Column(
        children: [
          SizedBox(
            height: 72,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemBuilder: (ctx, i) {
                final name = _modules[i];
                final key = name.toLowerCase();
                final done = status.isCompleted(key);
                return GestureDetector(
                  onTap: () => _openModule(context, key),
                  child: Chip(
                    avatar: done ? const Icon(Icons.check_circle, color: Colors.green) : null,
                    label: Text(name),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: _modules.length,
            ),
          ),
          const Divider(),
          Expanded(
            child: Center(
              child: Text('Select a module to begin', style: Theme.of(context).textTheme.titleMedium),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ValueListenableBuilder<Map<String, bool>>(
          valueListenable: status.snapshotListenable,
          builder: (context, snapshot, _) {
            final allDone = snapshot.values.every((v) => v == true);
            return ElevatedButton(
              onPressed: allDone ? () {} : null,
              child: const Text('Next'),
            );
          },
        ),
      ),
    );
  }

  void _openModule(BuildContext context, String key) {
    switch (key) {
      case 'vision':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const VisionHome()));
        break;
      case 'pose':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PoseScreen()));
        break;
      default:
        // For modules not implemented yet, open a placeholder
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => Scaffold(appBar: AppBar(title: Text(key)), body: const Center(child: Text('Module placeholder')))));
    }
  }
}
