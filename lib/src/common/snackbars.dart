import 'package:flutter/material.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar({
  required BuildContext context,
  required Widget content,
  Duration? duration,
  clear = true,
}) {
  if (clear) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: content,
      duration: duration ?? const Duration(seconds: 3),
    ),
  );
}
