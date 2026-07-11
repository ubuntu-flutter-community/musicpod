// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';

class Logger {
  static PrintWhen printWhen = PrintWhen.onlyInDebug;
  static SendWhen sendWhen = SendWhen.onlyInDebug;

  static void r(
    Object? object, {
    StackTrace? trace,
    String tag = '',
    required ReportType reportType,
    bool useDebugPrint = true,
  }) {
    if ((!kDebugMode && printWhen == PrintWhen.onlyInDebug) ||
        (kDebugMode && printWhen == PrintWhen.onlyInRelease)) {
      return;
    } else {
      _reportToConsole(
        object,
        trace: trace,
        tag: tag,
        reportType: reportType,
        useDebugPrint: useDebugPrint,
      );
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

  static void e(
    Object? object, {
    StackTrace? trace,
    String tag = '',
    bool useDebugPrint = true,
  }) {
    r(
      object,
      trace: trace,
      tag: tag,
      reportType: ReportType.error,
      useDebugPrint: useDebugPrint,
    );
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
  bool useDebugPrint = true,
}) {
  final message = object.toString();
  if (useDebugPrint) {
    debugPrint(
      '${reportType.colorPrefix}${reportType.name}: ${tag.isEmpty ? '' : '[$tag] '} ${reportType.emoji} $message ${reportType.colorSuffix}',
    );
  } else {
    print(
      '${reportType.colorPrefix}${reportType.name}: ${tag.isEmpty ? '' : '[$tag] '} ${reportType.emoji} $message ${reportType.colorSuffix}',
    );
  }
  if (trace != null) {
    final label = tag.isNotEmpty ? 'Stack trace for [$tag]' : 'Stack trace';
    try {
      if (useDebugPrint) {
        debugPrintStack(stackTrace: trace, label: label);
      } else {
        print(label);
        print(trace);
      }
    } on Object {
      // Traces that cross isolate boundaries (e.g. `compute`) or contain
      // `package:stack_trace` async-gap markers cannot be parsed frame-by-frame
      // by debugPrintStack. Fall back to printing the raw trace string so the
      // real stack (e.g. from findEpisodes) is not lost behind a FlutterError.
      debugPrint('$label\n$trace');
    }
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
