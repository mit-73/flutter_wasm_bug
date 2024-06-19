import 'package:flutter/material.dart';

class DataProvider<T extends Object> extends InheritedWidget {
  const DataProvider({
    required super.child,
    required this.data,
    required super.key,
  });

  final T data;

  static T of<T extends Object>(BuildContext context, {bool listen = true}) =>
      listen ? context.watch() : context.read();

  static T? maybeOf<T extends Object>(BuildContext context,
          {bool listen = true}) =>
      listen ? context.maybeWatch() : context.maybeRead();

  @override
  bool updateShouldNotify(DataProvider oldWidget) {
    return child != oldWidget.child || data != oldWidget.data;
  }
}

extension BuildContextEx on BuildContext {
  T read<T extends Object>() => maybeRead()!;

  T? maybeRead<T extends Object>() {
    final DataProvider<T>? inherited =
        getElementForInheritedWidgetOfExactType<DataProvider<T>>()?.widget
            as DataProvider<T>?;

    return inherited?.data;
  }

  T watch<T extends Object>() => maybeWatch()!;

  T? maybeWatch<T extends Object>() {
    final DataProvider<T>? inherited =
        dependOnInheritedWidgetOfExactType<DataProvider<T>>();

    return inherited?.data;
  }
}
