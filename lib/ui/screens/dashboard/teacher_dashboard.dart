import 'package:flutter/material.dart';
import 'dart:ui'; // Required for ImageFilter
import '../../../../localization/app_localizations.dart';
import '../../../utils/permission_manager.dart';
import '../../widgets/cropped_logo.dart';
import 'tabs/home_task_tab.dart'; // Import the new tab
import '../children/children_tab.dart'; // Import Child Tab API
import '../assessment/start_assessment_tab.dart'; // Import Start Tab API
import 'tabs/intervene_tab.dart'; // Import Intervene Tab
import 'tabs/insights_tab.dart'; // Import Insights Tab
import '../../widgets/voice_assistant_widget.dart';
import '../../../services/responsive_dashboard.dart'; // Import responsive utilities

class DashboardScreen extends StatefulWidget {
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
    final t = AppLocalizations.of(context);
    final responsive = ResponsiveDashboard(context);

    return Scaffold(
      key: _scaffoldKey,
      drawer: responsive.isMobile ? _buildDrawer(t) : null,
      body: Stack(
        children: [
          // Background with blur
          Positioned.fill(
            child: Stack(
              children: [
                Opacity(
                  opacity: 0.15,
                  child: Image.asset(
                    'assets/images/bg1.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ],
            ),
          ),

          // Main content
          Positioned.fill(
            child: Column(
              children: [
                _buildTopHeader(t, responsive),
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
          _buildSidebarItem(Icons.home, 0, responsive),
          _buildSidebarItem(Icons.child_care, 1, responsive),
          _buildSidebarItem(Icons.add_circle, 2, responsive),
          _buildSidebarItem(Icons.medical_services, 3, responsive),
          _buildSidebarItem(Icons.bar_chart, 4, responsive),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, int index, ResponsiveDashboard responsive) {
    final isActive = _selectedIndex == index;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: responsive.getSpacing(12)),
      child: Tooltip(
        message: ['Home', 'Children', 'Start', 'Intervene', 'Insights'][index],
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
            else
              Expanded(
                child: Center(
                  child: Text(
                    "Feature under development",
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
                  'Anganwadi Teacher',
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
            title: const Text('Profile'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => Navigator.pop(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => Navigator.pop(context),
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
    final t = AppLocalizations.of(context);

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
        left: responsive.getSpacing(8),
        right: responsive.contentPadding.right,
        top: MediaQuery.of(context).viewPadding.top + responsive.getSpacing(5),
        bottom: responsive.getSpacing(5),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (responsive.isMobile)
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.teal),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  "ShishuSuraksha AI",
                  style: TextStyle(
                    fontSize: responsive.getFontSize(16),
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: responsive.getSpacing(8)),
              const CroppedLogo(width: 36),
            ],
          ),
        ],
      ),
    );
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
            t.goodMorning,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: responsive.getFontSize(24),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: responsive.getSpacing(8)),
          Text(
            t.startMonitoring,
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
