import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/task.dart';
import 'task_controller.dart';
import '../services/notification_service.dart';
import '../data/local/hive_service.dart';
import '../data/models/session_model.dart';

class TimerController {
  Timer? _timer;

  int focusMinutes;
  int totalSeconds;
  int remainingSeconds;
  bool isRunning = false;

  final VoidCallback onTick;
  final VoidCallback onFinish;

  TimerController({
    required this.focusMinutes,
    required this.onTick,
    required this.onFinish,
  }) : totalSeconds = focusMinutes * 60,
       remainingSeconds = focusMinutes * 60;

  /// Starts the timer for a specific task.
  void start(Task task, String id) {
    if (isRunning) return;
    isRunning = true;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remainingSeconds > 0) {
        remainingSeconds--;
        onTick();
      } else {
        stop();

        // gọi ngay khi hết giờ
        finishPomodoro(task);
        NotificationService.show(
          "Hoàn thành 1 phiên Pomodoro",
          "${task.title} đã hoàn tất!",
        );
        onFinish();
      }
    });
  }

  void pause() {
    _timer?.cancel();
    isRunning = false;
  }

  void reset() {
    pause();
    remainingSeconds = totalSeconds;
  }

  void updateDuration(int minutes) {
    totalSeconds = minutes * 60;
    remainingSeconds = totalSeconds;
  }

  void stop() {
    _timer?.cancel();
    isRunning = false;
  }

  void dispose() {
    _timer?.cancel();
  }

  void finishPomodoro(Task task) {
    task.pomodoroCount++;
    TaskController().saveTasks();
  }

  final hiveService = HiveService();

  DateTime? _startTime;

  void saveSession(int focus, int breakTime) {
    final session = SessionModel(
      focusMinutes: focus,
      breakMinutes: breakTime,
      startAt: _startTime!,
      endAt: DateTime.now(),
    );

    hiveService.addSession(session);
  }

  void updateFocusMinutes(int minutes) {
    focusMinutes = minutes;
    updateDuration(minutes); // cập nhật cả giây
    reset();
  }
}
