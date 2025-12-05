import 'package:flutter/material.dart';
import '../logic/task_controller.dart';
import '../models/task.dart';

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
    // load tasks từ storage khi mở màn hình
    controller.loadTasks().then((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  Future<void> addTaskDialog() async {
    input.clear();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tạo task mới'),
          content: TextField(
            controller: input,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Nhập tiêu đề task'),
            onSubmitted: (_) => _addTaskFromDialog(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: _addTaskFromDialog,
              child: const Text('Thêm'),
            ),
          ],
        );
      },
    );
  }

  void _addTaskFromDialog() async {
    final text = input.text.trim();
    if (text.isEmpty) return;
    await controller.addTask(text);
    // sau khi thêm, reload hoặc cập nhật local list
    if (!mounted) return;
    setState(() {});
    input.clear();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = controller.tasks;
    return Scaffold(
      appBar: AppBar(title: const Text("Task List")),
      floatingActionButton: FloatingActionButton(
        onPressed: addTaskDialog,
        child: const Icon(Icons.add),
      ),
      body: tasks.isEmpty
          ? const Center(child: Text("Chưa có task nào. Nhấn + để tạo."))
          : ListView.separated(
              itemCount: tasks.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final task = tasks[i];
                return ListTile(
                  title: Text(task.title),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await controller.deleteTask(task.id);
                      if (!mounted) return;
                      setState(() {});
                    },
                  ),
                  onTap: () {
                    // nếu muốn chuyển sang Pomodoro và truyền task
                    Navigator.pushNamed(context, '/pomodoro', arguments: task);
                  },
                );
              },
            ),
    );
  }
}
