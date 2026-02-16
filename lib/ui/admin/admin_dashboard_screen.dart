import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/data/models/admin_models.dart';
import '../../core/data/services/admin_data_service.dart';
import 'school_detail_screen.dart';
import 'alert_management_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminDataService _dataService = AdminDataService();
  late Future<AdminSummaryModel> _summaryFuture;
  late Future<List<AlertModel>> _alertsFuture;
  
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _summaryFuture = _dataService.getDashboardSummary();
      _alertsFuture = _dataService.getActiveAlerts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NATIONAL DASHBOARD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2, color: Colors.white)),
            Text('Ministry of Women & Child Development', style: TextStyle(fontSize: 10, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshData,
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white30),
              ),
              child: const Row(
                children: [
                  Icon(Icons.admin_panel_settings, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text('ADMIN', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, "/auth", (route) => false);
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: FutureBuilder<AdminSummaryModel>(
        future: _summaryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final summary = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. KPI Cards Row
                Row(
                  children: [
                    Expanded(child: _buildKpiCard('Total Schools', '${summary.totalSchools}', Icons.school, Colors.indigo, '+2 this week')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildKpiCard('Total Children', '${summary.totalChildren}', Icons.child_care, Colors.purple, '+45 this week')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildKpiCard('High Risk', '${summary.totalHighRisk}', Icons.warning_amber, Colors.red, 'Requires Action')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildKpiCard('Active Alerts', '${summary.activeAlerts}', Icons.notifications_active, Colors.orange, 'Urgent')),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // 2. Health Index & Analytics
                Row(
                   children: [
                     Expanded(
                       flex: 5,
                       child: _buildHealthIndexCard(summary.nationalHealthIndex),
                     ),
                     const SizedBox(width: 16),
                     Expanded(
                       flex: 4,
                       child: _buildRiskDistributionChart(summary),
                     ),
                   ],
                ),

                const SizedBox(height: 24),
                
                // 3. District Comparison Chart
                _buildDistrictPerformanceChart(summary),

                const SizedBox(height: 24),
                
                // 4. Alerts Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('CRITICAL ALERTS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.blueGrey)),
                    TextButton(onPressed: (){
                       Navigator.push(context, MaterialPageRoute(builder: (context) => const AlertManagementScreen()));
                    }, child: const Text('View All'))
                  ],
                ),
                FutureBuilder<List<AlertModel>>(
                  future: _alertsFuture,
                  builder: (context, alertSnapshot) {
                    if (!alertSnapshot.hasData) return const LinearProgressIndicator();
                    return Column(
                      children: alertSnapshot.data!.map((alert) => _buildAlertTile(alert)).toList(),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                // 4. Critical Schools
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(child: Text('SCHOOLS REQUIRING ATTENTION', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.blueGrey))),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 150,
                      height: 35,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          prefixIcon: const Icon(Icons.search, size: 16),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                 ...summary.criticalSchools
                    .where((s) => s.name.toLowerCase().contains(_searchQuery) || s.district.toLowerCase().contains(_searchQuery))
                    .map((s) => Card(
                   elevation: 2,
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                   margin: const EdgeInsets.only(bottom: 12),
                   child: ListTile(
                     contentPadding: const EdgeInsets.all(12),
                     leading: Container(
                       padding: const EdgeInsets.all(10),
                       decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(10)),
                       child: const Icon(Icons.school, color: Colors.red),
                     ),
                     title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                     subtitle: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         const SizedBox(height: 4),
                         Text('${s.district} • ID: ${s.id}'),
                         const SizedBox(height: 4),
                         const SizedBox(height: 4),
                         Wrap(
                           spacing: 12,
                           runSpacing: 4,
                           children: [
                             Row(
                               mainAxisSize: MainAxisSize.min,
                               children: [
                                 Icon(Icons.health_and_safety, size: 14, color: Colors.red[400]),
                                 const SizedBox(width: 4),
                                 Text('Avg Health: ${s.averageHealthScore}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11)),
                               ],
                             ),
                             Row(
                               mainAxisSize: MainAxisSize.min,
                               children: [
                                 Icon(Icons.warning, size: 14, color: Colors.orange[800]),
                                 const SizedBox(width: 4),
                                 Text('${s.highRiskCount} High Risk', style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.bold, fontSize: 11)),
                               ],
                             ),
                           ],
                         )
                       ],
                     ),
                     trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                     onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SchoolDetailScreen(school: s)),
                        );
                     },
                   ),
                 )).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color, String footer) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.blueGrey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])),
          ),
          Text(title, style: TextStyle(color: Colors.blueGrey[400], fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(height: 1, color: Colors.grey[100]),
          const SizedBox(height: 8),
          Text(footer, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildHealthIndexCard(double score) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF2E3192), Color(0xFF1BFFFF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF2E3192).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'NATIONAL HEALTH INDEX', 
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  overflow: TextOverflow.ellipsis,
                )
              ),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(score.toStringAsFixed(0), style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.bold)),
              const Padding(
                padding: EdgeInsets.only(bottom: 12, left: 4),
                child: Text('/ 100', style: TextStyle(color: Colors.white70, fontSize: 16)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
            child: const Text(
              'Top Performing: Mysore Region', 
              style: TextStyle(color: Colors.white, fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistrictPerformanceChart(AdminSummaryModel summary) {
     return Container(
       padding: const EdgeInsets.all(20),
       decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(20),
         boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)]
       ),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           const Text('DISTRICT PERFORMANCE COMPARISON', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueGrey)),
           const SizedBox(height: 20),
           SizedBox(
             height: 200,
             child: BarChart(
               BarChartData(
                 alignment: BarChartAlignment.spaceEvenly,
                 maxY: 100,
                 barGroups: [
                   _buildDistrictBar(0, 88, 'Bangalore'),
                   _buildDistrictBar(1, 72, 'Mysore'),
                   _buildDistrictBar(2, 65, 'Tumkur'),
                   _buildDistrictBar(3, 79, 'Hassan'),
                 ],
                 titlesData: FlTitlesData(
                   bottomTitles: AxisTitles(
                     sideTitles: SideTitles(
                       showTitles: true,
                       getTitlesWidget: (value, meta) {
                          switch(value.toInt()) {
                            case 0: return const Text('BLR', style: TextStyle(fontSize: 10));
                            case 1: return const Text('MYS', style: TextStyle(fontSize: 10));
                            case 2: return const Text('TUM', style: TextStyle(fontSize: 10));
                            case 3: return const Text('HAS', style: TextStyle(fontSize: 10));
                          }
                          return const Text('');
                       }
                     )
                   ),
                   leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (val, meta) => Text('${val.toInt()}', style: const TextStyle(fontSize: 9)))),
                   topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                   rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                 ),
                 gridData: FlGridData(show: true, drawVerticalLine: false),
                 borderData: FlBorderData(show: false),
               )
             ),
           )
         ],
       ),
     );
  }

  BarChartGroupData _buildDistrictBar(int x, double y, String label) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y, 
          color: y > 80 ? Colors.green : (y > 70 ? Colors.orange : Colors.red), 
          width: 25, 
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6))
        )
      ]
    );
  }

  Widget _buildRiskDistributionChart(AdminSummaryModel summary) {
     int total = summary.totalChildren;
     int normal = total - summary.totalHighRisk - summary.totalMalnutrition*2;
     
     return Container(
       height: 220, // Increased height for legend
       padding: const EdgeInsets.all(16),
       decoration: BoxDecoration(
         color: Colors.white, 
         borderRadius: BorderRadius.circular(20),
         boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)]
       ),
       child: Column(
         children: [
           const Text('RISK DISTRIBUTION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueGrey)),
           const SizedBox(height: 10),
           Expanded(
             child: Stack(
               alignment: Alignment.center,
               children: [
                 PieChart(
                   PieChartData(
                     sectionsSpace: 2,
                     centerSpaceRadius: 35,
                     sections: [
                       PieChartSectionData(color: const Color(0xFFFF5252), value: summary.totalHighRisk.toDouble(), radius: 15, showTitle: false),
                       PieChartSectionData(color: const Color(0xFFFFB74D), value: summary.totalMalnutrition.toDouble() * 2, radius: 15, showTitle: false), 
                       PieChartSectionData(color: const Color(0xFF66BB6A), value: normal.toDouble(), radius: 15, showTitle: false),
                     ],
                   ),
                 ),
                 Column(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     Text('${summary.totalChildren}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                     const Text('Kids', style: TextStyle(fontSize: 10, color: Colors.grey)),
                   ],
                 )
               ],
             ),
           ),
           const SizedBox(height: 8),
           Wrap(
             spacing: 8,
             runSpacing: 4,
             alignment: WrapAlignment.center,
             children: [
               _buildLegend(Colors.green, 'Normal'),
               _buildLegend(Colors.orange, 'Monitor'),
               _buildLegend(Colors.red, 'High'),
             ],
           )
         ],
       ),
     );
  }
  
  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 8), 
        const SizedBox(width: 4), 
        Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600))
      ],
    );
  }

  Widget _buildAlertTile(AlertModel alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: alert.severity == 'High' ? Colors.redAccent : Colors.orangeAccent, width: 4)),
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(alert.issue, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
               Icon(Icons.person, size: 12, color: Colors.grey[600]),
               const SizedBox(width: 4),
               Flexible(child: Text(alert.childName, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[800], fontSize: 12, fontWeight: FontWeight.w500))),
               const SizedBox(width: 8),
               Icon(Icons.school, size: 12, color: Colors.grey[600]),
               const SizedBox(width: 4),
               Flexible(child: Text(alert.schoolName, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600], fontSize: 12))),
            ],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: alert.severity == 'High' ? Colors.red[50] : Colors.orange[50],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: alert.severity == 'High' ? Colors.red.withOpacity(0.3) : Colors.orange.withOpacity(0.3))
              ),
              child: Text(alert.severity.toUpperCase(), style: TextStyle(color: alert.severity == 'High' ? Colors.red[800] : Colors.orange[800], fontWeight: FontWeight.bold, fontSize: 10)),
            ),
            const SizedBox(height: 4),
            Text('2m ago', style: TextStyle(color: Colors.grey[400], fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
