// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cop1_event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class Cop1EventAdapter extends TypeAdapter<Cop1Event> {
  @override
  final int typeId = 0;

  @override
  Cop1Event read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Cop1Event(
      fields[0] as int,
      fields[1] as String,
      fields[2] as String,
      fields[3] as DateTime,
      fields[4] as String,
      fields[5] as String,
      fields[6] as String,
      fields[7] == null ? true : fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Cop1Event obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.duration)
      ..writeByte(5)
      ..write(obj.location)
      ..writeByte(6)
      ..write(obj.imageLink)
      ..writeByte(7)
      ..write(obj.isAvailable);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cop1EventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
