import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/data/models/child_model.dart';
import '../../../../app/theme/colors.dart';

class AssessmentReportScreen extends StatefulWidget {
  final ChildModel child;

  const AssessmentReportScreen({Key? key, required this.child}) : super(key: key);

  @override
  State<AssessmentReportScreen> createState() => _AssessmentReportScreenState();
}

class _AssessmentReportScreenState extends State<AssessmentReportScreen> {
  late List<GrowthRecord> _records;

  @override
  void initState() {
    super.initState();
    _records = widget.child.growthHistory;
    if (_records.isEmpty) {
      _records = _generateMockGrowthData();
    }
  }

  List<FlSpot> _getWHOSpots(int percentile, int count) {
    List<FlSpot> spots = [];
    int currentAgeMonths = widget.child.ageMonths; 
    
    for (int i = 0; i < count; i++) {
       int monthOffset = (count - 1) - i;
       int spotAge = currentAgeMonths - monthOffset;
       if (spotAge < 0) spotAge = 0;
       
       double weight = 0;
       // Approximate WHO Boys Weight-for-Age
       if (percentile == 50) weight = 3.3 + (0.5 * spotAge); // Median
       if (percentile == 3) weight = 2.4 + (0.4 * spotAge);  // 3rd
       if (percentile == 97) weight = 4.4 + (0.6 * spotAge); // 97th
       
       spots.add(FlSpot(i.toDouble(), weight));
    }
    return spots;
  }

  // Simulate past 6 months of growth
  List<GrowthRecord> _generateMockGrowthData() {
    List<GrowthRecord> mockData = [];
    DateTime now = DateTime.now();
    double baseHeight = 95.0; // cm
    double baseWeight = 14.0; // kg
    
    // Vary base based on age
    if (widget.child.ageMonths > 48) {
       baseHeight = 105;
       baseWeight = 18;
    } else if (widget.child.ageMonths < 12) {
       baseHeight = 70;
       baseWeight = 8;
    }

    for (int i = 5; i >= 0; i--) {
      mockData.add(GrowthRecord(
        date: now.subtract(Duration(days: i * 30)),
        height: baseHeight - (i * 0.5),
        weight: baseWeight - (i * 0.2), // Growing .2kg per month
      ));
    }
    return mockData;
  }

  Color _getBMIColor(double bmi) {
     if (bmi < 14) return Colors.orange;
     if (bmi > 18) return Colors.red;
     return Colors.green;
  }

  String _getBMIStatus(double bmi) {
    if (bmi < 14) return 'Underweight';
    if (bmi > 18) return 'Overweight'; 
    return 'Normal';
  }

  @override
  Widget build(BuildContext context) {
    final latest = _records.isNotEmpty 
        ? _records.last 
        : GrowthRecord(date: DateTime.now(), height: 0, weight: 0);
    final bmi = latest.bmi;
    final status = _getBMIStatus(bmi);
    final statusColor = _getBMIColor(bmi);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Assessment Report"),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header: Child Info
             Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.teal.shade100,
                      child: Text(
                        widget.child.name.isNotEmpty ? widget.child.name[0] : '?',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.child.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text("Age: ${widget.child.age} years", style: const TextStyle(fontSize: 14, color: Colors.grey)),
                        Text("ID: ${widget.child.id}", style: const TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Growth Section (Migrated)
            _buildGrowthSection(latest, bmi, status, statusColor),
            const SizedBox(height: 24),

            // Report Sections
            _buildSection("Development Progress", "Normal", "Child shows steady improvement in motor skills.", Colors.green),
            _buildSection("Mobility", "Active", "Crawling and attempting to stand with support.", Colors.blue),
            _buildSection("Cognitive Condition", "Age Appropriate", "Responds to name and tracks moving objects.", Colors.green),
            _buildSection("Speech & Hearing", "Monitoring Required", "Response to low frequency sounds is slightly delayed.", Colors.orange),
            
            const SizedBox(height: 16),
            
            // Alerts
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warning, color: Colors.red),
                      const SizedBox(width: 8),
                      const Text("Alerts", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Speech milestones are slightly behind schedule. Recommended follow-up in 2 weeks.",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),

             // Recommendations
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lightbulb, color: Colors.teal),
                      const SizedBox(width: 8),
                      const Text("Recommendations", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Encourage speaking by reading stories. Conduct daily interactive play. Schedule hearing test if no improvement.",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/dashboard',
                  (Route<dynamic> route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("Back to Dashboard", style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthSection(GrowthRecord latest, double bmi, String status, Color statusColor) {
    return Column(
      children: [
        // BMI Card
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
        const SizedBox(height: 16),
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
                // WHO 97th Percentile
                LineChartBarData(
                  spots: _getWHOSpots(97, _records.length),
                  isCurved: true,
                  color: Colors.red.withOpacity(0.3),
                  barWidth: 2,
                  dashArray: [5, 5],
                  dotData: FlDotData(show: false),
                ),
                // WHO 50th Percentile
                LineChartBarData(
                  spots: _getWHOSpots(50, _records.length),
                  isCurved: true,
                  color: Colors.green.withOpacity(0.5),
                  barWidth: 2,
                  dashArray: [5, 5],
                  dotData: FlDotData(show: false),
                ),
                // WHO 3rd Percentile
                LineChartBarData(
                  spots: _getWHOSpots(3, _records.length),
                  isCurved: true,
                  color: Colors.orange.withOpacity(0.3),
                  barWidth: 2,
                  dashArray: [5, 5],
                  dotData: FlDotData(show: false),
                ),
                // Child's Weight
                LineChartBarData(
                  spots: _records.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.weight)).toList(),
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.1)),
                ),
              ],
            ),
          ),
        ),
         const SizedBox(height: 8),
         const Row(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Icon(Icons.circle, color: Colors.blue, size: 12), SizedBox(width: 4), Text('Child'),
             SizedBox(width: 16),
             Icon(Icons.remove, color: Colors.green, size: 12), SizedBox(width: 4), Text('Median (WHO)'),
           ],
         ),
      ],
    );
  }

  Widget _buildSection(String title, String status, String description, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                   decoration: BoxDecoration(
                     color: color.withOpacity(0.1),
                     borderRadius: BorderRadius.circular(8),
                   ),
                   child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                 ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }
}
