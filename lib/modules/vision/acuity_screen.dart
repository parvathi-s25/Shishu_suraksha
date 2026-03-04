import 'package:flutter/material.dart';
import '../../services/module_status_service.dart';
import '../../services/camera_service.dart';
import '../../services/vision_processor.dart';
import '../../services/db_service.dart';

class AcuityScreen extends StatefulWidget {
  const AcuityScreen({super.key});

  @override
  State<AcuityScreen> createState() => _AcuityScreenState();
}

class _AcuityScreenState extends State<AcuityScreen> {
  int _level = 1;
  bool _distanceOk = false;
  bool _attentionOk = false;

  @override
  void initState() {
    super.initState();
    VisionProcessor.instance.onDistance = (ok) => setState(() => _distanceOk = ok);
    VisionProcessor.instance.onAttention = (ok) => setState(() => _attentionOk = ok);
    VisionProcessor.instance.start();
  }

  void _nextLevel() => setState(() => _level = (_level < 5) ? _level + 1 : 5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visual Acuity')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(children: [
              Chip(label: Text(_distanceOk ? 'Distance: OK' : 'Distance: Adjust')),
              const SizedBox(width: 12),
              Chip(label: Text(_attentionOk ? 'Facing: OK' : 'Facing: Adjust')),
            ]),
            const SizedBox(height: 12),
            Expanded(child: Center(child: Text('Level $_level', style: const TextStyle(fontSize: 48)))),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: () => _record(false), child: const Text('Wrong')),
                ElevatedButton(onPressed: () => _record(true), child: const Text('Correct')),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _nextLevel, child: const Text('Next Letter'))
          ],
        ),
      ),
    );
  }

  void _record(bool correct) {
    // store result locally or send to DB; simplified for scaffold
    if (correct) {
      // advance
      _nextLevel();
    }
    // Save a simple row for now
    DBService.instance.insert('vision_acuity', {
      'assessment_id': 'local',
      'eye': 'both',
      'level_passed': _level,
      'details': '{"correct":$correct}',
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  void dispose() {
    VisionProcessor.instance.stop();
    VisionProcessor.instance.dispose();
    CameraService.instance.dispose();
    super.dispose();
  }
}
