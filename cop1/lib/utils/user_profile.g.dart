// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 2;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      fields[2] as String,
    )
      ..firstName = fields[0] as ValueNotifier<String>
      ..lastName = fields[1] as ValueNotifier<String>
      ..email = fields[3] as ValueNotifier<String>
      ..events = (fields[4] as List).cast<int>() as SetNotifier<int>
      ..pastEvents = (fields[5] as List).cast<int>() as SetNotifier<int>
      ..barcodes = (fields[6] as Map).cast<int, String>()
      ..minDelayDays = fields[7] as int;
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.firstName)
      ..writeByte(1)
      ..write(obj.lastName)
      ..writeByte(2)
      ..write(obj._phoneNumber)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.events.toList())
      ..writeByte(5)
      ..write(obj.pastEvents.toList())
      ..writeByte(6)
      ..write(obj.barcodes)
      ..writeByte(7)
      ..write(obj.minDelayDays);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
