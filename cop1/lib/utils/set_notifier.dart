import 'dart:collection';
import 'package:flutter/foundation.dart';

class SetNotifier<T> extends ValueListenable<Set<T>> with ChangeNotifier, SetMixin<T> {
  final Set<T> _set = <T>{};

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