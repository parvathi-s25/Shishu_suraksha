import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final calendarServiceProvider = Provider<CalendarService>((ref) {
  return CalendarService();
});

class CalendarService {
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

  Future<bool> requestPermissions() async {
    var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
    if (permissionsGranted.isSuccess && !permissionsGranted.data!) {
      permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
      if (!permissionsGranted.isSuccess || !permissionsGranted.data!) {
        return false;
      }
    }
    return true;
  }

  Future<List<Calendar>> retrieveCalendars() async {
    final permissionsGranted = await requestPermissions();
    if (!permissionsGranted) return [];

    try {
      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      return calendarsResult.data ?? [];
    } on PlatformException catch (e) {
      print('Platform Exception: $e');
      return [];
    }
  }

  Future<List<Event>> retrieveEvents(String calendarId) async {
    final startDate = DateTime.now();
    final endDate = DateTime.now().add(const Duration(days: 30));
    
    final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
      calendarId,
      RetrieveEventsParams(startDate: startDate, endDate: endDate),
    );
    return eventsResult.data ?? [];
  }

  Future<bool> createEvent({
    required String calendarId,
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final eventToCreate = Event(
      calendarId,
      title: title,
      description: description,
      start: TZDateTime.from(startTime, local),
      end: TZDateTime.from(endTime, local),
    );

    final createEventResult = await _deviceCalendarPlugin.createOrUpdateEvent(eventToCreate);
    return createEventResult?.isSuccess ?? false;
  }
}
