
import 'package:flutter/material.dart';
import 'package:shishu_suraksha/l10n/app_localizations.dart';
import '../../../../services/responsive_dashboard.dart';
import '../services/admin_service.dart';
import 'package:shishu_suraksha/app/theme/colors.dart';
import 'excel_view_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService _adminService = AdminService();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final responsive = ResponsiveDashboard(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return _DesktopAdminView(
              t: t, responsive: responsive, adminService: _adminService);
        } else {
          return _MobileAdminView(
              t: t, responsive: responsive, adminService: _adminService);
        }
      },
    );
  }
}

class _MobileAdminView extends StatelessWidget {
  final AppLocalizations t;
  final ResponsiveDashboard responsive;
  final AdminService adminService;

  const _MobileAdminView({
    required this.t,
    required this.responsive,
    required this.adminService,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: responsive.contentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AdminHeader(t: t, responsive: responsive),
          SizedBox(height: responsive.getSpacing(24)),
          _StatsGrid(t: t, responsive: responsive, adminService: adminService),
          SizedBox(height: responsive.getSpacing(32)),
          _HighRiskSection(t: t, responsive: responsive, adminService: adminService),
          SizedBox(height: responsive.getSpacing(80)),
        ],
      ),
    );
  }
}

class _DesktopAdminView extends StatelessWidget {
  final AppLocalizations t;
  final ResponsiveDashboard responsive;
  final AdminService adminService;

  const _DesktopAdminView({
    required this.t,
    required this.responsive,
    required this.adminService,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: responsive.contentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AdminHeader(t: t, responsive: responsive),
          SizedBox(height: responsive.getSpacing(24)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _StatsGrid(
                    t: t, responsive: responsive, adminService: adminService),
              ),
              SizedBox(width: responsive.getSpacing(24)),
              Expanded(
                flex: 2,
                child: _HighRiskSection(
                    t: t, responsive: responsive, adminService: adminService),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminHeader extends StatelessWidget {
  final AppLocalizations t;
  final ResponsiveDashboard responsive;

  const _AdminHeader({required this.t, required this.responsive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: responsive.getSpacing(16)),
      child: Row(
        children: [
          Icon(Icons.admin_panel_settings, size: 32, color: AppColors.primary),
          SizedBox(width: responsive.getSpacing(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.centralConsole,
                  style: TextStyle(
                      fontSize: responsive.getFontSize(24),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
                Text(
                  t.realtimeOverview,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: responsive.getFontSize(14),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final AppLocalizations t;
  final ResponsiveDashboard responsive;
  final AdminService adminService;

  const _StatsGrid(
      {required this.t, required this.responsive, required this.adminService});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: adminService.getDashboardStats(),
      builder: (context, snapshot) {
        final data = snapshot.hasData
            ? snapshot.data!
            : {
                'total_schools': '...',
                'total_children': '...',
                'high_risk_children': '...',
                'malnutrition_cases': '...',
                'fever_alerts_today': '...',
                'poor_aqi_schools': '...'
              };

        return GridView.count(
          crossAxisCount:
              responsive.isMobile ? 2 : (responsive.isTablet ? 3 : 3),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: responsive.getSpacing(16),
          crossAxisSpacing: responsive.getSpacing(16),
          childAspectRatio: responsive.isMobile ? 1.3 : 1.5,
          children: [
            _buildStatCard(t.totalSchools, "${data['total_schools']}",
                Icons.school, Colors.blue, responsive),
            _buildStatCard(t.childrenMonitored, "${data['total_children']}",
                Icons.child_care, Colors.purple, responsive),
            _buildStatCard(t.highRiskCases, "${data['high_risk_children']}",
                Icons.warning, Colors.red, responsive),
            _buildStatCard(t.malnutrition, "${data['malnutrition_cases']}",
                Icons.restaurant_menu, Colors.orange, responsive),
            _buildStatCard(t.feverAlerts, "${data['fever_alerts_today']}",
                Icons.thermostat, Colors.deepOrange, responsive),
            _buildStatCard(t.envIssues, "${data['poor_aqi_schools']}",
                Icons.cloud_off, Colors.grey, responsive),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color,
      ResponsiveDashboard responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.getSpacing(16)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: responsive.getFontSize(28)),
              // Optional: Add trend indicator here if available
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                    fontSize: responsive.getFontSize(28),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: responsive.getFontSize(12),
                    color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HighRiskSection extends StatelessWidget {
  final AppLocalizations t;
  final ResponsiveDashboard responsive;
  final AdminService adminService;

  const _HighRiskSection(
      {required this.t, required this.responsive, required this.adminService});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              t.highRiskChildren,
              style: TextStyle(
                  fontSize: responsive.getFontSize(18),
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade900),
            ),
            ElevatedButton.icon(
              onPressed: () => _exportReport(context, "HighRisk", t),
              icon: const Icon(Icons.file_download),
              label: Text(t.exportExcel),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                    horizontal: responsive.getSpacing(16),
                    vertical: responsive.getSpacing(12)),
              ),
            ),
          ],
        ),
        SizedBox(height: responsive.getSpacing(16)),
        _buildHighRiskList(t, responsive),
      ],
    );
  }

  Widget _buildHighRiskList(
      AppLocalizations t, ResponsiveDashboard responsive) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: adminService.getHighRiskList(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final list = snapshot.data!;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: list
                .map((item) => Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: responsive.getSpacing(16),
                              vertical: responsive.getSpacing(8)),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.error.withOpacity(0.1),
                            child: Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
                          ),
                          title: Text(item['name'],
                              style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          subtitle: Text(
                              "${item['school']} • ${_getLocalizedRisk(item['risk'], t)}",
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          trailing: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: responsive.getSpacing(10),
                                vertical: responsive.getSpacing(4)),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              "${t.riskScore}: ${item['score']}",
                              style: TextStyle(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold,
                                  fontSize: responsive.getFontSize(12)),
                            ),
                          ),
                        ),
                        if (list.last != item) const Divider(height: 1, indent: 16, endIndent: 16),
                      ],
                    ))
                .toList(),
          ),
        );
      },
    );
  }

  // Method to open In-App Excel Viewer
  String _getLocalizedRisk(String rawRisk, AppLocalizations t) {
    if (rawRisk.contains("High Heart Rate")) {
      return "${t.riskHighHeartRate} ${rawRisk.replaceAll('High Heart Rate', '').trim()}";
    } else if (rawRisk.contains("Low SpO2")) {
      return "${t.riskLowSpo2} ${rawRisk.replaceAll('Low SpO2', '').trim()}";
    } else if (rawRisk.contains("Severe Malnutrition")) {
      return "${t.riskSevereMalnutrition} ${rawRisk.replaceAll('Severe Malnutrition', '').trim()}";
    } else if (rawRisk.contains("High Fever")) {
      return "${t.riskHighFever} ${rawRisk.replaceAll('High Fever', '').trim()}";
    } else if (rawRisk.contains("Irregular ECG")) {
      return t.riskIrregularEcg;
    }
    return rawRisk;
  }

  void _openReport(BuildContext context, String type, AppLocalizations t) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.generatingReport)),
    );

    try {
      final data = await adminService.getReportData(type);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        
        if (data.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(t.noDataAvailable))
          );
          return;
        }

        final headers = data.first.keys.toList();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExcelViewScreen(
              title: "$type Report", 
              data: data, 
              headers: headers
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
         ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text("Error: $e"))
          );
      }
    }
  }

  void _exportReport(
      BuildContext context, String type, AppLocalizations t) async {
      // Replaced by _openReport
      _openReport(context, type, t);
  }
}
