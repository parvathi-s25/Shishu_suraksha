import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import '../models/task_model.dart'; // Import for Task model if needed for conversion

class CalendarService {
  late final GoogleSignIn? _googleSignIn;

  CalendarService() {
    if (kIsWeb) {
      _googleSignIn = null;
    } else {
      _googleSignIn = GoogleSignIn(
        scopes: [CalendarApi.calendarScope],
      );
    }
  }

  CalendarApi? _calendarApi;

  Future<GoogleSignInAccount?> signIn() async {
    if (_googleSignIn == null) {
      print("Google Sign In not available on web (missing Client ID)");
      return null;
    }
    try {
      final account = await _googleSignIn!.signIn();
      if (account != null) {
        final httpClient = await _googleSignIn!.authenticatedClient();
        if (httpClient != null) {
          _calendarApi = CalendarApi(httpClient);
        }
      }
      return account;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    if (_googleSignIn != null) {
      await _googleSignIn!.signOut();
    }
    _calendarApi = null;
  }

  Future<List<Event>> getEvents() async {
    if (_calendarApi == null) return [];
    try {
      final now = DateTime.now();
      // Fetch events for next 30 days
      final events = await _calendarApi!.events.list(
        'primary',
        timeMin: now.toUtc(),
        timeMax: now.add(const Duration(days: 30)).toUtc(),
        singleEvents: true,
        orderBy: 'startTime',
      );
      return events.items ?? [];
    } catch (e) {
      print('Error fetching events: $e');
      return [];
    }
  }

  Future<String?> insertEvent(String title, String description, DateTime startTime) async {
    if (_calendarApi == null) return null;
    try {
      final event = Event(
        summary: title,
        description: description,
        start: EventDateTime(
          dateTime: startTime,
          timeZone: "IST", 
        ),
        end: EventDateTime(
          dateTime: startTime.add(const Duration(hours: 1)),
          timeZone: "IST",
        ),
      );
      final value = await _calendarApi!.events.insert(event, 'primary');
      return value.id;
    } catch (e) {
      print('Error creating event: $e');
      return null;
    }
  }
}
