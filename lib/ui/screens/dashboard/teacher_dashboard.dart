import 'package:flutter/material.dart';
import 'package:shishu_suraksha/app/theme/colors.dart'; // Import AppColors
import 'dart:ui'; // Required for ImageFilter
import 'package:shishu_suraksha/l10n/generated/app_localizations.dart';
import '../../../utils/permission_manager.dart';
import '../../widgets/cropped_logo.dart';
import 'tabs/home_task_tab.dart'; // Import the new tab
import '../children/children_tab.dart'; // Import Child Tab API
import '../assessment/start_assessment_tab.dart'; // Import Start Tab API
import 'tabs/intervene_tab.dart'; // Import Intervene Tab
import 'tabs/insights_tab.dart'; // Import Insights Tab
import '../../widgets/voice_assistant_widget.dart';
import '../../../services/responsive_dashboard.dart'; // Import responsive utilities
import '../../../modules/health_monitoring/screens/health_dashboard_screen.dart';
import '../../../modules/classroom_monitoring/screens/classroom_dashboard_screen.dart';
import '../../../modules/growth_tracking/screens/growth_monitoring_screen.dart';
import '../../../modules/ai_alerts/screens/alerts_dashboard_screen.dart';
import '../../../features/admin/admin_dashboard.dart'; // Updated path
import '../../../modules/admin_dashboard/screens/admin_schools_screen.dart';
import '../../../modules/admin_dashboard/screens/admin_reports_screen.dart';
import '../../../../main.dart'; // For language switching
import '../../../../core/services/offline_data_service.dart';

class DashboardScreen extends StatefulWidget {
  final String role; // 'Admin' or 'Anganwadi Teacher'

