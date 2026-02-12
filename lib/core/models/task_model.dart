class Task {
  final int? id;
  final String? googleId;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;
  final String status; // 'pending', 'completed', 'overdue'

  Task({
    this.id,
    this.googleId,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    String? status,
  }) : status = status ?? _calculateStatus(dueDate, isCompleted);

  static String _calculateStatus(DateTime dueDate, bool isCompleted) {
    if (isCompleted) return 'completed';
    final now = DateTime.now();
    // Use end of day for overdue check
    final endOfDay = DateTime(dueDate.year, dueDate.month, dueDate.day, 23, 59, 59);
    if (now.isAfter(endOfDay)) return 'overdue';
    return 'pending';
  }

  Task copyWith({
    int? id,
    String? googleId,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      googleId: googleId ?? this.googleId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'googleId': googleId,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      googleId: map['googleId'],
      title: map['title'],
      description: map['description'],
      dueDate: DateTime.parse(map['dueDate']),
      isCompleted: map['isCompleted'] == 1,
    );
  }
}
