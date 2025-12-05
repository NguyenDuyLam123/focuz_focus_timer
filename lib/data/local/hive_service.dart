import 'package:hive/hive.dart';
import '../models/session_model.dart';

class HiveService {
  static const _boxName = 'sessions';

  Future<void> init() async {
    await Hive.openBox<SessionModel>(_boxName);
  }

  Future<void> addSession(SessionModel session) async {
    final box = Hive.box<SessionModel>(_boxName);
    await box.add(session);
  }

  List<SessionModel> getSessions() {
    final box = Hive.box<SessionModel>(_boxName);
    return box.values.toList();
  }
}
