import 'package:flutter/material.dart';
import '../../services/module_status_service.dart';
import 'screens/color_vision_test_screen.dart';
import 'models/vision_result_model.dart';
import '../../services/db_service.dart';

class ColorScreen extends StatefulWidget {
  const ColorScreen({super.key});

  @override
  State<ColorScreen> createState() => _ColorScreenState();
}

class _ColorScreenState extends State<ColorScreen> {
  int _index = 0;
  int _incorrect = 0;

  final int _totalPlates = 10;

  void _answer(bool correct) {
    if (!correct) _incorrect++;
    setState(() => _index++);
    if (_index >= _totalPlates) _finish();
  }

  void _finish() {
    final risk = _incorrect >= 3;
    // store result (legacy quick flow)
    DBService.instance.insert('vision_color', {
      'assessment_id': 'local',
      'correct_count': _totalPlates - _incorrect,
      'incorrect_count': _incorrect,
      'details': '{"incorrect_indices":[]}',
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
    ModuleStatusService.instance.markCompleted('vision_color', true);
    ModuleStatusService.instance.markCompleted('vision', true);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(title: const Text('Result'), content: Text(risk ? 'Color vision risk' : 'Normal')),
    ).then((_) => Navigator.of(context).pop());
  }

  Future<void> _startFullTest() async {
    final res = await Navigator.of(context).push<ColorVisionResult?>(MaterialPageRoute(
      builder: (_) => const ColorVisionTestScreen(),
    ));

    if (res != null) {
      // Save structured result
      DBService.instance.insert('vision_color', {
        'assessment_id': 'local',
        'correct_count': res.score,
        'incorrect_count': (res.totalPlates - res.score),
        'details': res.toJson().toString(),
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
      ModuleStatusService.instance.markCompleted('vision_color', true);
      ModuleStatusService.instance.markCompleted('vision', true);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(title: const Text('Result'), content: Text('Score: ${res.score}/${res.totalPlates}\nType: ${res.type}')),
      ).then((_) => Navigator.of(context).pop());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Color Vision (Ishihara)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Expanded(child: Center(child: Text('Plate ${_index + 1}', style: const TextStyle(fontSize: 40)))),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _startFullTest,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Full Ishihara Test'),
          ),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            ElevatedButton(onPressed: () => _answer(true), child: const Text('Correct')),
            ElevatedButton(onPressed: () => _answer(false), child: const Text('Incorrect')),
          ])
        ]),
      ),
    );
  }
}

