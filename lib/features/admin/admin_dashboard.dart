import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/dashboard_card.dart';
import 'widgets/live_vital_card.dart'; // Imported
import 'widgets/live_vital_card.dart'; // Imported
import 'widgets/admin_analytics_chart.dart'; // Imported
import 'widgets/admin_sidebar.dart';
import '../../modules/admin_dashboard/services/admin_service.dart';
import '../../core/constants/app_constants.dart';
import '../../models/child_model.dart';
import '../../services/analytics_engine.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/widgets/cropped_logo.dart'; // Imported
import '../../../main.dart'; // For MyApp.setLocale
import '../../core/theme/app_theme.dart'; // Imported

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AdminDashboardContent(),
    );
  }
}

class AdminDashboardContent extends StatefulWidget {
  const AdminDashboardContent({super.key});

  @override
  State<AdminDashboardContent> createState() => _AdminDashboardContentState();
}

class _AdminDashboardContentState extends State<AdminDashboardContent> {
  final _adminService = AdminService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _adminService.getDashboardStats(),
      builder: (context, snapshot) {
        final l10n = AppLocalizations.of(context)!;
        
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;

        // Optional: Listen to Hive for real count if needed, but for now use Mock Data
        // to show the specific Speech/Hearing stats which aren't in Hive yet completely.

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                l10n.adminPanel,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              
              // Key Stats Grid
              GridView.count(
                crossAxisCount: ResponsiveLayout.isMobile(context) ? 2 : 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                childAspectRatio: 1.4,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                   DashboardCard(
                    title: l10n.totalSchools,
                    value: "${data['total_schools']}",
                    icon: Icons.school,
                    color: Colors.blue,
                  ),
                  DashboardCard(
                    title: l10n.totalChildren,
                    value: "${data['total_children']}",
                    icon: Icons.child_care,
                    color: Colors.green,
                  ),
                   DashboardCard(
                    title: l10n.highRiskCases,
                    value: "${data['high_risk_children']}",
                    icon: Icons.warning,
                    color: Colors.red,
                  ),
                   DashboardCard(
                    title: l10n.malnutrition,
                    value: "${data['malnutrition_cases']}",
                    icon: Icons.restaurant_menu,
                    color: Colors.orange,
                  ),
                  DashboardCard(
                    title: "Speech Issues", // TODO: Localize
                    value: "${data['speech_issues']}",
                    icon: Icons.record_voice_over,
                    color: Colors.purple,
                  ),
                  DashboardCard(
                    title: "Hearing Issues", // TODO: Localize
                    value: "${data['hearing_issues']}",
                    icon: Icons.hearing,
                    color: Colors.teal,
                  ),
                  DashboardCard(
                    title: "Pending Referrals", // TODO: Localize
                    value: "${data['pending_referrals']}",
                    icon: Icons.medical_services,
                    color: Colors.redAccent,
                  ),
                   DashboardCard(
                    title: l10n.envIssues,
                    value: "${data['poor_aqi_schools']}",
                    icon: Icons.cloud_off,
                    color: Colors.grey,
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Analytics Section
               Text(
                 "Analytics Overview", // TODO: Localize
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              
              // New Chart Widget
              const AdminAnalyticsChart(),
            ],
          ),
        );
      },
    );
  }
}
