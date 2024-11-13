import 'package:flutter/material.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showSnackBar({
  required BuildContext? context,
  Widget? content,
  SnackBar? snackBar,
  Duration? duration,
  bool clear = true,
}) {
  if (context == null || !context.mounted) return null;
  if (clear) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }
  return ScaffoldMessenger.of(context).showSnackBar(
    snackBar ??
        SnackBar(
          content: content ?? const SizedBox.shrink(),
          duration: duration ?? const Duration(seconds: 10),
        ),
  );
}
