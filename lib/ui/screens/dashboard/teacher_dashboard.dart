import 'package:flutter/material.dart';
import 'dart:ui'; // Required for ImageFilter
import '../../../../localization/app_localizations.dart';
import '../../../utils/permission_manager.dart';
import '../../widgets/cropped_logo.dart';
import 'tabs/home_task_tab.dart'; // Import the new tab
import 'tabs/child_tab.dart'; // Import Child Tab
import 'tabs/start_tab.dart'; // Import Start Tab
import 'tabs/intervene_tab.dart'; // Import Intervene Tab
import 'tabs/insights_tab.dart'; // Import Insights Tab

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _activePanel = 'none';
  int _selectedIndex = 0; // NEW: Track active tab

  @override
  void initState() {
    super.initState();
    // Trigger permission requests after the first frame to ensure context is valid
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Small delay to ensure smooth transition and context readiness
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
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(t),
      body: Stack(
        children: [
          // Background Image (bg1.png) with 15% Opacity and Blur
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
                ClipRect( // Clip the blur to the container
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                    child: Container(
                      color: Colors.transparent, 
                    ),
                  ),
                ),
              ],
            ),
          ),

          // NEW: Main Content Layout
          Positioned.fill(
            child: Column(
              children: [
                _buildTopHeader(t),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Replaced sidebar with SizedBox to maintain exact layout spacing
                      // as per strict requirement "DO NOT shift any existing elements left or right"
                      const SizedBox(width: 70),
                      Expanded(
                        child: _buildBodyContent(t),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 1. Chatbot Panel (Bottom-Right)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: 100, // Above FABs
            right: 20,
            width: _activePanel == 'chatbot' ? size.width * 0.4 : 0,
            height: _activePanel == 'chatbot' ? size.height * 0.65 : 0,
            child: _activePanel == 'chatbot'
                ? _buildChatbotPanel(t) 
                : const SizedBox(),
          ),

          // 2. Helpline Panel (Bottom-Right)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: 100, // Above FABs
            right: 20,
            width: _activePanel == 'helpline' ? size.width * 0.4 : 0,
            height: _activePanel == 'helpline' ? size.height * 0.55 : 0,
            child: _activePanel == 'helpline'
                ? _buildHelplinePanel(t) 
                : const SizedBox(),
          ),

          // Chatbot FAB (Top)
          Positioned(
            bottom: 120, // Moved down
            right: 20,
            child: SizedBox(
              width: 58,
              height: 58,
              child: FloatingActionButton(
                heroTag: "chatbot_fab",
                onPressed: () => _togglePanel('chatbot'),
                backgroundColor: const Color(0xFF00796B), // Teal
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                elevation: 4,
                child: const Icon(Icons.smart_toy, size: 28, color: Colors.white),
              ),
            ),
          ),

          // Helpline FAB (Bottom)
          Positioned(
            bottom: 50, // Moved down
            right: 20,
            child: SizedBox(
              width: 58,
              height: 58,
              child: FloatingActionButton(
                heroTag: "helpline_fab", // Dial icon requested
                onPressed: () => _togglePanel('helpline'),
                backgroundColor: const Color(0xFFE53935), // Red/Orange
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                elevation: 4,
                child: const Icon(Icons.phone, size: 28, color: Colors.white),
              ),
            ),
          ),


        ],
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex, // Bind state
        onTap: _onItemTapped, // Bind action
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: t.home),
          BottomNavigationBarItem(icon: const Icon(Icons.child_care), label: t.children),
          BottomNavigationBarItem(icon: const Icon(Icons.add_circle, size: 40, color: Colors.teal), label: t.start),
          BottomNavigationBarItem(icon: const Icon(Icons.medical_services), label: t.intervene),
          BottomNavigationBarItem(icon: const Icon(Icons.bar_chart), label: t.insights),
        ],
      ),
    );
  }

  Widget _buildBodyContent(AppLocalizations t) {
    // If Home Tab (Index 0), show Task List
    if (_selectedIndex == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildGreeting(t),
          const Expanded(child: HomeTaskTab()),
        ],
      );
    } else if (_selectedIndex == 1) {
      // Child Tab
      return const ChildTab();
    } else if (_selectedIndex == 2) {
      // Start Tab (Assessment Flow)
      return const StartTab();
    } else if (_selectedIndex == 3) {
      // Intervene Tab (Alerts Module)
      return const InterveneTab();
    }
    
    // Placeholder for other tabs (Index 4)
    else if (_selectedIndex == 4) {
      // Insights Tab (Analytics Dashboard)
      return const InsightsTab();
    }
    
    return const Center(child: Text("Feature under development"));
  }

  Widget _buildDrawer(AppLocalizations t) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.teal,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 30,
                  child: Icon(Icons.person, size: 40, color: Colors.teal),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Anganwadi Teacher',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'teacher@anganwadi.com', // Placeholder e-mail
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
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
            title: const Text('Profile'), // Add localization key if available
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'), // Add localization key if available
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChatbotPanel(AppLocalizations t) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(
                    "🤖 ${t.chatbotTitle}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => _togglePanel('none'),
                  )
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  children: [
                    _buildChatMessage("Hello! how can I help?", false),
                    _buildChatMessage("Show me malnutrition data.", true),
                    _buildChatMessage("Here is the updated list...", false),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: t.chatbotPlaceholder,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        isDense: true,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.teal),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelplinePanel(AppLocalizations t) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(
                    "🆘 ${t.helplineTitle}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => _togglePanel('none'),
                  )
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHelplineItem(Icons.call, t.callSupervisor, Colors.blue),
                      _buildHelplineItem(Icons.email, t.emailSupport, Colors.orange),
                      _buildHelplineItem(Icons.chat, t.whatsappSupport, Colors.green),
                      _buildHelplineItem(Icons.local_hospital, t.nearestPhc, Colors.red),
                      _buildHelplineItem(Icons.emergency, t.emergencyContact, Colors.red[900]!),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatMessage(String text, bool isUser) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isUser ? Colors.teal.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(text, style: const TextStyle(fontSize: 12)),
        ),
      ),
    );
  }

  Widget _buildHelplineItem(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8), // Increased spacing
      child: InkWell(
        onTap: () {
          // Placeholder for action
        },
        child: Row(
          children: [
            Container( // Colored Icon BG
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text, 
                style: const TextStyle(
                  fontWeight: FontWeight.w600, 
                  fontSize: 14,
                  color: Colors.black87
                )
              )
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
  Widget _buildTopHeader(AppLocalizations t) {
    return Container(
      padding: EdgeInsets.only(
        left: 8, 
        right: 16, 
        top: MediaQuery.of(context).viewPadding.top + 5,
        bottom: 5
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          // Flatter shadow as requested
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 2, offset: const Offset(0, 1)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Hamburger Menu
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.teal),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),

          const Spacer(),

          // Right: Logo and Text
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  "ShishuSuraksha AI",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              const CroppedLogo(width: 36), // Slightly smaller, clearly readable
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting(AppLocalizations t) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
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
            style: const TextStyle(fontSize: 14, color: Colors.teal),
          ),
          const SizedBox(height: 4),
          Text(
            t.goodMorning,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            t.startMonitoring,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
