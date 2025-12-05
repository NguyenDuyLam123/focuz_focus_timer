import 'package:flutter/material.dart';
import '../logic/timer_controller.dart';
import '../widgets/timer_display.dart';
import '../services/session_service.dart';
import 'statistics_screen.dart';
import '../screens/settings_screen.dart';
import '../models/task.dart';
import '../logic/task_controller.dart';

class PomodoroScreen extends StatefulWidget {
  final int focusMinutes;
  final ValueChanged<int> onChangeFocus;

  const PomodoroScreen({
    super.key,
    required this.focusMinutes,
    required this.onChangeFocus,
  });

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen>
    with SingleTickerProviderStateMixin {
  late TimerController controller;

  // Task management
  final TaskController taskCtrl = TaskController();
  Task? _selectedTask;

  int completedSessions = 0;

  // Animation
  late AnimationController animCtrl;
  late Animation<double> scaleAnim;
  late Animation<double> fadeAnim;

  final TextEditingController _taskInput = TextEditingController();

  @override
  void initState() {
    super.initState();

    // load saved completed sessions
    SessionService.loadCompletedSessions().then((value) {
      setState(() => completedSessions = value);
    });

    // init timer controller
    controller = TimerController(
      focusMinutes: widget.focusMinutes,
      onTick: () => setState(() {}),
      onFinish: () {
        completedSessions++;
        SessionService.saveCompletedSessions(completedSessions);
        setState(() {});
      },
    );

    // load tasks
    taskCtrl.loadTasks().then((_) {
      setState(() {
        // keep _selectedTask null for now; if route provides task we'll pick it in build
      });
    });

    // UI Animation
    animCtrl = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat(reverse: true);

    scaleAnim = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: animCtrl, curve: Curves.easeInOut));

    fadeAnim = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: animCtrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    animCtrl.dispose();
    controller.dispose();
    _taskInput.dispose();
    super.dispose();
  }

  Future<void> _addTaskDialog() async {
    _taskInput.clear();
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Tạo task mới'),
          content: TextField(
            controller: _taskInput,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Nhập tiêu đề task'),
            onSubmitted: (_) => _confirmAddTask(ctx),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => _confirmAddTask(ctx),
              child: const Text('Thêm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmAddTask(BuildContext ctx) async {
    final text = _taskInput.text.trim();
    if (text.isEmpty) return;
    await taskCtrl.addTask(text);
    await taskCtrl.loadTasks();
    // tự chọn task vừa tạo
    setState(() {
      _selectedTask = taskCtrl.tasks.isNotEmpty ? taskCtrl.tasks.last : null;
    });
    Navigator.of(ctx).pop();
  }

  Future<void> _deleteTask(Task task) async {
    await taskCtrl.deleteTask(task.id);
    await taskCtrl.loadTasks();
    if (_selectedTask?.id == task.id) _selectedTask = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Task được truyền qua route (nếu có)
    final Task? routeTask = ModalRoute.of(context)?.settings.arguments as Task?;

    // ưu tiên task truyền từ route, nếu không thì dùng _selectedTask
    final Task? activeTask = routeTask ?? _selectedTask;

    // Khi chạy → bật animation, khi pause → dừng
    final running = controller.isRunning;
    running ? animCtrl.forward() : animCtrl.stop();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Focuz Timer"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(
                    focusMinutes: widget.focusMinutes,
                    onSave: (newMinutes) {
                      widget.onChangeFocus(newMinutes);
                      controller.updateFocusMinutes(
                        newMinutes,
                      ); // cập nhật timer
                      setState(() {});
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),

      // Nếu chưa có task được chọn — hiển thị giao diện chọn/tao task
      body: activeTask == null
          ? _buildTaskPicker()
          : _buildTimerBody(activeTask),

      // FAB: nếu chưa có task thì hiện nút tạo task; khi đã chọn task thì ẩn FAB (hoặc tuỳ bạn muốn)
      floatingActionButton: activeTask == null
          ? FloatingActionButton(
              onPressed: _addTaskDialog,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildTaskPicker() {
    final tasks = taskCtrl.tasks;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 8),
            const Text(
              "Chọn một Task để bắt đầu",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (tasks.isEmpty)
              const Expanded(
                child: Center(
                  child: Text("Bạn chưa có task nào. Nhấn + để tạo task mới."),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: tasks.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, i) {
                    final t = tasks[i];
                    return ListTile(
                      title: Text(t.title),
                      onTap: () {
                        setState(() {
                          _selectedTask = t;
                        });
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.play_arrow),
                            onPressed: () {
                              // chọn và bắt đầu luôn
                              setState(() {
                                _selectedTask = t;
                              });
                              // start timer immediately
                              controller.start(t, t.id);
                              animCtrl.repeat(reverse: true);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteTask(t),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.bar_chart),
              label: const Text("Xem thống kê"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        StatisticsScreen(completedSessions: completedSessions),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerBody(Task task) {
    final running = controller.isRunning;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),

          /// TIMER ANIMATION
          IgnorePointer(
            ignoring: true,
            child: ScaleTransition(
              scale: scaleAnim,
              child: FadeTransition(
                opacity: fadeAnim,
                child: TimerDisplay(seconds: controller.remainingSeconds),
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// Task title
          Text(
            task.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 12),

          /// Completed Count
          Text(
            "Phiên hoàn thành: $completedSessions",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 40),

          /// Button Start/Pause + Reset
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: running ? Colors.redAccent : Colors.green,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: running ? 18 : 6,
                      spreadRadius: running ? 2 : 0,
                      color: Colors.black26,
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: () {
                    if (controller.isRunning) {
                      controller.pause();
                      animCtrl.stop();
                    } else {
                      controller.start(task, task.id);
                      animCtrl.repeat(reverse: true);
                    }
                    setState(() {});
                  },
                  child: Text(
                    running ? "Pause" : "Start",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  controller.reset();
                  animCtrl.stop();
                  animCtrl.reset();
                  setState(() {});
                },
                child: const Text("Reset", style: TextStyle(fontSize: 18)),
              ),
            ],
          ),

          const SizedBox(height: 25),

          /// Open Statistics Screen
          OutlinedButton.icon(
            icon: const Icon(Icons.bar_chart),
            label: const Text("Xem thống kê"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 14),
              side: const BorderSide(color: Colors.blueAccent, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      StatisticsScreen(completedSessions: completedSessions),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // nút back để chọn task khác
          TextButton.icon(
            onPressed: () {
              // trở về chế độ chọn task
              setState(() {
                _selectedTask = null;
                controller.reset();
                animCtrl.stop();
                animCtrl.reset();
              });
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text("Chọn task khác"),
          ),
        ],
      ),
    );
  }
}
