
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../services/responsive_dashboard.dart';
import '../models/device_data.dart';
import '../services/health_service.dart';
import '../../ai_engine/services/risk_engine_service.dart';
import '../../ai_engine/models/risk_assessment.dart';
import '../../../ui/widgets/child_selector_widget.dart';
import '../../../ui/widgets/charts/vitals_trend_chart.dart';
import '../../../../core/services/simulation/iot_simulator.dart';

class HealthDashboardScreen extends StatefulWidget {
  final String? initialChildId;
  final String? initialChildName;

  const HealthDashboardScreen({
    Key? key, 
    this.initialChildId,
    this.initialChildName,
  }) : super(key: key);

  @override
  _HealthDashboardScreenState createState() => _HealthDashboardScreenState();
}

class _HealthDashboardScreenState extends State<HealthDashboardScreen> {
  final HealthService _healthService = HealthService();
  final IoTDeviceSimulator _iotSimulator = IoTDeviceSimulator();
  final RiskEngineService _riskEngine = RiskEngineService();
  
  late String _activeChildId;
  late String _activeChildName;
  final String _schoolId = "DEMO_SCHOOL_01";
  final List<Map<String, dynamic>> _children = DemoDataGenerator.getDemoChildren();

  @override
  void initState() {
    super.initState();
    _activeChildId = widget.initialChildId ?? _children[0]['id'];
    _activeChildName = widget.initialChildName ?? _children[0]['name'];
  }

  @override
  void dispose() {
    _iotSimulator.disconnect();
    super.dispose();
  }

  void _onChildChanged(String id, String name) {
    if (_activeChildId == id) return;
    
    setState(() {
      _activeChildId = id;
      _activeChildName = name;
      // Restart simulation for new child if active
      if (_iotSimulator.isConnected) {
        _iotSimulator.disconnect();
        _iotSimulator.connect();
      }
    });
  }

  void _toggleSimulation() {
    setState(() {
      if (_iotSimulator.isConnected) {
        _iotSimulator.disconnect();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Stopped Simulation")),
        );
      } else {
        _iotSimulator.connect();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Started Live IoT Simulation")),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Health Monitor"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_iotSimulator.isConnected ? Icons.stop_circle : Icons.play_circle),
            tooltip: _iotSimulator.isConnected ? "Stop Simulation" : "Start Simulation",
            onPressed: _toggleSimulation,
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ChildSelectorWidget(
              children: _children,
              selectedChildId: _activeChildId,
              onChildSelected: _onChildChanged,
            ),
          ),
          Expanded(
            child: StreamBuilder<DeviceData?>(
              stream: _iotSimulator.isConnected 
                  ? _iotSimulator.vitalsStream.map((data) => DeviceData(
                      deviceId: data['device_id'],
                      schoolId: _schoolId,
                      childId: _activeChildId,
                      heartRate: (data['heart_rate'] as int).toDouble(),
                      spo2: (data['spo2'] as int).toDouble(),
                      temp: (data['body_temp'] as double),
                      movement: "Active",
                      batteryLevel: 85,
                      signalStrength: 90,
                      timestamp: DateTime.parse(data['timestamp']),
                    ))
                  : _healthService.getLiveVitals(_schoolId, _activeChildId),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
                if (!snapshot.hasData && !_iotSimulator.isConnected) {
                   return const Center(child: Text("No live data. Start simulation."));
                }
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                final data = snapshot.data;
                RiskAssessment risk = data != null 
                    ? _riskEngine.evaluateHealthRisk(data, childName: _activeChildName)
                    : RiskAssessment.normal();

                final double heartRate = data?.heartRate ?? 0;
                final double spo2 = data?.spo2 ?? 0;
                final double temp = data?.temp ?? 0;
                final String movement = data?.movement ?? "No Data";

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusCard(data != null, data?.batteryLevel, data?.signalStrength),
                      const SizedBox(height: 16),
                      _buildRiskCard(risk),
                      const SizedBox(height: 16),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.4,
                        children: [
                          _buildVitalCard("Heart Rate", "${heartRate.toInt()}", "BPM", Icons.favorite, Colors.redAccent, heartRate > 120),
                          _buildVitalCard("SpO2", "${spo2.toInt()}", "%", Icons.water_drop, Colors.blueAccent, spo2 < 95 && spo2 > 0),
                          _buildVitalCard("Temp", temp.toStringAsFixed(1), "°C", Icons.thermostat, Colors.orangeAccent, temp > 38.0),
                          _buildVitalCard("Movement", movement, "", Icons.directions_run, Colors.green, false),
                        ],
                      ),
                      const SizedBox(height: 16),
                      StreamBuilder<List<DeviceData>>(
                        stream: _healthService.getVitalHistory(_schoolId, _activeChildId),
                        builder: (context, histSnapshot) {
                          if (!histSnapshot.hasData) return const SizedBox(height: 100);
                          return VitalsTrendChart(
                            history: histSnapshot.data!, 
                            title: "Heart Rate Trend (BPM)",
                            lineColor: Colors.redAccent,
                          );
                        }
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskCard(RiskAssessment risk) {
    Color cardColor = risk.level == RiskLevel.high ? Colors.red.shade50 : (risk.level == RiskLevel.medium ? Colors.orange.shade50 : Colors.green.shade50);
    Color textColor = risk.level == RiskLevel.high ? Colors.red.shade900 : (risk.level == RiskLevel.medium ? Colors.orange.shade900 : Colors.green.shade900);
    IconData icon = risk.level == RiskLevel.high ? Icons.warning_rounded : (risk.level == RiskLevel.medium ? Icons.info_outline : Icons.check_circle_outline);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Health Risk: ${risk.score}/100", style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 16)),
                Text(risk.message, style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 13)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatusCard(bool isConnected, int? battery, int? signal) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isConnected ? Colors.teal.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isConnected ? Colors.teal.shade100 : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.sensors, color: isConnected ? Colors.teal : Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isConnected ? "IoT Device Active" : "Waiting for IoT Stream...",
              style: TextStyle(color: isConnected ? Colors.teal.shade800 : Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          if (isConnected) ...[
            Icon(Icons.battery_std, size: 14, color: Colors.teal),
            Text(" ${battery ?? 0}%", style: const TextStyle(fontSize: 10, color: Colors.teal)),
            const SizedBox(width: 8),
            Icon(Icons.wifi, size: 14, color: Colors.teal),
            Text(" ${signal ?? 0}%", style: const TextStyle(fontSize: 10, color: Colors.teal)),
          ]
        ],
      ),
    );
  }

  Widget _buildVitalCard(String title, String value, String unit, IconData icon, Color color, bool isAlert) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isAlert ? Border.all(color: Colors.red, width: 2) : Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 4),
              Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(width: 2),
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(unit, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
              ),
            ],
          )
        ],
      ),
    );
  }
}

