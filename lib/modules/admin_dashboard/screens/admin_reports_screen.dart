import 'package:flutter/material.dart';
import 'package:shishu_suraksha/l10n/app_localizations.dart';
import '../../../../app/theme/colors.dart';
import '../services/admin_service.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({Key? key}) : super(key: key);

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> with SingleTickerProviderStateMixin {
  final AdminService _adminService = AdminService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final t = AppLocalizations.of(context)!; // Not used yet

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detailed Reports'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: "High Risk"),
            Tab(text: "Speech & Hearing"),
            Tab(text: "Growth"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReportList("HighRisk"),
          _buildReportList("SpeechHearing"),
          _buildReportList("Growth"),
        ],
      ),
    );
  }

  Widget _buildReportList(String reportType) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _adminService.getReportData(reportType),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final data = snapshot.data!;
        if (data.isEmpty) {
          return const Center(child: Text("No records found"));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: data.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final item = data[index];
            return _buildReportItem(item, reportType);
          },
        );
      },
    );
  }

  Widget _buildReportItem(Map<String, dynamic> item, String type) {
    if (type == "SpeechHearing") {
      return ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple.withOpacity(0.1),
          child: const Icon(Icons.record_voice_over, color: Colors.purple),
        ),
        title: Text(item['Name'] ?? 'Unknown'),
        subtitle: Text("Speech: ${item['SpeechScore']} | Hearing: ${item['Hearing']}"),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Text(item['Action'] ?? 'Monitor', style: const TextStyle(color: Colors.red, fontSize: 12)),
        ),
      );
    }
    
    // Default High Risk / Growth style
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: (item['Category'] == 'Health' ? Colors.red : Colors.orange).withOpacity(0.1),
        child: Icon(
          item['Category'] == 'Health' ? Icons.medical_services : Icons.show_chart,
          color: item['Category'] == 'Health' ? Colors.red : Colors.orange,
        ),
      ),
      title: Text(item['Name']),
      subtitle: Text("${item['School']} • ${item['RiskFactor'] ?? item['Status']}"),
      trailing: item['Score'] != null 
          ? CircleAvatar(
              radius: 14,
              backgroundColor: Colors.grey[200],
              child: Text("${item['Score']}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }
}
