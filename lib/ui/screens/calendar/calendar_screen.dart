import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shishu_suraksha/app/theme/colors.dart';
import 'package:shishu_suraksha/data/services/calendar_service.dart';
import 'package:shishu_suraksha/ui/widgets/glass_container.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  List<Calendar> _calendars = [];
  List<Event> _events = [];
  Calendar? _selectedCalendar;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCalendars();
  }

  Future<void> _loadCalendars() async {
    setState(() => _isLoading = true);
    final calendars = await ref.read(calendarServiceProvider).retrieveCalendars();
    setState(() {
      _calendars = calendars;
      if (calendars.isNotEmpty) {
        // Try to find a default google calendar or just pick the first one
        _selectedCalendar = calendars.firstWhere(
            (c) => c.isDefault ?? false,
            orElse: () => calendars.first);
        _loadEvents();
      } else {
        _isLoading = false;
      }
    });
  }

  Future<void> _loadEvents() async {
    if (_selectedCalendar == null) return;
    setState(() => _isLoading = true);
    final events = await ref.read(calendarServiceProvider).retrieveEvents(_selectedCalendar!.id!);
    setState(() {
      _events = events;
      _isLoading = false;
    });
  }

  Future<void> _addEvent() async {
    if (_selectedCalendar == null) return;

    final now = DateTime.now();
    final success = await ref.read(calendarServiceProvider).createEvent(
      calendarId: _selectedCalendar!.id!,
      title: 'Growth Screening Follow-up',
      description: 'Checkup for recent screening results.',
      startTime: now.add(const Duration(hours: 1)),
      endTime: now.add(const Duration(hours: 2)),
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event Added to Calendar!')));
      _loadEvents();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add event')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
           // Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg2.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
             child: Container(color: Colors.black.withOpacity(0.3)),
          ),

          SafeArea(
            child: Column(
              children: [
                // AppBar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Schedule',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: AppColors.secondary),
                        onPressed: _addEvent,
                      ),
                    ],
                  ),
                ),

                // Calendar Selector
                if (_calendars.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Calendar>(
                          value: _selectedCalendar,
                          isExpanded: true,
                          dropdownColor: AppColors.surface,
                          style: const TextStyle(color: Colors.white),
                          items: _calendars.map((c) {
                            return DropdownMenuItem(
                              value: c,
                              child: Text(c.name ?? 'Unknown Calendar', style: const TextStyle(color: AppColors.textPrimary)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() => _selectedCalendar = val);
                            _loadEvents();
                          },
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 10),

                // Event List
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _events.isEmpty
                          ? const Center(
                              child: Text(
                                'No upcoming events',
                                style: TextStyle(color: Colors.white70),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _events.length,
                              itemBuilder: (context, index) {
                                final event = _events[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: GlassContainer(
                                    child: ListTile(
                                      leading: const Icon(Icons.event, color: AppColors.primary),
                                      title: Text(
                                        event.title ?? 'No Title',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      subtitle: Text(
                                        event.start != null 
                                          ? DateFormat('MMM d, h:mm a').format(event.start!)
                                          : '',
                                        style: const TextStyle(color: AppColors.textSecondary),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
