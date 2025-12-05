import 'package:hive/hive.dart';

part 'session_model.g.dart';

@HiveType(typeId: 0)
class SessionModel {
  @HiveField(0)
  final int focusMinutes;

  @HiveField(1)
  final int breakMinutes;

  @HiveField(2)
  final DateTime startAt;

  @HiveField(3)
  final DateTime endAt;

  SessionModel({
    required this.focusMinutes,
    required this.breakMinutes,
    required this.startAt,
    required this.endAt,
  });
}
