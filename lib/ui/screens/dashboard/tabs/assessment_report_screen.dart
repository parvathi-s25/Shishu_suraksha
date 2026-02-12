import 'package:flutter/material.dart';

class AssessmentReportScreen extends StatelessWidget {
  final Map<String, dynamic> child;

  const AssessmentReportScreen({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                Navigator.popUntil(context, (route) => route.isFirst);
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
