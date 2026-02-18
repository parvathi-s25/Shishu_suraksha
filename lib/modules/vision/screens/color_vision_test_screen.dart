import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/vision_result_model.dart';

class ColorVisionTestScreen extends StatefulWidget {
  const ColorVisionTestScreen({super.key});

  @override
  State<ColorVisionTestScreen> createState() => _ColorVisionTestScreenState();
}

class _ColorVisionTestScreenState extends State<ColorVisionTestScreen> {
  int _currentIndex = 0;
  int _score = 0;
  
  // Mock Ishihara Data
  // In a real app, these would be asset paths.
  // For MVP, we'll use colored containers with text overlay as placeholders if assets missing, 
  // or just describe them.
  // Ideally, I should generate assets. But for code-only, I'll simulate.
  
  final List<Map<String, dynamic>> _plates = [
    {'id': 1, 'answer': '12', 'type': 'demo', 'color': Colors.orange}, 
    {'id': 2, 'answer': '8', 'type': 'rg', 'color': Colors.green},
    {'id': 3, 'answer': '29', 'type': 'rg', 'color': Colors.red},
    {'id': 4, 'answer': '5', 'type': 'rg', 'color': Colors.teal},
    {'id': 5, 'answer': '3', 'type': 'rg', 'color': Colors.amber},
  ];

  final TextEditingController _controller = TextEditingController();

  void _nextPlate() {
     // Check answer
     if (_controller.text.trim() == _plates[_currentIndex]['answer']) {
        _score++;
     }
     _controller.clear();
     
     if (_currentIndex < _plates.length - 1) {
        setState(() {
           _currentIndex++;
        });
     } else {
        _showResults();
     }
  }

  void _showResults() {
     showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
           title: const Text('Color Vision Test Result'),
           content: Text('Score: $_score / ${_plates.length}'),
           actions: [
              TextButton(
                  onPressed: () {
                     final result = ColorVisionResult(
                        score: _score,
                        totalPlates: _plates.length,
                        type: _score < 3 ? 'Red-Green Deficiency' : 'Normal', // Simple logic
                     );
                     Navigator.pop(context); // Close dialog
                     Navigator.pop(context, result); // Return result
                  },
                  child: const Text('Finish'),
               )
           ],
        ),
     );
  }

  @override
  Widget build(BuildContext context) {
    final plate = _plates[_currentIndex];
    
    return Scaffold(
      appBar: AppBar(title: const Text('Color Vision Test')),
      body: SingleChildScrollView(
         padding: const EdgeInsets.all(24),
         child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
               Text(
                  'Plate ${_currentIndex + 1} of ${_plates.length}',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
               ),
               const SizedBox(height: 32),
               
               // Placeholder for Ishihara Plate Image
               Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                     color: plate['color'] as Color, // Mock background
                     shape: BoxShape.circle,
                     // Real implementation would use Image.asset('assets/ishihara_${plate['id']}.png')
                  ),
                  alignment: Alignment.center,
                  child: Stack(
                     children: [
                        // Noise simulation
                       ...List.generate(20, (index) => Positioned(
                          left: (index * 15).toDouble(),
                          top: (index * 15).toDouble(),
                          child: Container(width: 10, height: 10, color: Colors.white.withOpacity(0.2)),
                       )), 
                       Center(
                          child: Text(
                             "Plate #${plate['id']}", 
                             style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                          ),
                       ),
                     ],
                  ),
               ),
               const SizedBox(height: 16),
               const Text(
                  "What number do you see?", 
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
               ),
               
               const SizedBox(height: 24),
               TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 2),
                  decoration: const InputDecoration(
                     hintText: 'Enter Number',
                     border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _nextPlate(),
               ),
               
               const SizedBox(height: 32),
               SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                     onPressed: _nextPlate,
                     style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18),
                     ),
                     child: Text(_currentIndex == _plates.length -1 ? 'Finish' : 'Next'),
                  ),
               ),
            ],
         ),
      ),
    );
  }
}
