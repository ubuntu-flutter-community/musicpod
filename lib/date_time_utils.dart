import 'dart:io';

import 'package:intl/intl.dart';

String unixTimeToDateString(int? unixTime) {
  var s = '';
  if (unixTime == null || unixTime.abs() > 999999999999999) {
    return s;
  } else {
    try {
      final dateTime = DateTime.fromMillisecondsSinceEpoch(unixTime);
      s = DateFormat.yMMMEd(
        Platform.localeName == 'und' ? 'en_US' : Platform.localeName,
      ).format(dateTime);
    } on Exception catch (_) {
      return s;
    }
    return s;
  }
}
