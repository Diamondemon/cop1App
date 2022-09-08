
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ValueNotifierAdapter<T> extends TypeAdapter<ValueNotifier<T>> {
  @override
  final int typeId;

  ValueNotifierAdapter({required this.typeId});

  @override
  ValueNotifier<T> read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ValueNotifier(
      fields[0] as T,
    );
  }

  @override
  void write(BinaryWriter writer, ValueNotifier obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.value);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ValueNotifierAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}