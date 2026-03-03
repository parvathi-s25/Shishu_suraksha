import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

class CalendarService {
  bool _initialized = false;
  CalendarApi? _calendarApi;

  Future<void> _ensureInitialized() async {
    if (!_initialized && !kIsWeb) {
      await GoogleSignIn.instance.initialize();
      _initialized = true;
    }
  }

  Future<bool> signIn() async {
    if (kIsWeb) {
      debugPrint('Google Sign In not supported on web without a Client ID.');
      return false;
    }

    try {
      await _ensureInitialized();

      // Step 1: Authenticate (get GoogleSignInAccount)
      final account = await GoogleSignIn.instance.authenticate(
        scopeHint: [CalendarApi.calendarScope],
      );

      // Step 2: Authorize scopes via the account's authorizationClient
      final authorization = await account.authorizationClient.authorizeScopes(
        [CalendarApi.calendarScope],
      );

      // Step 3: Create an authenticated HTTP client using the extension
      final authClient = authorization.authClient(
        scopes: [CalendarApi.calendarScope],
      );

      _calendarApi = CalendarApi(authClient);
      return true;
    } catch (e) {
      debugPrint('Error signing in to Google Calendar: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    if (!kIsWeb) {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (e) {
        debugPrint('Error signing out: $e');
      }
    }
    _calendarApi = null;
  }

  Future<List<Event>> getEvents() async {
    if (_calendarApi == null) return [];
    try {
      final now = DateTime.now();
      final events = await _calendarApi!.events.list(
        'primary',
        timeMin: now.toUtc(),
        timeMax: now.add(const Duration(days: 30)).toUtc(),
        singleEvents: true,
        orderBy: 'startTime',
      );
      return events.items ?? [];
    } catch (e) {
      debugPrint('Error fetching events: $e');
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
          timeZone: 'IST',
        ),
        end: EventDateTime(
          dateTime: startTime.add(const Duration(hours: 1)),
          timeZone: 'IST',
        ),
      );
      final value = await _calendarApi!.events.insert(event, 'primary');
      return value.id;
    } catch (e) {
      debugPrint('Error creating event: $e');
      return null;
    }
  }
}
