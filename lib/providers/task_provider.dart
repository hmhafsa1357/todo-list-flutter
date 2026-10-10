import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/task_storage.dart';

/// Holds all tasks and exposes the CRUD operations.
/// Screens listen to this, so the UI updates whenever it changes.
class TaskProvider extends ChangeNotifier {
  final TaskStorage _storage = TaskStorage();
  List<Task> _tasks = [];

  List<Task> get tasks => List.unmodifiable(_tasks);

  Future<void> load() async {
    _tasks = await _storage.load();
    notifyListeners();
  }

  Future<void> _persist() async {
    notifyListeners();
    await _storage.save(_tasks);
  }

  Future<void> add(Task task) async {
    _tasks.add(task);
    await _persist();
  }

  Future<void> update(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) return;
    _tasks[index] = task;
    await _persist();
  }

  Future<void> remove(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    await _persist();
  }

  Future<void> toggleDone(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    _tasks[index] = _tasks[index].copyWith(isDone: !_tasks[index].isDone);
    await _persist();
  }

  Future<void> clearCompleted() async {
    _tasks.removeWhere((t) => t.isDone);
    await _persist();
  }

  /// Tasks for a filter tab: 'Today', 'Upcoming' or 'Done'.
  /// Today    = not done and due today or overdue
  /// Upcoming = not done and due later, or with no due date
  /// Done     = completed tasks
  List<Task> forFilter(String filter) {
    final today = dateOnly(DateTime.now());
    Iterable<Task> result;

    switch (filter) {
      case 'Done':
        result = _tasks.where((t) => t.isDone);
        break;
      case 'Upcoming':
        result = _tasks.where((t) =>
        !t.isDone &&
            (t.dueDate == null || dateOnly(t.dueDate!).isAfter(today)));
        break;
      default:
        result = _tasks.where((t) =>
        !t.isDone &&
            t.dueDate != null &&
            !dateOnly(t.dueDate!).isAfter(today));
    }

    final list = result.toList();
    list.sort(_byDueDate);
    return list;
  }

  int countFor(String filter) => forFilter(filter).length;

  /// All tasks due on a given day (used by the calendar).
  List<Task> forDay(DateTime day) {
    return _tasks
        .where((t) => t.dueDate != null && sameDay(t.dueDate!, day))
        .toList();
  }

  int _byDueDate(Task a, Task b) {
    if (a.dueDate == null && b.dueDate == null) return 0;
    if (a.dueDate == null) return 1;
    if (b.dueDate == null) return -1;
    return a.dueDate!.compareTo(b.dueDate!);
  }
}