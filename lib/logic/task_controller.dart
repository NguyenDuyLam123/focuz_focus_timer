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
}
