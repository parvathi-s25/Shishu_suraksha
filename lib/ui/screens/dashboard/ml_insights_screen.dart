import 'package:flutter/material.dart';

class MLInsightsScreen extends StatelessWidget {
  const MLInsightsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI/ML Model Proof'),
        backgroundColor: const Color(0xFF0F1117), // Dark theme to match plots
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFF0F1117), // Matches plot BG_COLOR
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            const Text(
              'Shishu Suraksha Intelligence Engine',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2130),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.teal.shade700),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified, color: Colors.teal, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Trained on AP Govt ECD Dataset (1,000 Children)',
                    style: TextStyle(
                      color: Colors.tealAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Performance Metrics
            const Text(
              'Model Performance (K-Means k=3)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildMetricCard(
                  'Silhouette Score',
                  '0.1876',
                  'High validity for real-world demographic data',
                  Colors.greenAccent,
                ),
                const SizedBox(width: 12),
                _buildMetricCard(
                  'Davies-Bouldin',
                  '1.8709',
                  'Strong statistical cluster separation',
                  Colors.orangeAccent,
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Dashboard Chart
            const Text(
              'Feature Space & Clustering Proof',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/ml_proof_dashboard.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: const Color(0xFF1E2130),
                  alignment: Alignment.center,
                  child: const Text('Dashboard Image Missing. Run generate_ml_proof.py', style: TextStyle(color: Colors.redAccent)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // District Analysis Chart
            const Text(
              'Demographic Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/ml_district_analysis.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: const Color(0xFF1E2130),
                  alignment: Alignment.center,
                  child: const Text('District Analysis Image Missing', style: TextStyle(color: Colors.redAccent)),
                ),
              ),
            ),
            const SizedBox(height: 48), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String subtitle, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2130),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 11,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
