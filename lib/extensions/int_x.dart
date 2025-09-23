import 'dart:io';

import 'package:intl/intl.dart';
import '../common/logging.dart';

extension IntX on int? {
  String get unixTimeToDateString {
    var time = '';
    var date = '';
    if (this == null || this!.abs() > 999999999999999) {
      return time;
    } else {
      try {
        final dateTime = DateTime.fromMillisecondsSinceEpoch(this!);
        date = DateFormat.yMd(
          Platform.localeName == 'und' ? 'en_US' : Platform.localeName,
        ).format(dateTime);
        time = DateFormat.Hm(
          Platform.localeName == 'und' ? 'en_US' : Platform.localeName,
        ).format(dateTime);
      } on Exception catch (e) {
        printMessageInDebugMode(e);
        return date + ', ' + time;
      }
      return date + ', ' + time;
    }
  }
}
