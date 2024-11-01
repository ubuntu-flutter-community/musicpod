import 'package:flutter/foundation.dart';

void printMessageInDebugMode(Object? object) {
  if (kDebugMode) {
    print(object);
  }
}
