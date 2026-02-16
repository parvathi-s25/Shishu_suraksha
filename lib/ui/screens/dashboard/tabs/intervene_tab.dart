import 'package:flutter/material.dart';
import '../../../../services/alert_generator.dart';
import '../../../../models/alert_model.dart';
import '../../../widgets/alert_card.dart';
import '../../../../services/responsive_dashboard.dart';
import 'package:shishu_suraksha/l10n/app_localizations.dart';

class InterveneTab extends StatefulWidget {
  const InterveneTab({Key? key}) : super(key: key);

  @override
  State<InterveneTab> createState() => _InterveneTabState();
}

class _InterveneTabState extends State<InterveneTab> {
  List<AlertModel> _alerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  void _loadAlerts() {
    // Simulate loading delay for realistic UX
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _alerts = AlertGenerator.getMockAlerts();
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveDashboard(context);
    final t = AppLocalizations.of(context)!;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        if (_isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.teal),
          );
        }

        if (_alerts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: responsive.getFontSize(80),
                  color: Colors.green[300],
                ),
                SizedBox(height: responsive.getSpacing(16)),
                Text(
                  t.noAlerts,
                  style: TextStyle(
                    fontSize: responsive.getFontSize(20),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: responsive.getSpacing(8)),
                Text(
                  t.allMonitored,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: responsive.getFontSize(14),
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: responsive.getSpacing(20)),

                // Header Section
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.getSpacing(20),
                    vertical: responsive.getSpacing(16),
                  ),
                  margin: EdgeInsets.symmetric(
                    horizontal: responsive.contentPadding.left,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.teal[50]!, Colors.teal[100]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.teal.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_active,
                            color: Colors.teal[700],
                            size: responsive.getFontSize(28),
                          ),
                          SizedBox(width: responsive.getSpacing(12)),
                          Text(
                            t.childAlerts,
                            style: TextStyle(
                              fontSize: responsive.getFontSize(24),
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: responsive.getSpacing(8)),
                      Text(
                        '${_alerts.length} ${t.alertsAttention}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: responsive.getFontSize(14),
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: responsive.getSpacing(20)),

                // Risk Level Summary Badges
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.contentPadding.left,
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: responsive.getSpacing(8),
                    runSpacing: responsive.getSpacing(8),
                    children: [
                      _buildRiskBadge(
                        '🔴 ${t.riskHigh}',
                        _alerts.where((a) => a.riskLevel == RiskLevel.high).length,
                        Colors.red,
                        responsive,
                      ),
                      _buildRiskBadge(
                        '🟠 ${t.riskModerate}',
                        _alerts.where((a) => a.riskLevel == RiskLevel.moderate).length,
                        Colors.orange,
                        responsive,
                      ),
                      _buildRiskBadge(
                        '🟡 ${t.riskMild}',
                        _alerts.where((a) => a.riskLevel == RiskLevel.mild).length,
                        Colors.amber,
                        responsive,
                      ),
                      _buildRiskBadge(
                        '🟢 ${t.riskNormal}',
                        _alerts.where((a) => a.riskLevel == RiskLevel.normal).length,
                        Colors.green,
                        responsive,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: responsive.getSpacing(24)),

                // Alert Cards List
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.contentPadding.left,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _alerts.length,
                    itemBuilder: (context, index) {
                      return AlertCard(alert: _alerts[index]);
                    },
                  ),
                ),

                SizedBox(height: responsive.getSpacing(20)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRiskBadge(
    String label,
    int count,
    Color color,
    ResponsiveDashboard responsive,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.getSpacing(12),
        vertical: responsive.getSpacing(6),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(
          fontSize: responsive.getFontSize(12),
          fontWeight: FontWeight.w600,
          color: color is MaterialColor ? (color as MaterialColor)[900] ?? color : color,
        ),
      ),
    );
  }
}
