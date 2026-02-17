
import 'package:flutter/material.dart';
import 'package:shishu_suraksha/l10n/app_localizations.dart';
import '../../../../app/theme/colors.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.reports),
         automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "Centralized Reports",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
             const SizedBox(height: 8),
            Text(
              "Access detailed analytics across all districts",
              style: Theme.of(context).textTheme.bodySmall,
            ),
             const SizedBox(height: 32),
             Wrap(
               spacing: 16,
               runSpacing: 16,
               alignment: WrapAlignment.center,
               children: [
                 _buildReportCard(context, "Growth Reports", Icons.show_chart, Colors.teal),
                 _buildReportCard(context, "Health Screening", Icons.medical_services, Colors.orange),
                 _buildReportCard(context, "High Risk Cases", Icons.warning, Colors.red),
                 _buildReportCard(context, "Performance", Icons.school, Colors.blue),
               ],
             )
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, String title, IconData icon, Color color) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("View Report", style: TextStyle(color: Colors.blue, fontSize: 12)),
        ],
      ),
    );
  }
}
