import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static Future<int> loadCompletedSessions() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('completedSessions') ?? 0;
  }

  static Future<void> saveCompletedSessions(int value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('completedSessions', value);
  }
}
