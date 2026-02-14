import 'package:flutter/material.dart';
import '../../../core/services/data_service.dart';
import '../../../app/theme/colors.dart';

class QuickAddScreen extends StatefulWidget {
  const QuickAddScreen({Key? key}) : super(key: key);

  @override
  _QuickAddScreenState createState() => _QuickAddScreenState();
}

class _QuickAddScreenState extends State<QuickAddScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  bool _isLoading = false;

  void _saveChild() async {
    if (_nameController.text.isEmpty || _ageController.text.isEmpty || _weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Please fill all 3 fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Update DataService
    DataService().addChild();
    if (double.tryParse(_weightController.text)! < 10) { 
       // Example logic: Low weight = High Risk
       DataService().addHighRiskChild();
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Child Added Quickly!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Quick Add (Ultra Fast)", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Minimal Entry Mode",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              
              _buildTextField("Child Name", _nameController, Icons.person),
              const SizedBox(height: 16),
              _buildTextField("Age (Months/Years)", _ageController, Icons.cake, isNumber: true),
              const SizedBox(height: 16),
              _buildTextField("Weight (kg)", _weightController, Icons.monitor_weight, isNumber: true),
              
              const SizedBox(height: 40), // Replaced Spacer with fixed spacing
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveChild,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A981), // Teal brand color
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("SAVE & CONTINUE LATER", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF00A981)), // Teal brand color
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}
