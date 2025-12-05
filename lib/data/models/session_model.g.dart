// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SessionModelAdapter extends TypeAdapter<SessionModel> {
  @override
  final int typeId = 0;

  @override
  SessionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SessionModel(
      focusMinutes: fields[0] as int,
      breakMinutes: fields[1] as int,
      startAt: fields[2] as DateTime,
      endAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SessionModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.focusMinutes)
      ..writeByte(1)
      ..write(obj.breakMinutes)
      ..writeByte(2)
      ..write(obj.startAt)
      ..writeByte(3)
      ..write(obj.endAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
