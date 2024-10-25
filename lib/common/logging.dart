import 'package:flutter/foundation.dart';

void printMessageInDebugMode(String message) {
  if (kDebugMode) {
    print(message);
  }
}
