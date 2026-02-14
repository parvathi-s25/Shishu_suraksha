import 'package:flutter/material.dart';

class AudioScreeningScreen extends StatefulWidget {
  const AudioScreeningScreen({super.key});

  @override
  State<AudioScreeningScreen> createState() => _AudioScreeningScreenState();
}

class _AudioScreeningScreenState extends State<AudioScreeningScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hearing Test"),
        backgroundColor: Colors.teal,
      ),
      body: const Center(
        child: Text("Platform not supported"),
      ),
    );
  }
}
