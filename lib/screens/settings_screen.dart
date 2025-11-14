import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final int focusMinutes;
  final ValueChanged<int> onSave;

  const SettingsScreen({
    super.key,
    required this.focusMinutes,
    required this.onSave,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late int minutes;

  @override
  void initState() {
    super.initState();
    minutes = widget.focusMinutes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cài đặt")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Thời gian Pomodoro (phút)",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),

            Slider(
              value: minutes.toDouble(),
              min: 5,
              max: 60,
              divisions: 11,
              label: "$minutes phút",
              onChanged: (value) => setState(() {
                minutes = value.toInt();
              }),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                widget.onSave(minutes);
                Navigator.pop(context);
              },
              child: const Text("Lưu"),
            ),
          ],
        ),
      ),
    );
  }
}
