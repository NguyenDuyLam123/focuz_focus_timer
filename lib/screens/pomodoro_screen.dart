import 'package:flutter/material.dart';
import '../logic/timer_controller.dart';
import '../widgets/timer_display.dart';
import '../services/session_service.dart';
import 'statistics_screen.dart';
import '../screens/settings_screen.dart';
import '../models/task.dart';

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

  int completedSessions = 0;

  // Animation
  late AnimationController animCtrl;
  late Animation<double> scaleAnim;
  late Animation<double> fadeAnim;

  @override
  void initState() {
    super.initState();

    SessionService.loadCompletedSessions().then((value) {
      setState(() => completedSessions = value);
    });

    controller = TimerController(
      focusMinutes: widget.focusMinutes,
      onTick: () => setState(() {}),
      onFinish: () {
        completedSessions++;
        SessionService.saveCompletedSessions(completedSessions);
        setState(() {});
      },
    );

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final running = controller.isRunning;
    final Task? task = ModalRoute.of(context)?.settings.arguments as Task?;

    if (task == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            "Không có Task được chọn!",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }
    // Khi chạy → bật animation, khi pause → dừng
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
                      ); // 🔥 thêm dòng này
                      setState(() {});
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),

      body: Center(
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
                        animCtrl.stop(); // stop animation when paused
                      } else {
                        controller.start(task, task.id);
                        animCtrl.repeat(
                          reverse: true,
                        ); // restart animation smoothly
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
                    animCtrl.reset(); // return animation to default scale
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 14,
                ),
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
          ],
        ),
      ),
    );
  }
}
