import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ChildReportScreen extends StatelessWidget {
  final Map<String, dynamic> child;

  const ChildReportScreen({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine colors based on status (Mock logic)
    // Development: Green (Normal), Red (Delayed)
    // Nutrition: Green (Normal), Orange (Stunted), Red (Wasted)
    // Immunization: Green (Complete), Yellow (Pending)

    return Scaffold(
      appBar: AppBar(
        title: Text("${child['name']}'s Report"),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Center alignment
          children: [
            // 1. Profile Card
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
                        child['name'][0],
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(child['name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text("Age: ${child['age']}", style: const TextStyle(fontSize: 14, color: Colors.grey)),
                        Text("ID: ${child['id']}", style: const TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. Descriptive Analysis
            const Text(
              "Comprehensive Analysis",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const SizedBox(height: 8),
             Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: const Text(
                "Child is showing consistent growth. Immunization is up to date. "
                "Nutrition levels are normal, but slight stunting observed in previous month. "
                "Development milestones are being met on time.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
            ),
            const SizedBox(height: 24),

            // 3. Pie Charts
            _buildChartSection(
              title: "Development Status",
              sections: [
                PieChartSectionData(color: Colors.green, value: 80, title: '80%', radius: 50),
                PieChartSectionData(color: Colors.redAccent, value: 20, title: '20%', radius: 40),
              ],
              labels: ["Normal (80%)", "Delayed (20%)"],
            ),
            const Divider(height: 40),

            _buildChartSection(
              title: "Nutrition Status",
              sections: [
                PieChartSectionData(color: Colors.green, value: 60, title: '60%', radius: 50),
                PieChartSectionData(color: Colors.orange, value: 30, title: '30%', radius: 40),
                PieChartSectionData(color: Colors.red, value: 10, title: '10%', radius: 30),
              ],
              labels: ["Normal", "Stunted", "Wasted"],
            ),
            const Divider(height: 40),

            _buildChartSection(
              title: "Immunization Status",
              sections: [
                PieChartSectionData(color: Colors.teal, value: 90, title: '90%', radius: 50),
                PieChartSectionData(color: Colors.amber, value: 10, title: '10%', radius: 40),
              ],
              labels: ["Complete", "Pending"],
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection({required String title, required List<PieChartSectionData> sections, required List<String> labels}) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          alignment: WrapAlignment.center,
          children: labels.asMap().entries.map((e) {
             final index = e.key;
             final label = e.value;
             // Hacky color matching to the sections
             final color = sections[index % sections.length].color;
             return Row(
               mainAxisSize: MainAxisSize.min,
               children: [
                 Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                 const SizedBox(width: 4),
                 Text(label, style: const TextStyle(fontSize: 12)),
               ],
             );
          }).toList(),
        ),
      ],
    );
  }
}
