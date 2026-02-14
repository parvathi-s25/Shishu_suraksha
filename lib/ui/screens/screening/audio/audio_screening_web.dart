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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning, size: 80, color: Colors.orange),
            const SizedBox(height: 20),
            const Text(
              "Audio Screening Not Supported on Web",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "The audio screening feature uses native libraries (TFLite) that are not available in the browser. Please use the mobile app for this feature.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Go Back"),
            ),
          ],
        ),
      ),
    );
  }
}
