// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_notifier.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SetNotifierAdapter extends TypeAdapter<SetNotifier> {
  @override
  final int typeId = 1;

  @override
  SetNotifier read(BinaryReader reader) {
    return SetNotifier();
  }

  @override
  void write(BinaryWriter writer, SetNotifier obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj._set.toList());
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetNotifierAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
