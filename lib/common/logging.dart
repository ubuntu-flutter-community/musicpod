import 'package:flutter/foundation.dart';

void _printMessageInDebugMode(
  Object? object, {
  StackTrace? trace,
  String tag = '',
  PrintLevel level = PrintLevel.info,
}) {
  if (kDebugMode) {
    final message = object.toString();
    switch (level) {
      case PrintLevel.info:
        debugPrint(
          tag.isNotEmpty
              ? '\x1B[32m${level.name}: [$tag] $message \x1B[0m'
              : '\x1B[32m${level.name}: $message\x1B[0m',
        );
      case PrintLevel.warning:
        debugPrint(
          tag.isNotEmpty
              ? '\x1B[33m${level.name}: [$tag] ⚠️ $message \x1B[0m'
              : '\x1B[33m${level.name}: ⚠️ $message\x1B[0m',
        );
      case PrintLevel.error:
        debugPrint(
          tag.isNotEmpty
              ? '\x1B[31m${level.name}: [$tag] ❌ $message \x1B[0m'
              : '\x1B[31m${level.name}: ❌ $message\x1B[0m',
        );
    }
    if (trace != null) {
      debugPrint(trace.toString());
    }
  }
}

void printInfoInDebugMode(
  Object? object, {
  StackTrace? trace,
  String tag = '',
}) {
  _printMessageInDebugMode(
    object,
    trace: trace,
    tag: tag,
    level: PrintLevel.info,
  );
}

void printWarningInDebugMode(
  Object? object, {
  StackTrace? trace,
  String tag = '',
}) {
  _printMessageInDebugMode(
    object,
    trace: trace,
    tag: tag,
    level: PrintLevel.warning,
  );
}

void printErrorInDebugMode(
  Object? object, {
  required StackTrace? trace,
  String tag = '',
}) {
  _printMessageInDebugMode(
    object,
    trace: trace,
    tag: tag,
    level: PrintLevel.error,
  );
}

enum PrintLevel { info, warning, error }
