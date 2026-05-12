import 'package:flutter/material.dart';

extension NavigatorStateX on NavigatorState {
  Future<T?> teleport<T extends Object?>(
    Widget Function(BuildContext) builder,
  ) =>
      pushAndRemoveUntil(MaterialPageRoute(builder: builder), (route) => false);
}
