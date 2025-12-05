import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskController {
  List<Task> tasks = [];

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('tasks');

    if (data != null) {
      final decoded = jsonDecode(data) as List;
      tasks = decoded.map((e) => Task.fromJson(e)).toList();
    } else {
      tasks = [];
    }
  }

  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(tasks.map((e) => e.toJson()).toList());
    await prefs.setString('tasks', encoded);
  }

  Future<void> addTask(String title) async {
    tasks.add(Task(id: DateTime.now().toString(), title: title));
    await saveTasks();
  }

  Future<void> deleteTask(String id) async {
    tasks.removeWhere((task) => task.id == id);
    await saveTasks();
  }

  /// Trả về Task theo id hoặc null nếu không tìm thấy
  Task? getTaskById(String id) {
    try {
      return tasks.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Cập nhật task (tìm theo id và thay thế). Nếu không tồn tại thì thêm mới.
  Future<void> updateTask(Task updated) async {
    final idx = tasks.indexWhere((t) => t.id == updated.id);
    if (idx >= 0) {
      tasks[idx] = updated;
    } else {
      tasks.add(updated);
    }
    await saveTasks();
  }
}
