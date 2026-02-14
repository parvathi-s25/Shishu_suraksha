import 'package:flutter/material.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../services/responsive_dashboard.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/data_service.dart';
import '../../student/ocr_data_entry_screen.dart';
import '../../tasks/tasks_screen.dart';
import '../../alerts/alerts_screen.dart';
import '../../profile/profile_screen.dart';
import '../../help/help_center_screen.dart';
import '../../student/quick_add_screen.dart';

class HomeTaskTab extends StatefulWidget {
  final Function(int) onTabChange;

  const HomeTaskTab({Key? key, required this.onTabChange}) : super(key: key);

  @override
  _HomeTaskTabState createState() => _HomeTaskTabState();
}

class _HomeTaskTabState extends State<HomeTaskTab> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveDashboard(context);
    // final t = AppLocalizations.of(context); // Localization

    return SingleChildScrollView(
      padding: responsive.contentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, "Overview", responsive),
          SizedBox(height: responsive.getSpacing(16)),
          
          // Top Summary Grid
          StreamBuilder<int>(
            stream: DataService().childCountStream,
            initialData: 42,
            builder: (context, snapshot) {
              return GridView.count(
                crossAxisCount: responsive.isMobile ? 2 : 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: responsive.getSpacing(16),
                crossAxisSpacing: responsive.getSpacing(16),
                childAspectRatio: responsive.isMobile ? 1.3 : 1.5,
                children: [
                  _buildSummaryCard(
                    icon: Icons.child_care,
                    color: Colors.purple,
                    title: "Children",
                    count: snapshot.data.toString(),
                    onTap: () => widget.onTabChange(1),
                    responsive: responsive,
                  ),
                  StreamBuilder<int>(
                    stream: DataService().assessmentCountStream,
                    initialData: 5,
                    builder: (context, snap) => _buildSummaryCard(
                      icon: Icons.assessment,
                      color: Colors.orange,
                      title: "Assessments",
                      count: snap.data.toString(),
                      label: "Pending",
                      onTap: () => widget.onTabChange(2),
                      responsive: responsive,
                    ),
                  ),
                  StreamBuilder<int>(
                    stream: DataService().taskCountStream,
                    initialData: 12,
                    builder: (context, snap) => _buildSummaryCard(
                      icon: Icons.medical_services,
                      color: Colors.blue,
                      title: "Interventions",
                      count: snap.data.toString(),
                      label: "Active",
                      onTap: () => widget.onTabChange(3),
                      responsive: responsive,
                    ),
                  ),
                  StreamBuilder<int>(
                    stream: DataService().highRiskCountStream, // Changed to High Risk
                    initialData: 3,
                    builder: (context, snap) => _buildSummaryCard(
                      icon: Icons.flag, // Red Flag Icon
                      color: Colors.red,
                      title: "Red Flags",
                      count: snap.data.toString(),
                      label: "High Risk",
                      onTap: () => widget.onTabChange(4),
                      responsive: responsive,
                    ),
                  ),
                ],
              );
            },
          ),

          SizedBox(height: responsive.getSpacing(32)),
          
          // --- CALENDAR SECTION (NEW) ---
          _buildSectionTitle(context, "Schedule", responsive),
          SizedBox(height: responsive.getSpacing(16)),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Month',
                  CalendarFormat.week: 'Week',
                },
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  }
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() => _calendarFormat = format);
                  }
                },
                onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Colors.teal,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: Colors.indigo,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: true,
                  titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          
          SizedBox(height: responsive.getSpacing(32)),

          // --- LAST VISIT REMINDER (NEW) ---
          StreamBuilder<int>(
            stream: DataService().overdueCountStream,
            initialData: 5,
            builder: (context, snap) {
              if (snap.data == 0) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.history, color: Colors.orange, size: 30),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${snap.data} children not seen in >30 days",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const Text(
                            "Schedule a home visit soon.",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                       onPressed: () {}, // Navigate to filtered list (future)
                       child: const Text("VIEW", style: TextStyle(fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              );
            },
          ),

          SizedBox(height: responsive.getSpacing(32)),
          _buildSectionTitle(context, "Quick Actions", responsive),
          SizedBox(height: responsive.getSpacing(16)),

          // Secondary Action Grid
          GridView.count(
            crossAxisCount: responsive.isMobile ? 2 : 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: responsive.getSpacing(16),
            crossAxisSpacing: responsive.getSpacing(16),
            childAspectRatio: 1.2,
            children: [
              _buildActionCard(
                icon: Icons.task_alt,
                title: "Tasks",
                 onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const TasksScreen())),
                responsive: responsive,
              ),
               _buildActionCard(
                icon: Icons.notifications_none,
                title: "Alerts",
                badgeCount: 3,
                 onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AlertsScreen())),
                responsive: responsive,
              ),
               _buildActionCard(
                icon: Icons.person_outline,
                title: "Profile",
                 onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ProfileScreen())),
                responsive: responsive,
              ),
               _buildActionCard(
                icon: Icons.help_outline,
                title: "Help Center",
                 onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const HelpCenterScreen())),
                responsive: responsive,
              ),
               _buildActionCard(
                icon: Icons.add_circle_outline,
                title: "Quick Add",
                color: Colors.teal,
                 onTap: () {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                      builder: (context) => Container(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("Select Mode", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 24),
                            ListTile(
                              leading: const CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.document_scanner, color: Colors.white)),
                              title: const Text("Scan Document", style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: const Text("Auto-fill details from ID card"),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(context, MaterialPageRoute(builder: (c) => const OCRDataEntryScreen()));
                              },
                            ),
                            const Divider(),
                            ListTile(
                              leading: const CircleAvatar(backgroundColor: Colors.blueAccent, child: Icon(Icons.flash_on, color: Colors.white)),
                              title: const Text("Quick Add (Ultra Fast)", style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: const Text("Enter Name, Age, Weight only"),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(context, MaterialPageRoute(builder: (c) => const QuickAddScreen()));
                              },
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    );
                 },
                responsive: responsive,
              ),
            ],
          ),
           SizedBox(height: responsive.getSpacing(80)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, ResponsiveDashboard responsive) {
    return Text(
      title,
      style: TextStyle(
        fontSize: responsive.getFontSize(18),
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required Color color,
    required String title,
    required String count,
    String? label,
    required VoidCallback onTap,
    required ResponsiveDashboard responsive,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(responsive.getSpacing(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.all(responsive.getSpacing(8)),
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
                  count,
                  style: TextStyle(
                    fontSize: responsive.getFontSize(24),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: responsive.getFontSize(14),
                    color: Colors.grey[600],
                  ),
                ),
                if (label != null)
                  Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        label,
                        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
                      )
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    Color color = Colors.grey,
    int? badgeCount,
    required VoidCallback onTap,
    required ResponsiveDashboard responsive,
  }) {
      final iconColor = (title == "Quick Add") ? Colors.teal : Colors.indigoAccent;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
           boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 32, color: iconColor.withOpacity(0.8)),
                  SizedBox(height: responsive.getSpacing(12)),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: responsive.getFontSize(14),
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
            if (badgeCount != null && badgeCount > 0)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badgeCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
