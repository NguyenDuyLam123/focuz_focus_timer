import 'package:flutter/material.dart';
import '../logic/task_controller.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final controller = TaskController();
  final TextEditingController input = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.loadTasks().then((_) => setState(() {}));
  }

  void addTaskDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Thêm Task"),
        content: TextField(controller: input),
        actions: [
          TextButton(
            onPressed: () async {
              await controller.addTask(input.text);
              input.clear();
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Task List")),
      floatingActionButton: FloatingActionButton(
        onPressed: addTaskDialog,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: controller.tasks.length,
        itemBuilder: (context, i) {
          final task = controller.tasks[i];
          return ListTile(
            onTap: () {
              Navigator.pushNamed(context, '/pomodoro', arguments: task);
            },
            title: Text(task.title),
            subtitle: Text("Pomodoros: ${task.pomodoroCount}"),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await controller.deleteTask(task.id);
                setState(() {});
              },
            ),
          );
        },
      ),
    );
  }
}
