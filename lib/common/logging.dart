import 'package:flutter/foundation.dart';

class Logger {
  static PrintWhen printWhen = PrintWhen.onlyInDebug;
  static SendWhen sendWhen = SendWhen.onlyInDebug;

  static void r(
    Object? object, {
    StackTrace? trace,
    String tag = '',
    required ReportType reportType,
  }) {
    if ((!kDebugMode && printWhen == PrintWhen.onlyInDebug) ||
        (kDebugMode && printWhen == PrintWhen.onlyInRelease)) {
      return;
    } else {
      _reportToConsole(object, trace: trace, tag: tag, reportType: reportType);
    }

    // If we would ever like to send the error to a server, we could do it here. For now, we just print it to the console.
    /* if ((!kDebugMode && sendWhen == SendWhen.onlyInDebug) ||
        (kDebugMode && sendWhen == SendWhen.onlyInRelease)) {
      return;
    } else {
      
    } */
  }

  static void i(Object? object, {StackTrace? trace, String tag = ''}) {
    r(object, trace: trace, tag: tag, reportType: ReportType.info);
  }

  static void o({required String tag, bool created = true, String? message}) {
    r(
      message ?? 'Instance ${created ? 'created' : 'disposed'}',
      tag: tag,
      reportType: ReportType.memoryChange,
    );
  }

  static void w(Object? object, {StackTrace? trace, String tag = ''}) {
    r(object, trace: trace, tag: tag, reportType: ReportType.warning);
  }

  static void e(Object? object, {StackTrace? trace, String tag = ''}) {
    r(object, trace: trace, tag: tag, reportType: ReportType.error);
  }

  static void fe(FlutterErrorDetails details) {
    r(
      details.exception,
      trace: details.stack,
      tag: 'FlutterError',
      reportType: ReportType.flutterError,
    );
  }
}

void _reportToConsole(
  Object? object, {
  StackTrace? trace,
  String tag = '',
  required ReportType reportType,
}) {
  final message = object.toString();
  debugPrint(
    '${reportType.colorPrefix}${reportType.name}: ${tag.isEmpty ? '' : '[$tag] '} ${reportType.emoji} $message ${reportType.colorSuffix}',
  );
  if (trace != null) {
    debugPrintStack(
      stackTrace: trace,
      label: tag.isNotEmpty ? 'Stack trace for [$tag]' : 'Stack trace',
    );
  }
}

enum ReportType {
  info,
  memoryChange,
  warning,
  flutterError,
  error;

  String get colorPrefix => switch (this) {
    ReportType.info => '\x1B[32m',
    ReportType.warning => '\x1B[33m',
    ReportType.error => '\x1B[31m',
    ReportType.flutterError => '\x1B[35m',
    ReportType.memoryChange => '\x1B[36m',
  };

  String get colorSuffix => '\x1B[0m';

  String get emoji => switch (this) {
    ReportType.info => 'ℹ️',
    ReportType.memoryChange => '🧜🏻‍♀️',
    ReportType.warning => '⚠️',
    ReportType.error => '❌',
    ReportType.flutterError => '👾',
  };
}

enum PrintWhen { onlyInDebug, onlyInRelease, inDebugAndRelease }

enum SendWhen { onlyInDebug, onlyInRelease, inDebugAndRelease }
