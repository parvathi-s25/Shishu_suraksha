
import 'package:flutter/material.dart';
import '../../../../services/responsive_dashboard.dart'; // Import responsive utilities
import '../services/admin_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService _adminService = AdminService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin & Government Dashboard"),
        backgroundColor: Colors.indigo.shade900,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildStatsGrid(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text(
                  "High Risk Children (Action Required)",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo.shade900),
                ),
                ElevatedButton.icon(
                  onPressed: () => _exportReport("HighRisk"),
                  icon: const Icon(Icons.file_download),
                  label: const Text("Export Excel"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700, 
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildHighRiskList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.indigo.shade100,
          radius: 24,
          child: Icon(Icons.admin_panel_settings, size: 30, color: Colors.indigo.shade900),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Central Monitoring Console",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo.shade900),
            ),
            const Text(
              "Real-time overview of all connected schools",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildStatsGrid() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _adminService.getDashboardStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final data = snapshot.data!;
        
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildStatCard("Total Schools", "${data['total_schools']}", Icons.school, Colors.blue),
            _buildStatCard("Children Monitored", "${data['total_children']}", Icons.child_care, Colors.purple),
            _buildStatCard("High Risk Cases", "${data['high_risk_children']}", Icons.warning, Colors.red),
            _buildStatCard("Malnutrition", "${data['malnutrition_cases']}", Icons.restaurant_menu, Colors.orange),
            _buildStatCard("Fever Alerts", "${data['fever_alerts_today']}", Icons.thermostat, Colors.deepOrange),
            _buildStatCard("Env. Issues", "${data['poor_aqi_schools']}", Icons.cloud_off, Colors.grey),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    // Basic Layout - In a real app, use ResponsiveDashboard for flexible grid
    // For now fixed width for visual consistency
    return Container(
      width: 160, 
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildHighRiskList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _adminService.getHighRiskList(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final list = snapshot.data!;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200)
          ),
          child: Column(
            children: list.map((item) => ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.red,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
              title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${item['school']} • ${item['risk']}"),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Risk Score: ${item['score']}",
                  style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            )).toList(),
          ),
        );
      },
    );
  }

  void _exportReport(String type) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Generating Excel Report... Please wait.")),
    );
    
    final fileName = await _adminService.exportToExcel(type);
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Export Successful"),
        content: Text("Report generated: $fileName\n\nFile saved to device downloads."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Open File")),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }
}
