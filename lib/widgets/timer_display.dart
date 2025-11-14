import 'package:flutter/material.dart';

/// Displays the Pomodoro timer in mm:ss format.
class TimerDisplay extends StatelessWidget {
  final int seconds;

  const TimerDisplay({super.key, required this.seconds});

  String _format(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _format(seconds),
      style: const TextStyle(fontSize: 70, fontWeight: FontWeight.bold),
    );
  }
}
