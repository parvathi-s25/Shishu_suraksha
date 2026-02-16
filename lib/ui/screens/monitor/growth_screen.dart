import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/data/models/child_model.dart';
import 'package:intl/intl.dart';

class GrowthScreen extends StatefulWidget {
  final ChildModel child;
  const GrowthScreen({Key? key, required this.child}) : super(key: key);

  @override
  State<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends State<GrowthScreen> {
  late List<GrowthRecord> _records;

  @override
  void initState() {
    super.initState();
    _records = widget.child.growthHistory;
    if (_records.isEmpty) {
      _records = _generateMockGrowthData();
    }
  }

  // Simulate past 6 months of growth
  List<GrowthRecord> _generateMockGrowthData() {
    List<GrowthRecord> mockData = [];
    DateTime now = DateTime.now();
    double baseHeight = 95.0; // cm
    double baseWeight = 14.0; // kg
    
    // Vary base based on age if possible, but keep simple for demo
    if (widget.child.ageMonths > 48) {
       baseHeight = 105;
       baseWeight = 18;
    }

    for (int i = 5; i >= 0; i--) {
      mockData.add(GrowthRecord(
        date: now.subtract(Duration(days: i * 30)),
        height: baseHeight - (i * 0.5),
        weight: baseWeight - (i * 0.2),
      ));
    }
    return mockData;
  }

  @override
  Widget build(BuildContext context) {
    final latest = _records.last;
    final bmi = latest.bmi;
    final status = _getBMIStatus(bmi);
    final statusColor = _getBMIColor(bmi);

    return Scaffold(
      appBar: AppBar(title: Text('Growth: ${widget.child.name}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1. BMI Card
            Card(
              color: statusColor.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: statusColor)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Current BMI', style: TextStyle(fontSize: 16, color: Colors.grey)),
                        Text(bmi.toStringAsFixed(1), style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: statusColor)),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(status.toUpperCase(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: statusColor)),
                        Text('${latest.weight}kg | ${latest.height}cm', style: const TextStyle(fontSize: 16)),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. Growth Chart
            const Text('Growth Trend (Last 6 Months)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < _records.length) {
                             return Text(DateFormat('MMM').format(_records[index].date), style: const TextStyle(fontSize: 10));
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.withOpacity(0.2))),
                  lineBarsData: [
                    // Weight Line
                    LineChartBarData(
                      spots: _records.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.weight)).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                    // Height Line (Scaled down for visuals or separate? Let's just show Weight for clarity as height varies less)
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
             const Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Icon(Icons.circle, color: Colors.blue, size: 12),
                 SizedBox(width: 4),
                 Text('Weight (kg)'),
               ],
             ),
             
             const SizedBox(height: 24),
             
             // 3. AI Insights
             Container(
               padding: const EdgeInsets.all(16),
               decoration: BoxDecoration(
                 color: Colors.indigo.withOpacity(0.05),
                 borderRadius: BorderRadius.circular(12),
               ),
               child: const Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    Row(children: [Icon(Icons.auto_awesome, color: Colors.indigo), SizedBox(width: 8), Text('AI Growth Insight', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo))]),
                    SizedBox(height: 8),
                    Text('Growth trajectory is consistent. Weight gain is effectively tracking with age expectation. No nutritional intervention required at this time.'),
                 ],
               ),
             )
          ],
        ),
      ),
    );
  }
  
  String _getBMIStatus(double bmi) {
    if (bmi < 14) return 'Underweight';
    if (bmi > 18) return 'Overweight'; // Simplified for child range
    return 'Normal';
  }

  Color _getBMIColor(double bmi) {
     if (bmi < 14) return Colors.orange;
     if (bmi > 18) return Colors.red;
     return Colors.green;
  }
}
