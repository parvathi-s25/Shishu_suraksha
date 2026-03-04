import 'package:flutter/material.dart';
import '../../services/module_status_service.dart';
import 'acuity_screen.dart';
import 'alignment_screen.dart';
import 'color_screen.dart';
import 'reflex_screen.dart';
import 'refraction_screen.dart';

class VisionHome extends StatelessWidget {
  const VisionHome({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'title': 'Visual Acuity', 'page': const AcuityScreen()},
      {'title': 'Eye Alignment', 'page': const AlignmentScreen()},
      {'title': 'Pupil Reflex', 'page': const ReflexScreen()},
      {'title': 'Color Vision', 'page': const ColorScreen()},
      {'title': 'Field of Vision', 'page': const Placeholder()},
      {'title': 'Refraction Risk', 'page': const RefractionScreen()},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Vision Screening')),
      body: ListView.separated(
        itemBuilder: (ctx, i) {
          final it = items[i];
          return ListTile(
            title: Text(it['title'] as String),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              final p = it['page'] as Widget;
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => p));
            },
          );
        },
        separatorBuilder: (_, __) => const Divider(),
        itemCount: items.length,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ModuleStatusService.instance.markCompleted('vision', true);
          Navigator.of(context).pop();
        },
        label: const Text('Mark Vision Done'),
        icon: const Icon(Icons.check),
      ),
    );
  }
}
