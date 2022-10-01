import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

/// [ChangeNotifier] containing a [Set] and notifying the Listeners for every element added or removed
@HiveType(typeId: 1)
class SetNotifier<T> extends ValueListenable<Set<T>> with ChangeNotifier, SetMixin<T>, HiveObjectMixin {

  @HiveField(0)
  Set<T> _set = <T>{};

  SetNotifier();

  SetNotifier.fromList(List<T> list){
    _set = list.toSet();
  }


  @override
  int get length => _set.length;

  @override
  bool add(T value) {
    final bool ret = _set.add(value);
    if (ret) notifyListeners();
    return ret;
  }

  @override
  Set<T> get value => _set;

  @override
  bool contains(Object? element) => _set.contains(element);

  @override
  Iterator<T> get iterator => _set.iterator;

  @override
  T? lookup(Object? element) {
    return _set.lookup(element);
  }

  @override
  bool remove(Object? value) {
    final bool ret = _set.remove(value);
    if (ret) notifyListeners();
    return ret;
  }

  @override
  Set<T> toSet() {
    return _set.toSet();
  }

  @override
  Iterable<T> where(bool Function(T) f){
    return _set.where(f);
  }

  @override
  T firstWhere(bool Function(T) test, {T Function()? orElse}){
    return _set.firstWhere(test, orElse:orElse);
  }
}

/// Adapter of [SetNotifier] for [Hive] database storage
class SetNotifierAdapter<T> extends TypeAdapter<SetNotifier<T>> {
  @override
  final int typeId;

  SetNotifierAdapter({required this.typeId});

  @override
  SetNotifier<T> read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SetNotifier().._set = (fields[0] as List).cast<T>().toSet();
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