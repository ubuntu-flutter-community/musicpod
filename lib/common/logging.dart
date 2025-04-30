import 'package:flutter/foundation.dart';

void printMessageInDebugMode(Object? object, [String tag = '']) {
  if (kDebugMode) {
    final message = object.toString();
    debugPrint(tag.isNotEmpty ? '[$tag] $message' : message);
  }
}
