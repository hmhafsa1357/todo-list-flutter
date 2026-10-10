/// A single to-do item.
class Task {
  final String id;
  final String title;
  final DateTime? dueDate;
  final String priority; // 'High', 'Med' or 'Low'
  final bool isDone;

  const Task({
    required this.id,
    required this.title,
    this.dueDate,
    this.priority = 'Med',
    this.isDone = false,
  });

  Task copyWith({
    String? title,
    DateTime? dueDate,
    bool clearDueDate = false,
    String? priority,
    bool? isDone,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      priority: priority ?? this.priority,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'dueDate': dueDate?.toIso8601String(),
    'priority': priority,
    'isDone': isDone,
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'] as String,
    title: json['title'] as String,
    dueDate: json['dueDate'] == null
        ? null
        : DateTime.parse(json['dueDate'] as String),
    priority: json['priority'] as String? ?? 'Med',
    isDone: json['isDone'] as bool? ?? false,
  );
}

/// True if both dates fall on the same calendar day.
bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Strips the time part, keeping only year/month/day.
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Formats a date like "Sep 11, 2026".
String formatDate(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[d.month - 1]} ${d.day}, ${d.year}';
}