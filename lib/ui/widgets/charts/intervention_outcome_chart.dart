import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/dashboard_data.dart';

import 'package:shishu_suraksha/l10n/generated/app_localizations.dart';

class InterventionOutcomeChart extends StatelessWidget {
  final InterventionOutcome data;
  final AppLocalizations t;

  const InterventionOutcomeChart({Key? key, required this.data, required this.t}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int total = data.improved + data.underMonitoring + data.noImprovement;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
             Align(
              alignment: Alignment.centerLeft,
              child: Text(
                t.interventionSuccessRate,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: Stack(
                children: [
                   PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 60,
                      startDegreeOffset: -90,
                      sections: [
                        PieChartSectionData(
                          color: Colors.teal[400],
                          value: data.improved.toDouble(),
                          title: '${(data.improved / total * 100).toStringAsFixed(0)}%',
                          radius: 30,
                          showTitle: true,
                          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        PieChartSectionData(
                          color: Colors.orange[300],
                          value: data.underMonitoring.toDouble(),
                          title: '${(data.underMonitoring / total * 100).toStringAsFixed(0)}%',
                          radius: 30,
                          showTitle: true,
                          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        PieChartSectionData(
                          color: Colors.red[300],
                          value: data.noImprovement.toDouble(),
                          title: '${(data.noImprovement / total * 100).toStringAsFixed(0)}%',
                          radius: 30,
                          showTitle: true,
                          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "$total",
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                         Text(
                          t.keyTotal,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),
             Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildLegendItem(Colors.teal[400]!, t.keyImproved),
                _buildLegendItem(Colors.orange[300]!, t.keyMonitoring),
                _buildLegendItem(Colors.red[300]!, t.keyNoChange),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
