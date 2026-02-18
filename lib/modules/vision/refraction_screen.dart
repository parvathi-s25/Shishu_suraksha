import 'package:flutter/material.dart';
import '../../services/module_status_service.dart';

class RefractionScreen extends StatefulWidget {
  const RefractionScreen({super.key});

  @override
  State<RefractionScreen> createState() => _RefractionScreenState();
}

class _RefractionScreenState extends State<RefractionScreen> {
  double _blurLevel = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Refraction Risk Estimation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          const Text('Increase blur until child can read; record smallest readable blur.'),
          const SizedBox(height: 20),
          Slider(value: _blurLevel, onChanged: (v) => setState(() => _blurLevel = v), min: 0, max: 10),
          Text('Blur level: ${_blurLevel.toStringAsFixed(1)}'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // basic rule: high blur -> risk
              final risk = _blurLevel > 6.0;
              DBService.instance.insert('vision_refraction', {
                'assessment_id': 'local',
                'blur_level': _blurLevel,
                'risk_flag': risk ? 1 : 0,
                'details': '{}',
                'created_at': DateTime.now().millisecondsSinceEpoch,
              });
              ModuleStatusService.instance.markCompleted('vision_refraction', true);
              ModuleStatusService.instance.markCompleted('vision', true);
              showDialog(
                context: context,
                builder: (_) => AlertDialog(title: const Text('Result'), content: Text(risk ? 'Refraction risk detected' : 'Low risk')),
              ).then((_) => Navigator.of(context).pop());
            },
            child: const Text('Save Refraction Result'),
          )
        ]),
      ),
    );
  }
}
