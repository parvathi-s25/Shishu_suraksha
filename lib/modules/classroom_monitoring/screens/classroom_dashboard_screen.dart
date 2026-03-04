
import 'package:flutter/material.dart';
import '../../../../services/responsive_dashboard.dart';
import '../models/classroom_environment.dart';
import '../services/classroom_service.dart';
import '../services/mock_environment_provider.dart';

class ClassroomDashboardScreen extends StatefulWidget {
  const ClassroomDashboardScreen({Key? key}) : super(key: key);

  @override
  _ClassroomDashboardScreenState createState() => _ClassroomDashboardScreenState();
}

class _ClassroomDashboardScreenState extends State<ClassroomDashboardScreen> {
  final ClassroomService _classroomService = ClassroomService();
  final MockEnvironmentProvider _mockProvider = MockEnvironmentProvider();
  bool _isSimulating = false;
  
  // Hardcoded Demo IDs
  final String _schoolId = "DEMO_SCHOOL_01";
  final String _classroomId = "CLASS_101";

  @override
  void dispose() {
    _mockProvider.stopSimulation();
    super.dispose();
  }

  void _toggleSimulation() {
    setState(() {
      _isSimulating = !_isSimulating;
      if (_isSimulating) {
        _mockProvider.startSimulation(_schoolId, _classroomId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Started Classroom Environment Simulation")),
        );
      } else {
        _mockProvider.stopSimulation();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Stopped Simulation")),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Classroom Environment"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isSimulating ? Icons.stop_circle : Icons.play_circle),
            color: _isSimulating ? Colors.red : Colors.green,
            tooltip: _isSimulating ? "Stop Simulation" : "Start Simulation",
            onPressed: _toggleSimulation,
          )
        ],
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: StreamBuilder<ClassroomEnvironment?>(
        stream: _classroomService.getLiveEnvironment(_schoolId, _classroomId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
             return Center(child: Text("Error: ${snapshot.error}"));
          }

          final data = snapshot.data;
          
          // Defaults
          final int aqi = data?.aqi ?? 0;
          final double noise = data?.noiseLevel ?? 0;
          final double temp = data?.temperature ?? 0;
          final double light = data?.lightIntensity ?? 0;
          final String aqiStatus = data?.aqiStatus ?? "--";
          final int healthIndex = data?.healthIndex ?? 0;
          final String healthStatus = data?.healthIndexStatus ?? "No Data";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverallScore(healthIndex, healthStatus, data != null),
                const SizedBox(height: 24),
                
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _buildMetricCard("Air Quality", "$aqi AQI", aqiStatus, Icons.air, _getAQIColor(aqi)),
                    _buildMetricCard("Temperature", "${temp.toStringAsFixed(1)}°C", data?.tempStatus ?? "Live", Icons.thermostat, Colors.orange),
                    _buildMetricCard("Noise Level", "${noise.toInt()} dB", data?.noiseStatus ?? "--", Icons.volume_up, _getNoiseColor(noise)),
                    _buildMetricCard("Lighting", "${light.toInt()} Lux", data?.lightStatus ?? "Bright", Icons.wb_sunny, Colors.amber),
                  ],
                ),
                
                const SizedBox(height: 24),
                _buildRecommendations(aqi, noise, data),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getAQIColor(int aqi) {
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.yellow.shade700;
    if (aqi <= 150) return Colors.orange;
    return Colors.red;
  }

  Color _getNoiseColor(double noise) {
    if (noise < 50) return Colors.green;
    if (noise < 70) return Colors.blue;
    return Colors.red;
  }

  Widget _buildOverallScore(int score, String status, bool hasData) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6dd5ed), Color(0xFF2193b0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2193b0).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Classroom Health Index",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            hasData ? "$score" : "--",
            style: const TextStyle(
              color: Colors.white, 
              fontSize: 56, 
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              hasData ? status : "No Data",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String status, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  fontSize: 14, 
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12, 
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations(int aqi, double noise, ClassroomEnvironment? data) {
    List<Widget> suggestions = [];
    
    if (aqi > 100) {
      suggestions.add(_buildSuggestionItem("Air quality is poor. Open windows for better ventilation.", Icons.air));
    }
    if (noise > 70) {
      suggestions.add(_buildSuggestionItem("Noise levels are high. Consider a quiet reading session.", Icons.volume_off));
    }
    if (data != null) {
      if (data.temperature > 30) {
        suggestions.add(_buildSuggestionItem("Room is too hot. Ensure fans are working and children stay hydrated.", Icons.thermostat));
      } else if (data.temperature < 18) {
        suggestions.add(_buildSuggestionItem("Room is too cold. Close windows if necessary.", Icons.thermostat));
      }
      if (data.lightIntensity < 300) {
        suggestions.add(_buildSuggestionItem("Lighting is low. Switch on lights or open curtains.", Icons.lightbulb));
      }
    }
    
    if (suggestions.isEmpty) {
      suggestions.add(_buildSuggestionItem("Environment looks great! Keep it up.", Icons.thumb_up));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "AI Suggestions",
          style: TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.bold, 
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...suggestions.map((w) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: w,
        )),
      ],
    );
  }
  
  Widget _buildSuggestionItem(String text, IconData icon) {
     return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
            ],
          ),
        );
  }
}
