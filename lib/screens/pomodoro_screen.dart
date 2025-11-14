import 'package:flutter/material.dart';
import '../logic/timer_controller.dart';
import '../widgets/timer_display.dart';

class PomodoroScreen extends StatefulWidget {
  final int focusMinutes;
  final ValueChanged<int> onChangeFocus;
  final VoidCallback onOpenSettings;

  const PomodoroScreen({
    super.key,
    required this.focusMinutes,
    required this.onChangeFocus,
    required this.onOpenSettings,
  });

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  late TimerController controller;

  @override
  void initState() {
    super.initState();
    controller = TimerController(
      focusMinutes: widget.focusMinutes,
      onTick: () => setState(() {}),
      onFinish: () => setState(() {}),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final running = controller.isRunning;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Focuz Timer"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: widget.onOpenSettings,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TimerDisplay(seconds: controller.remainingSeconds),
            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: running ? controller.pause : controller.start,
                  child: Text(running ? "Pause" : "Start"),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: controller.reset,
                  child: const Text("Reset"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
