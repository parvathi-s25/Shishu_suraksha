import 'package:flutter/material.dart';
import '../../services/module_status_service.dart';

class PoseScreen extends StatelessWidget {
  const PoseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pose Module')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          const Text('BlazePose detection will run here (not implemented).'),
          const SizedBox(height: 20),
          const Expanded(child: Center(child: Icon(Icons.self_improvement, size: 72))),
          ElevatedButton(
            onPressed: () {
              ModuleStatusService.instance.markCompleted('pose', true);
              Navigator.of(context).pop();
            },
            child: const Text('Complete Pose Test'),
          )
        ]),
      ),
    );
  }
}
