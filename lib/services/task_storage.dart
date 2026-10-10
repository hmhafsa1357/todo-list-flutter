import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

/// Saves and loads the task list on the device (local storage).
class TaskStorage {
  static const _key = 'tasks';

  Future<List<Task>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((e) => Task.fromJson(jsonDecode(e))).toList();
  }

  Future<void> save(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      tasks.map((t) => jsonEncode(t.toJson())).toList(),
    );
  }
}