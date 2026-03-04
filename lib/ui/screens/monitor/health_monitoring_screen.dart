import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/data/models/child_model.dart';
import '../../../../core/data/models/health_data_model.dart';
import '../../../../core/data/services/health_simulator_service.dart';
import '../../../../core/data/services/risk_stratification_service.dart';
import 'dart:async';

class HealthMonitoringScreen extends StatefulWidget {
  final ChildModel child;
  const HealthMonitoringScreen({Key? key, required this.child}) : super(key: key);

  @override
  State<HealthMonitoringScreen> createState() => _HealthMonitoringScreenState();
}

class _HealthMonitoringScreenState extends State<HealthMonitoringScreen> {
  final HealthSimulatorService _simulator = HealthSimulatorService();
  final RiskStratificationService _riskService = RiskStratificationService();
  
  // Chart Data Buffers
  final List<FlSpot> _hrSpots = [];
  final List<FlSpot> _spo2Spots = [];
  double _timeCounter = 0;
  
  StreamSubscription<HealthData>? _subscription;
  Map<String, dynamic> _latestRisk = {};

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    _subscription = _simulator.getHealthStream(widget.child.id).listen((data) {
      if (mounted) {
        setState(() {
          _timeCounter++;
          // Maintain window of last 20 points
          _hrSpots.add(FlSpot(_timeCounter, data.heartRate.toDouble()));
          if (_hrSpots.length > 20) _hrSpots.removeAt(0);

          _spo2Spots.add(FlSpot(_timeCounter, data.spo2.toDouble()));
          if (_spo2Spots.length > 20) _spo2Spots.removeAt(0);

          // Calculate Risk
          _latestRisk = _riskService.calculateRisk(data);
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Health Monitor: ${widget.child.name}', style: const TextStyle(fontSize: 16)),
            const Row(
              children: [
                Icon(Icons.circle, color: Colors.green, size: 10),
                SizedBox(width: 4),
                Text('Device Connected', style: TextStyle(fontSize: 12, color: Colors.greenAccent)),
              ],
            )
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.red),
            tooltip: 'Simulate Stress Event',
            onPressed: () {
               _simulator.triggerStressMode(widget.child.id);
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('⚡ INJECTING STRESS EVENT ⚡')),
               );
            },
          )
        ],
      ),
      body: StreamBuilder<HealthData>(
        stream: _simulator.getHealthStream(widget.child.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          final riskColor = Color(int.parse(_latestRisk['color_hex'] ?? '0xFF4CAF50'));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 1. AI Risk Header
              _buildRiskCard(data, riskColor),
              
              const SizedBox(height: 20),
              
              // 2. Vitals Grid
              Row(
                children: [
                  Expanded(child: _buildVitalCard('Heart Rate', '${data.heartRate} bpm', Icons.favorite, Colors.red, _hrSpots, 60, 150)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildVitalCard('SpO2', '${data.spo2}%', Icons.water_drop, Colors.blue, _spo2Spots, 85, 100)),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 3. Secondary Vitals
              Row(
                children: [
                  Expanded(child: _buildStatTile('Temp', '${data.temperature}°C', Icons.thermostat, Colors.orange)),
                ],
              ),
              
            ],
          );
        },
      ),
    );
  }

  Widget _buildRiskCard(HealthData data, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.smart_toy, color: color, size: 30),
              const SizedBox(width: 10),
              Text(
                'AI ASSESSMENT: ${_latestRisk['level']?.toUpperCase() ?? "NORMAL"}',
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          if ((_latestRisk['factors'] as List?)?.isNotEmpty ?? false) ...[
            const Divider(),
            ...(_latestRisk['factors'] as List).map((f) => 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     const Icon(Icons.warning_amber, size: 16, color: Colors.red),
                     const SizedBox(width: 8),
                     Text(f, style: const TextStyle(fontWeight: FontWeight.w500)),
                   ],
                ),
              )
            ).toList()
          ]
        ],
      ),
    );
  }

  Widget _buildVitalCard(String title, String value, IconData icon, Color color, List<FlSpot> spots, double minY, double maxY) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color),
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 10),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minX: _timeCounter > 20 ? _timeCounter - 20 : 0,
                maxX: _timeCounter > 20 ? _timeCounter : 20,
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: color.withOpacity(0.1)),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatTile(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
