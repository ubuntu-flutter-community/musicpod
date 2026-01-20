import 'package:flutter/foundation.dart';

void printMessageInDebugMode(
  Object? object, {
  StackTrace? trace,
  String tag = '',
}) {
  if (kDebugMode) {
    final message = object.toString();
    debugPrint(tag.isNotEmpty ? '[$tag] $message' : message);
    if (trace != null) {
      debugPrint(trace.toString());
    }
  }
}
