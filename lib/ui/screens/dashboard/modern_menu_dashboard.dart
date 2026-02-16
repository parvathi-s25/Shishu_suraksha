import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shishu_suraksha/app/theme/colors.dart';
import 'package:shishu_suraksha/localization/app_localizations.dart';
import 'package:shishu_suraksha/ui/widgets/menu_card_widget.dart';
import 'package:shishu_suraksha/ui/widgets/neumorphic_menu_card.dart';
import 'package:shishu_suraksha/ui/widgets/glass_container.dart';
import 'package:shishu_suraksha/ui/widgets/calendar_widget.dart';
import 'package:shishu_suraksha/ui/widgets/health_indicator_widget.dart';
import 'package:shishu_suraksha/ui/widgets/quick_stats_card.dart';
import 'package:shishu_suraksha/ui/screens/screening/visual/visual_screening_screen.dart';
import 'package:shishu_suraksha/ui/screens/screening/audio/audio_screening_screen.dart';
import 'package:shishu_suraksha/ui/screens/screening/thermal/thermal_screening_screen.dart';
import 'package:shishu_suraksha/ui/screens/children/children_tab.dart';
import 'package:shishu_suraksha/ui/screens/reports/reports_tab.dart';
import 'package:shishu_suraksha/ui/screens/calendar/calendar_screen.dart';
import 'package:shishu_suraksha/ui/screens/ai_assistant/ai_assistant_screen.dart';
import 'package:shishu_suraksha/ui/screens/student/ocr_data_entry_screen.dart';
import '../screening/injury/injury_screening_screen.dart';
import '../screening/symptoms/symptom_screening_screen.dart';
import '../assessment/start_assessment_tab.dart'; // Added import

import 'package:shishu_suraksha/ui/widgets/custom_bottom_nav_bar.dart';
import '../../../core/utils/voice_command_manager.dart';
import 'package:shishu_suraksha/ui/screens/tasks/tasks_screen.dart';
import 'package:shishu_suraksha/ui/screens/alerts/alerts_screen.dart';
import 'package:shishu_suraksha/ui/screens/profile/profile_screen.dart';
import 'package:shishu_suraksha/ui/screens/help/help_center_screen.dart';

class ModernMenuDashboard extends StatefulWidget {
  const ModernMenuDashboard({super.key});

  @override
  State<ModernMenuDashboard> createState() => _ModernMenuDashboardState();
}

class _ModernMenuDashboardState extends State<ModernMenuDashboard> {
  int _currentIndex = 0;
  final VoiceCommandManager _voiceManager = VoiceCommandManager();
  bool _isListening = false;

