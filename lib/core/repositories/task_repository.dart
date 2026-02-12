import '../database/task_database.dart';
import '../models/task_model.dart';
import '../services/calendar_service.dart';

class TaskRepository {
  final TaskDatabase _db = TaskDatabase.instance;
  final CalendarService _calendarService = CalendarService();

  Future<List<Task>> getAllTasks() async {
    // 1. Get local tasks
    var localTasks = await _db.readAllTasks();

    // 2. Try to sync with Google Calendar (basic logic)
    // In a real app, this would be more robust (handling conflicts, deletions, etc.)
    try {
      final events = await _calendarService.getEvents();
      if (events.isNotEmpty) {
        // Simple One-way Sync for demo: Add remote events to local if not exists
        for (var event in events) {
          if (event.summary != null) {
             // Check if already exists by googleId
             // This is simplified. Proper sync requires mapping IDs.
             // Here we just skip for now or could implement specific logic.
          }
        }
      }
    } catch (e) {
      print("Sync failed: $e");
    }

    return localTasks;
  }

  Future<void> addTask(String title, String description, DateTime dueDate) async {
    // 1. Save to Local DB
    final newTask = Task(
      title: title,
      description: description,
      dueDate: dueDate,
      isCompleted: false,
    );
    final savedTask = await _db.create(newTask);

    // 2. Save to Google Calendar
    try {
      final eventId = await _calendarService.insertEvent(title, description, dueDate);
      if (eventId != null) {
        // Update local task with Google ID
        await _db.update(savedTask.copyWith(googleId: eventId));
      }
    } catch (e) {
      print("Failed to add to calendar: $e");
    }
  }

  Future<void> toggleTaskCompletion(Task task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    await _db.update(updatedTask);
    // TODO: Update Google Calendar event status if API supports it easily
  }

  Future<void> signIn() async {
    await _calendarService.signIn();
  }
}
