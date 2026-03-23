import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/task_model.dart';
import '../../../../core/repositories/task_repository.dart';

class HomeTaskTab extends StatefulWidget {
  const HomeTaskTab({Key? key}) : super(key: key);

  @override
  _HomeTaskTabState createState() => _HomeTaskTabState();
}

class _HomeTaskTabState extends State<HomeTaskTab> {
  final TaskRepository _repository = TaskRepository();
  List<Task> _allTasks = [];
  bool _isLoading = true;

  // Calendar State
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Task>> _groupedTasks = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    
    // Create Mock Data if empty (for demonstration as requested)
    var tasks = await _repository.getAllTasks();
    if (tasks.isEmpty) {
      await _seedMockData();
      tasks = await _repository.getAllTasks();
    }

    // Group tasks by Date (ignoring time)
    final Map<DateTime, List<Task>> grouped = {};
    for (var task in tasks) {
      final date = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
      if (grouped[date] == null) grouped[date] = [];
      grouped[date]!.add(task);
    }

    setState(() {
      _allTasks = tasks;
      _groupedTasks = grouped;
      _isLoading = false;
    });
  }

  Future<void> _seedMockData() async {
    final now = DateTime.now();
    final tasksToSeed = [
      Task(title: "Health check – Child A (Raju)", description: "Routine immunization check", dueDate: now, status: 'pending'),
      Task(title: "Nutrition activity – Group B", description: "Distribute supplements", dueDate: now.add(const Duration(hours: 2)), status: 'pending'),
      Task(title: "Follow-up – High-risk child", description: "Home visit for Priya", dueDate: now.add(const Duration(days: 1)), status: 'pending'),
      Task(title: "Monthly parent counseling", description: "Community hall meeting", dueDate: now.add(const Duration(days: 2)), status: 'pending'),
      Task(title: "Supervisor review visit", description: "Prepare register updates", dueDate: now.add(const Duration(days: -1)), status: 'overdue'),
      Task(title: "Growth Monitoring", description: "Weight and height measurement", dueDate: now.add(const Duration(days: 5)), status: 'pending'),
    ];

    for (var t in tasksToSeed) {
      await _repository.addTask(t.title, t.description, t.dueDate);
    }
  }

  Future<void> _addTask() async {
     final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime selectedDate = _selectedDay ?? DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Anganwadi Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Task Title', hintText: "e.g., Home Visit")),
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description', hintText: "e.g., Check child weight")),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text("Date: ${DateFormat('MMM d').format(selectedDate)}"),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                 final dateTime = DateTime(
                   selectedDate.year, 
                   selectedDate.month, 
                   selectedDate.day, 
                   selectedTime.hour, 
                   selectedTime.minute
                 );
                 await _repository.addTask(
                   titleController.text, 
                   descController.text, 
                   dateTime,
                  );
                 _loadTasks(); // Reload to update calendar
                 if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Add Task'),
          ),
        ],
      ),
    );
  }

  Future<void> _syncCalendar() async {
    // Sync logic from before
    setState(() => _isLoading = true);
    try {
      await _repository.signIn();
      await _loadTasks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sync completed!')));
      }
    } catch (e) {
      // Ignore for now
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Task> _getTasksForDay(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return _groupedTasks[date] ?? [];
  }

  void _showTasksForDay(DateTime day) {
    final tasks = _getTasksForDay(day);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('EEEE, MMMM d').format(day),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(),
              if (tasks.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: Text("No tasks for this day.", style: TextStyle(color: Colors.grey))),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Checkbox(
                            value: task.isCompleted,
                            activeColor: Colors.teal,
                            onChanged: (val) async {
                              await _repository.toggleTaskCompletion(task);
                              Navigator.pop(context); // Close sheet
                              _loadTasks(); // Reload
                              _showTasksForDay(day); // Reopen sheet (optional, creates flicker but updates state)
                            },
                          ),
                          title: Text(
                            task.title,
                            style: TextStyle(
                              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          subtitle: Text(task.description),
                          trailing: _buildStatusTag(task),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Stack(
      children: [
        LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                   // Header
                   Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        const SizedBox(width: 48), // Spacer to balance the Sync button
                        Expanded(
                          child: Text(
                            "Monthly Planner",
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.sync, color: Colors.teal),
                          tooltip: "Sync",
                          onPressed: _syncCalendar,
                        ),
                      ],
                    ),
                  ),
                  
                  Card(
                    margin: const EdgeInsets.all(12),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: TableCalendar<Task>(
                      firstDay: DateTime.utc(2020, 10, 16),
                      lastDay: DateTime.utc(2030, 3, 14),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      availableCalendarFormats: const { CalendarFormat.month : 'Month' }, // Only Month View
                      
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        if (!isSameDay(_selectedDay, selectedDay)) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        }
                        _showTasksForDay(selectedDay);
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                      eventLoader: _getTasksForDay,

                      // Styling
                      calendarStyle: const CalendarStyle(
                        outsideDaysVisible: false,
                        todayDecoration: BoxDecoration(
                          color: Colors.orangeAccent,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Colors.teal,
                          shape: BoxShape.circle,
                        ),
                        markerSize: 0, // We use custom builder
                        cellMargin: EdgeInsets.all(2), // Reduce margin to fit more
                      ),
                      headerStyle: const HeaderStyle(
                        titleCentered: true,
                        formatButtonVisible: false,
                        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      
                      // Custom Builders for Pills - Unified to ensure alignment
                      calendarBuilders: CalendarBuilders(
                        // We remove markerBuilder to avoid double-rendering.
                        // Instead, we fully customize the cell to include the task bars.
                        
                        defaultBuilder: (context, day, focusedDay) {
                           return _buildCell(day);
                        },
                        todayBuilder: (context, day, focusedDay) {
                           return _buildCell(day, isToday: true);
                        },
                        selectedBuilder: (context, day, focusedDay) {
                           return _buildCell(day, isSelected: true);
                        },
                      ),
                    ),
                  ),
                  
                  // Helper Legend
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLegendItem(Colors.green, "Done"),
                        _buildLegendItem(Colors.blue, "Scheduled"),
                        _buildLegendItem(Colors.red, "Overdue"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60), // Space for FAB
                ],
              ),
            ),
          );
        }
      ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: _addTask,
            backgroundColor: Colors.teal,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildCell(DateTime day, {bool isToday = false, bool isSelected = false}) {
    final tasks = _getTasksForDay(day);
    
    // Style for the number container
    BoxDecoration? decoration;
    Color textColor = Colors.black87;
    FontWeight fontWeight = FontWeight.normal;

    if (isSelected) {
      decoration = const BoxDecoration(color: Colors.teal, shape: BoxShape.circle);
      textColor = Colors.white;
      fontWeight = FontWeight.bold;
    } else if (isToday) {
      decoration = const BoxDecoration(color: Colors.orangeAccent, shape: BoxShape.circle);
      textColor = Colors.white;
      fontWeight = FontWeight.bold;
    }

    return Container(
      margin: const EdgeInsets.all(2),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Date Number
          Container(
            width: 28, // Fixed width for consistent circle
            height: 28,
            alignment: Alignment.center,
            decoration: decoration,
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: textColor,
                fontWeight: fontWeight,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 4), // Spacing between number and pills
          
          // Task Bars (Pills)
          // Use a Column of bars. If too many, maybe show a "+" indicator? 
          // For now, take 3.
          ...tasks.take(4).map((t) {
             Color color;
              if (t.isCompleted) color = Colors.green;
              else if (t.status == 'overdue') color = Colors.red;
              else color = Colors.blue; // Scheduled

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 1),
                height: 4,
                width: 24, // Slightly wider
                decoration: BoxDecoration(
                  color: color.withOpacity(0.9), // Higher opacity
                  borderRadius: BorderRadius.circular(2),
                ),
              );
          }),
          
          if (tasks.length > 4)
             Container(
               margin: const EdgeInsets.only(top: 1),
               width: 12,
               height: 2, 
               color: Colors.grey,
             ),
        ],
      ),
    );
  }

  Widget _buildStatusTag(Task task) {
    Color color;
    String text;
    if (task.isCompleted) {
      color = Colors.green;
      text = "Done";
    } else if (task.status == 'overdue') {
      color = Colors.red;
      text = "Overdue";
    } else {
      color = Colors.blue;
      text = "Pending";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(text, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