  void _toggleListening() {
    if (_isListening) {
      _voiceManager.stop();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      _voiceManager.listen(
        context,
        onResult: (text) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text("Heard: $text", style: const TextStyle(fontWeight: FontWeight.bold))),
          );
           if (mounted) setState(() => _isListening = false);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF00A981)), // Teal menu icon
          onPressed: () {},
        ),
        title: const Text(
          'ShishuSuraksha AI',
          style: TextStyle(
            color: Color(0xFF00A981),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const CircleAvatar(
              radius: 14,
              backgroundImage: AssetImage('assets/images/logo.png'), 
              backgroundColor: Colors.transparent,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomeContent(),
            const ChildrenTab(),
            const StartAssessmentTab(),
            const Center(child: Text("Intervene - Coming Soon")),
            const ReportsTab(),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
      floatingActionButton: _currentIndex == 0 ? FloatingActionButton(
        onPressed: _toggleListening,
        backgroundColor: _isListening ? Colors.red : const Color(0xFF00A981),
        elevation: 4,
        child: Icon(_isListening ? Icons.mic : Icons.mic_none, color: Colors.white),
      ) : null,
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeBanner(),
          const SizedBox(height: 24),
          _buildMonthlyPlanner(),
          const SizedBox(height: 24),
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 12),
          _buildMenuGrid(context),
          const SizedBox(height: 24),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1), // Light teal/cyan background
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text(
            'Welcome!',
            style: TextStyle(
              color: Color(0xFF00A981),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getGreeting(AppLocalizations.of(context)),
            style: const TextStyle(
              color: Color(0xFF2D3142),
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start monitoring child health with these quick actions.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF2D3142).withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyPlanner() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Text(
              'Monthly Planner',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00A981), // Teal color
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFF00A981)),
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 12),
        const CalendarWidget(),
      ],
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        'label': 'Scan Student',
        'icon': Icons.document_scanner_rounded,
        'color': const Color(0xFFFF5722), // Deep Orange
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OCRDataEntryScreen()),
        ),
      },
      {
        'label': 'Visual',
        'icon': Icons.videocam_rounded,
        'color': const Color(0xFF4A90E2),
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const VisualScreeningScreen()),
        ),
      },
      {
        'label': 'Audio',
        'icon': Icons.mic_rounded,
        'color': const Color(0xFFFF6B6B),
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AudioScreeningScreen()),
        ),
      },
      {
        'label': 'Thermal',
        'icon': Icons.thermostat_rounded,
        'color': const Color(0xFFFF9500),
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ThermalScreeningScreen()),
        ),
      },
      {
        'label': 'Injury',
        'icon': Icons.healing_rounded,
        'color': const Color(0xFFE91E63),
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const InjuryScreeningScreen()),
        ),
      },
      {
        'label': 'Symptoms',
        'icon': Icons.sick_rounded,
        'color': const Color(0xFF9C27B0),
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SymptomScreeningScreen()),
        ),
      },
      {
        'label': 'Children',
        'icon': Icons.people_rounded,
        'color': const Color(0xFF50C878),
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChildrenTab()),
        ),
      },
      {
        'label': 'Reports',
        'icon': Icons.analytics_rounded,
        'color': const Color(0xFF9D4EDD),
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ReportsTab()),
        ),
      },
      {
        'label': 'AI Chat',
        'icon': Icons.psychology_rounded,
        'color': const Color(0xFFEC4899),
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AiAssistantScreen()),
        ),
      },
      {
        'label': 'Calendar',
        'icon': Icons.calendar_month_rounded,
        'color': const Color(0xFF3F51B5),
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CalendarScreen()),
        ),
      },
      {
        'label': 'Tasks',
        'icon': Icons.task_alt,
        'color': const Color(0xFF607D8B),
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TasksScreen()),
        ),
      },
      {
        'label': 'Alerts',
        'icon': Icons.notifications_active_rounded,
        'color': const Color(0xFFD32F2F),
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AlertsScreen()),
        ),
      },
      {
        'label': 'Profile',
        'icon': Icons.person_rounded,
        'color': const Color(0xFF795548),
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        ),
      },
      {
        'label': 'Help',
        'icon': Icons.help_outline_rounded,
        'color': const Color(0xFF00BCD4),
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HelpCenterScreen()),
        ),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 columns for larger neumorphic cards
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.1, 
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        // Example logic: Highlight the 'Reports' item or the first item to show active state
        final bool isSelected = item['label'] == 'Reports'; 
        
        return NeumorphicMenuCard(
          icon: item['icon'],
          label: item['label'],
          onTap: item['onTap'],
          isSelected: isSelected,
          accentColor: item['color'], // Using the item color as accent for the selected state icon
        );
      },
    );
  }


  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 16),
          _buildActivityItem(
            icon: Icons.videocam,
            color: const Color(0xFF4A90E2),
            title: 'Visual Screening Completed',
            subtitle: 'Ravi Kumar - 2 hours ago',
            status: HealthStatus.excellent,
          ),
          const Divider(height: 24),
          _buildActivityItem(
            icon: Icons.mic,
            color: const Color(0xFFFF6B6B),
            title: 'Audio Screening Completed',
            subtitle: 'Priya Sharma - 4 hours ago',
            status: HealthStatus.good,
          ),
          const Divider(height: 24),
          _buildActivityItem(
            icon: Icons.thermostat,
            color: const Color(0xFFFF9500),
            title: 'Thermal Screening Alert',
            subtitle: 'Amit Patel - 5 hours ago',
            status: HealthStatus.needsAttention,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required HealthStatus status,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3142),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        HealthIndicatorWidget(
          status: status,
          label: '',
          showBadge: true,
        ),
      ],
    );
  }
  String _getGreeting(AppLocalizations t) {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return t.goodMorning;
    } else if (hour < 17) {
      return t.goodAfternoon;
    } else {
      return t.goodEvening;
    }
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
