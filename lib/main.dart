import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/pomodoro_screen.dart';
import 'screens/settings_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  await NotificationService.requestPermission();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int focusMinutes = 25;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    focusMinutes = prefs.getInt("focusMinutes") ?? 25;
    setState(() {});
  }

  Future<void> _saveSettings(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("focusMinutes", minutes);
    setState(() => focusMinutes = minutes);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PomodoroScreen(
        focusMinutes: focusMinutes,
        onChangeFocus: _saveSettings,
      ),
    );
  }
}