  const DashboardScreen({Key? key, this.role = 'Anganwadi Teacher'}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _activePanel = 'none';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        PermissionManager.requestInitialPermissions(context);
      }
    });
  }

  void _togglePanel(String panelName) {
    setState(() {
      if (_activePanel == panelName) {
        _activePanel = 'none';
      } else {
        _activePanel = panelName;
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final responsive = ResponsiveDashboard(context);

    // If Admin, different Drawer/Sidebar logic
    return Scaffold(
      key: _scaffoldKey,
      drawer: responsive.isMobile ? _buildDrawer(t) : null,
      body: Stack(
        children: [
          // Minimalist Background (Solid Color from Theme)
          Positioned.fill(
              child: Container(color: AppColors.background),
          ),

          // Main content
          Positioned.fill(
            child: AnimatedBuilder(
              animation: OfflineDataService(),
              builder: (context, child) {
                final isOffline = OfflineDataService().isOfflineMode;
                return Column(
                  children: [
                    _buildTopHeader(t, responsive),
                    if (isOffline)
                      Container(
                        width: double.infinity,
                        color: Colors.orangeAccent,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          t.offlineModeActive,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (responsive.isTablet || responsive.isDesktop)
                            _buildSidebar(t, responsive),
                          Expanded(
                            child: _buildBodyContent(t, responsive),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
            ),
          ),

          // Animated panels
          _buildChatbotPanel(t, responsive),
          _buildHelplinePanel(t, responsive),
          _buildFABs(responsive),
        ],
      ),
      bottomNavigationBar: responsive.isMobile
          ? _buildBottomNav()
          : null,
    );
  }

  /// Build sidebar for tablet/desktop
  Widget _buildSidebar(AppLocalizations t, ResponsiveDashboard responsive) {
    return Container(
      width: responsive.sidebarWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: responsive.getSpacing(20)),
          if (widget.role == 'Admin') ...[
             _buildSidebarItem(Icons.admin_panel_settings, t.adminPanel, 0),
             // Add more Admin sidebar items here if needed
          ] else ...[
            _buildSidebarItem(Icons.home, t.home, 0),
            _buildSidebarItem(Icons.child_care, t.children, 1),
            _buildSidebarItem(Icons.add_circle, t.start, 2),
            _buildSidebarItem(Icons.medical_services, t.intervene, 3),
            _buildSidebarItem(Icons.analytics, t.reports, 4),
            const Divider(color: Colors.white24),
            _buildSidebarItem(Icons.monitor_heart, t.health, 5), // Health
            _buildSidebarItem(Icons.school, t.classroom, 6), // Classroom
            _buildSidebarItem(Icons.show_chart, t.growth, 7), // Growth
            _buildSidebarItem(Icons.warning, t.alerts, 8), // Alerts
            const Divider(color: Colors.white24),
            // _buildSidebarItem(Icons.admin_panel_settings, t.adminPanel, 9), // Hiding Admin link from Teacher view for clean separation? Or keep as toggle? 
            // Keeping it for now if they switch roles, but for this task let's focus on role-based separation
          ],
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String label, int index) {
    // responsive is not available here unless passed or obtained from context
    // But responsive was used in padding: responsive.getSpacing(12)
    // We need to get responsive again or pass it. 
    // The original method used 'responsive' from the class state or passed in?
    // In _buildSidebar, responsive is passed.
    // In _buildSidebarItem, it is NOT passed in the new signature.
    // We need to get it from context.
    final responsive = ResponsiveDashboard(context);
    final isActive = _selectedIndex == index;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: responsive.getSpacing(12)),
      child: Tooltip(
        message: label,
        child: IconButton(
          icon: Icon(icon, size: 28),
          color: isActive ? Colors.teal : Colors.grey,
          onPressed: () => setState(() => _selectedIndex = index),
          disabledColor: Colors.grey[300],
        ),
      ),
    );
  }



  /// Build body content
  Widget _buildBodyContent(AppLocalizations t, ResponsiveDashboard responsive) {
    // Admin Navigation Logic
    if (widget.role == 'Admin') {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.isMobile ? 0 : responsive.contentPadding.left,
          vertical: responsive.contentPadding.top,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_selectedIndex == 0)
              const Expanded(child: AdminDashboardContent())
            else if (_selectedIndex == 1)
              const Expanded(child: AdminSchoolsScreen()) // Schools Tab
            else if (_selectedIndex == 2)
              const Expanded(child: AlertsDashboardScreen()) // Reuse Alerts Screen for now
            else if (_selectedIndex == 3)
              const Expanded(child: AdminReportsScreen()) // Reports Tab
            else
               const Expanded(child: AdminDashboardContent())
          ],
        ),
      );
    }

    // Teacher Navigation Logic
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.isMobile ? 0 : responsive.contentPadding.left,
        vertical: responsive.contentPadding.top,
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_selectedIndex == 0) ...[
              _buildGreeting(t, responsive),
              const SizedBox(height: 16),
              Expanded(child: HomeTaskTab(onTabChange: _onItemTapped)),
            ] else if (_selectedIndex == 1)
              const Expanded(child: ChildrenTab())
            else if (_selectedIndex == 2)
              const Expanded(child: StartAssessmentTab())
            else if (_selectedIndex == 3)
              const Expanded(child: InterveneTab())
            else if (_selectedIndex == 4)
              const Expanded(child: InsightsTab())
            else if (_selectedIndex == 5)
              const Expanded(child: HealthDashboardScreen(initialChildId: "demo_01", initialChildName: "Rahul Kumar"))
            else if (_selectedIndex == 6)
              const Expanded(child: ClassroomDashboardScreen())
            else if (_selectedIndex == 7)
              const Expanded(child: GrowthMonitoringScreen(childId: "demo_01", childName: "Rahul Kumar"))
            else if (_selectedIndex == 8)
              const Expanded(child: AlertsDashboardScreen())
            else if (_selectedIndex == 9)
               const Expanded(child: AdminDashboardContent())
            else
              Expanded(
                child: Center(
                  child: Text(
                    t.featureUnderDevelopment,
                    style: TextStyle(
                      fontSize: responsive.getFontSize(16),
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
          ],
        ),
    );
  }

  Widget _buildDrawer(AppLocalizations t) {
    final responsive = ResponsiveDashboard(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.teal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 30,
                  child: Icon(Icons.person, size: 40, color: Colors.teal),
                ),
                SizedBox(height: responsive.getSpacing(10)),
                Text(
                  widget.role == 'Admin' ? t.admin : t.anganwadiTeacher, // Dynamic Role
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsive.getFontSize(18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'teacher@anganwadi.com',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: responsive.getFontSize(14),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text(t.home),
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(t.profile),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(t.settings),
            onTap: () => Navigator.pop(context),
          ),
          const Divider(),
          AnimatedBuilder(
            animation: OfflineDataService(),
            builder: (context, child) {
              return SwitchListTile(
                secondary: const Icon(Icons.wifi_off),
                title: Text(t.offlineMode),
                value: OfflineDataService().isOfflineMode,
                onChanged: (bool value) {
                  OfflineDataService().setOfflineMode(value);
                },
                activeColor: Colors.teal,
              );
            }
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(t.logout),
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(context, "/auth", (route) => false);
            },
          ),
        ],
      ),
    );
  }

  /// Build chatbot panel
  Widget _buildChatbotPanel(AppLocalizations t, ResponsiveDashboard responsive) {
    if (_activePanel != 'chatbot') return const SizedBox();

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      bottom: responsive.fabBottom + 70,
      right: responsive.fabRight,
      width: responsive.panelWidth,
      height: responsive.panelHeight,
      child: Hero(
        tag: "chatbot_panel",
        child: VoiceAssistantWidget(
          onClose: () => _togglePanel('none'),
        ),
      ),
    );
  }

  /// Build helpline panel
  Widget _buildHelplinePanel(AppLocalizations t, ResponsiveDashboard responsive) {
    if (_activePanel != 'helpline') return const SizedBox();

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      bottom: responsive.fabBottom,
      right: responsive.fabRight,
      width: responsive.panelWidth,
      height: responsive.panelHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: responsive.contentPadding,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "🆘 ${t.helplineTitle}",
                      style: TextStyle(
                        fontSize: responsive.getFontSize(18),
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => _togglePanel('none'),
                      iconSize: responsive.getFontSize(20),
                    )
                  ],
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildHelplineItem(Icons.call, t.callSupervisor, Colors.blue, responsive),
                        _buildHelplineItem(Icons.email, t.emailSupport, Colors.orange, responsive),
                        _buildHelplineItem(Icons.chat, t.whatsappSupport, Colors.green, responsive),
                        _buildHelplineItem(Icons.local_hospital, t.nearestPhc, Colors.red, responsive),
                        _buildHelplineItem(Icons.emergency, t.emergencyContact, Colors.red[900]!, responsive),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build FABs
  Widget _buildFABs(ResponsiveDashboard responsive) {
    return Stack(
      children: [
        if (_activePanel == 'none') ...[
          // Chatbot FAB
          Positioned(
            bottom: responsive.fabBottom + 70,
            right: responsive.fabRight,
            child: FloatingActionButton(
              heroTag: "chatbot_fab",
              onPressed: () => _togglePanel('chatbot'),
              backgroundColor: const Color(0xFF00796B),
              child: const Icon(Icons.smart_toy, size: 24, color: Colors.white),
            ),
          ),
          // Helpline FAB
          Positioned(
            bottom: responsive.fabBottom,
            right: responsive.fabRight,
            child: FloatingActionButton(
              heroTag: "helpline_fab",
              onPressed: () => _togglePanel('helpline'),
              backgroundColor: const Color(0xFFE53935),
              child: const Icon(Icons.phone, size: 24, color: Colors.white),
            ),
          ),
        ],
      ],
    );
  }

  /// Build bottom navigation for mobile
  BottomNavigationBar _buildBottomNav() {
    final t = AppLocalizations.of(context)!;
    
    if (widget.role == 'Admin') {
       return BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.dashboard), label: t.adminPanel),
          BottomNavigationBarItem(icon: const Icon(Icons.school), label: t.totalSchools), // Using 'Total Schools' as label for Schools tab
          BottomNavigationBarItem(icon: const Icon(Icons.warning), label: t.alerts),
          BottomNavigationBarItem(icon: const Icon(Icons.analytics), label: t.reports),
        ],
      );
    }

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.teal,
      unselectedItemColor: Colors.grey,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: [
        BottomNavigationBarItem(icon: const Icon(Icons.home), label: t.home),
        BottomNavigationBarItem(icon: const Icon(Icons.child_care), label: t.children),
        BottomNavigationBarItem(icon: const Icon(Icons.add_circle), label: t.start),
        BottomNavigationBarItem(icon: const Icon(Icons.medical_services), label: t.intervene),
        BottomNavigationBarItem(icon: const Icon(Icons.bar_chart), label: t.insights),
      ],
    );
  }

  Widget _buildChatMessage(String text, bool isUser, ResponsiveDashboard responsive) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: responsive.getSpacing(4)),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.getSpacing(12),
            vertical: responsive.getSpacing(8),
          ),
          decoration: BoxDecoration(
            color: isUser
                ? Colors.teal.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            style: TextStyle(fontSize: responsive.getFontSize(12)),
          ),
        ),
      ),
    );
  }

  Widget _buildHelplineItem(
    IconData icon,
    String text,
    Color color,
    ResponsiveDashboard responsive,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: responsive.getSpacing(8)),
      child: InkWell(
        onTap: () {},
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(responsive.getSpacing(8)),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: responsive.getFontSize(22)),
            ),
            SizedBox(width: responsive.getSpacing(12)),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: responsive.getFontSize(14),
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: responsive.getFontSize(14),
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader(AppLocalizations t, ResponsiveDashboard responsive) {
    return Container(
      padding: EdgeInsets.only(
        left: responsive.contentPadding.left,
        right: responsive.contentPadding.right,
        top: MediaQuery.of(context).viewPadding.top + responsive.getSpacing(10),
        bottom: responsive.getSpacing(10),
      ),
      color: AppColors.surface, // Clean white background
      child: Row(
        children: [
          // Left: Menu (Mobile)
          if (responsive.isMobile)
            IconButton(
              icon: const Icon(Icons.menu, color: AppColors.textPrimary),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          
          if (responsive.isMobile) SizedBox(width: responsive.getSpacing(8)),

          // Left/Center: Language Toggle
          _buildLanguageToggle(context, responsive),

          const Spacer(),

          // Right: Logo + Title
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      "ShishuSuraksha",
                      style: TextStyle(
                        fontSize: responsive.getFontSize(20),
                        fontWeight: FontWeight.w800,
                        color: Colors.blueGrey[900],
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
                Text(
                  "AI Powered",
                  style: TextStyle(
                    fontSize: responsive.getFontSize(10),
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: responsive.getSpacing(8)),
          CroppedLogo(width: responsive.isMobile ? 48 : 64),
        ],
      ),
    );
  }

  Widget _buildLanguageToggle(BuildContext context, ResponsiveDashboard responsive) {
    final currentLocale = Localizations.localeOf(context).languageCode;
    final isEnglish = currentLocale == 'en';
    
    return InkWell(
      onTap: () {
        final newLocale = isEnglish ? const Locale('te') : const Locale('en');
        MyApp.setLocale(context, newLocale);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: responsive.isMobile 
            ? const EdgeInsets.symmetric(horizontal: 10, vertical: 4)
            : EdgeInsets.symmetric(horizontal: responsive.getSpacing(12), vertical: responsive.getSpacing(6)),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Text(
          isEnglish ? "తెలుగు" : "English", 
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: responsive.isMobile ? 12 : responsive.getFontSize(14),
          ),
        ),
      ),
    );
  }

  String _getLocalizedGreeting(AppLocalizations t) {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return t.goodMorning;
    } else if (hour < 17) {
      return t.goodAfternoon;
    } else {
      return t.goodEvening;
    }
  }

  Widget _buildGreeting(AppLocalizations t, ResponsiveDashboard responsive) {
    return Container(
      padding: responsive.cardPadding,
      margin: responsive.contentPadding,
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            t.welcome,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: responsive.getFontSize(14),
              color: Colors.teal,
            ),
          ),
          SizedBox(height: responsive.getSpacing(4)),
          Text(
            _getLocalizedGreeting(t),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: responsive.getFontSize(24),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: responsive.getSpacing(8)),

          Text(
            t.startMonitoringSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: responsive.getFontSize(14),
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
