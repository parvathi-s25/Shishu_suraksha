import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/screens/opening/opening_animation_screen.dart';
import 'data/models/growth_data.dart';
import 'data/models/child_model.dart';
import 'data/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Adapters
  Hive.registerAdapter(GrowthDataAdapter());
  Hive.registerAdapter(ChildModelAdapter());
  
  // Open Boxes
  await Hive.openBox<ChildModel>(StorageService.childBoxName);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shishu Suraksha AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const OpeningAnimationScreen(),
    );
  }
}
