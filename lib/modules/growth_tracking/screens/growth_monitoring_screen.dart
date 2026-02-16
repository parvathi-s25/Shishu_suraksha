
import 'package:flutter/material.dart';
import '../models/growth_record.dart';
import '../services/growth_service.dart';

class GrowthMonitoringScreen extends StatefulWidget {
  final String childId;
  final String childName;

  const GrowthMonitoringScreen({
    Key? key,
    required this.childId,
    required this.childName,
  }) : super(key: key);

  @override
  _GrowthMonitoringScreenState createState() => _GrowthMonitoringScreenState();
}

class _GrowthMonitoringScreenState extends State<GrowthMonitoringScreen> {
  final GrowthService _growthService = GrowthService();
  final String _schoolId = "DEMO_SCHOOL_01"; 

  // Form Controllers
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  
  void _addRecord() async {
    if (_heightController.text.isEmpty || _weightController.text.isEmpty) return;

    final double h = double.tryParse(_heightController.text) ?? 0;
    final double w = double.tryParse(_weightController.text) ?? 0;

    if (h > 0 && w > 0) {
      final newRecord = GrowthRecord(
        height: h,
        weight: w,
        notes: "Manual Entry",
        date: DateTime.now(),
      );

      await _growthService.addGrowthRecord(_schoolId, widget.childId, newRecord);
      
      Navigator.pop(context); // Close dialog
      _heightController.clear();
      _weightController.clear();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Growth Record Added Successfully")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Growth: ${widget.childName}"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<GrowthRecord>>(
        stream: _growthService.getGrowthHistory(_schoolId, widget.childId),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final history = snapshot.data!;
          final GrowthRecord? latest = history.isNotEmpty ? history.first : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGoalHeader(),
                const SizedBox(height: 16),
                if (latest != null) ...[
                   _buildMalnutritionCard(latest),
                   const SizedBox(height: 24),
                   _buildNutritionAdvice(latest),
                   const SizedBox(height: 24),
                ],

                Text(
                  "Recent Records",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple.shade900),
                ),
                const SizedBox(height: 12),
                _buildHistoryList(history),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEntryDialog,
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildGoalHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Growth Monitoring Goal",
            style: TextStyle(color: Colors.purple.shade800, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            "Track monthly weight and height to detect early signs of malnutrition and ensure healthy development.",
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildMalnutritionCard(GrowthRecord record) {
    // Child age logic
    // For demo using 36 months if not available
    const int ageMonths = 36;
    final risk = record.getMalnutritionRisk(ageMonths);
    final status = record.getMalnutritionStatus(ageMonths);
    
    Color color;
    if (risk >= 60) color = Colors.red;
    else if (risk >= 30) color = Colors.orange;
    else if (risk >= 15) color = Colors.yellow.shade800;
    else color = Colors.green;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: risk / 100,
                  backgroundColor: color.withOpacity(0.1),
                  color: color,
                  strokeWidth: 8,
                ),
              ),
              Text(
                "$risk%",
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "AI Malnutrition Risk",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  risk > 30 ? "Immediate attention required" : "Healthy development tracked",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNutritionAdvice(GrowthRecord record) {
    const int ageMonths = 36;
    final advice = record.getNutritionAdvice(ageMonths);
    final isAlert = record.getMalnutritionRisk(ageMonths) >= 30;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isAlert ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isAlert ? Colors.red.shade100 : Colors.green.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Icon(isAlert ? Icons.warning_amber_rounded : Icons.restaurant, 
                color: isAlert ? Colors.red : Colors.green),
           const SizedBox(width: 12),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(
                   "AI Nutrition Suggestion", 
                   style: TextStyle(
                     fontWeight: FontWeight.bold, 
                     color: isAlert ? Colors.red : Colors.green
                   )
                 ),
                 const SizedBox(height: 4),
                 Text(advice, style: const TextStyle(fontSize: 13, height: 1.4)),
               ],
             ),
           )
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      children: [
        Text(
          "$label: ",
          style: TextStyle(color: Colors.grey[600]),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildHistoryList(List<GrowthRecord> history) {
    if (history.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: Text("No growth records found. Add one!")),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple.shade50,
              child: const Icon(Icons.calendar_today, color: Colors.purple, size: 18),
            ),
            title: Text("${item.date.day}/${item.date.month}/${item.date.year}"),
            subtitle: Text("Height: ${item.height} cm • Weight: ${item.weight} kg"),
            trailing: Text(
              item.bmi.toStringAsFixed(1),
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple.shade700),
            ),
          ),
        );
      },
    );
  }

  void _showAddEntryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Measurement"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _heightController,
              decoration: const InputDecoration(labelText: "Height (cm)", hintText: "e.g. 110"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _weightController,
              decoration: const InputDecoration(labelText: "Weight (kg)", hintText: "e.g. 18.5"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(onPressed: _addRecord, child: const Text("Save")),
        ],
      ),
    );
  }
}
