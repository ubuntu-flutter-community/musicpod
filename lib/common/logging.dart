import 'package:flutter/foundation.dart';

void printMessageInDebugMode(
  Object? object, {
  StackTrace? trace,
  String tag = '',
  required LogType logType,
}) {
  if (kDebugMode) {
    final message = object.toString();
    switch (logType) {
      case LogType.info:
        debugPrint(
          tag.isNotEmpty
              ? '\x1B[32m${logType.name}: [$tag] $message \x1B[0m'
              : '\x1B[32m${logType.name}: $message\x1B[0m',
        );
      case LogType.warning:
        debugPrint(
          tag.isNotEmpty
              ? '\x1B[33m${logType.name}: [$tag] ⚠️ $message \x1B[0m'
              : '\x1B[33m${logType.name}: ⚠️ $message\x1B[0m',
        );
      case LogType.error:
        debugPrint(
          tag.isNotEmpty
              ? '\x1B[31m${logType.name}: [$tag] ❌ $message \x1B[0m'
              : '\x1B[31m${logType.name}: ❌ $message\x1B[0m',
        );
      case LogType.flutterError:
        debugPrint(
          tag.isNotEmpty
              ? '\x1B[35m${logType.name}: [$tag] 👾 $message \x1B[0m'
              : '\x1B[35m${logType.name}: 👾 $message\x1B[0m',
        );
    }
    if (trace != null) {
      debugPrintStack(
        stackTrace: trace,
        label: tag.isNotEmpty ? 'Stack trace for [$tag]' : 'Stack trace',
      );
    }
  }
}

void printInfoInDebugMode(
  Object? object, {
  StackTrace? trace,
  String tag = '',
}) {
  printMessageInDebugMode(
    object,
    trace: trace,
    tag: tag,
    logType: LogType.info,
  );
}

void printWarningInDebugMode(
  Object? object, {
  StackTrace? trace,
  String tag = '',
}) {
  printMessageInDebugMode(
    object,
    trace: trace,
    tag: tag,
    logType: LogType.warning,
  );
}

void printErrorInDebugMode(
  Object? object, {
  required StackTrace? trace,
  String tag = '',
}) {
  printMessageInDebugMode(
    object,
    trace: trace,
    tag: tag,
    logType: LogType.error,
  );
}

void printFlutterErrorInDebugMode(FlutterErrorDetails details) {
  printMessageInDebugMode(
    details.exception,
    trace: details.stack,
    tag: 'FlutterError',
    logType: LogType.flutterError,
  );
}

enum LogType { info, warning, flutterError, error }
