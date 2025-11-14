import 'dart:async';
import 'package:flutter/foundation.dart';

/// Handles Pomodoro timer logic.
/// Keeps business logic separate from UI.
class TimerController {
  Timer? _timer;

  int totalSeconds;
  int remainingSeconds;
  bool isRunning = false;

  final VoidCallback onTick;
  final VoidCallback onFinish;

  TimerController({
    required int focusMinutes,
    required this.onTick,
    required this.onFinish,
  }) : totalSeconds = focusMinutes * 60,
       remainingSeconds = focusMinutes * 60;

  /// Starts the timer.
  void start() {
    if (isRunning) return;
    isRunning = true;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remainingSeconds > 0) {
        remainingSeconds--;
        onTick();
      } else {
        stop();
        onFinish();
      }
    });
  }

  /// Pauses the timer.
  void pause() {
    _timer?.cancel();
    isRunning = false;
  }

  /// Resets the timer.
  void reset() {
    pause();
    remainingSeconds = totalSeconds;
  }

  /// Updates Pomodoro duration.
  void updateDuration(int minutes) {
    totalSeconds = minutes * 60;
    remainingSeconds = totalSeconds;
  }

  /// Stops timer completely.
  void stop() {
    _timer?.cancel();
    isRunning = false;
  }

  void dispose() {
    _timer?.cancel();
  }
}
