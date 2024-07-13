import 'dart:io';

import 'package:intl/intl.dart';

extension IntX on int? {
  String get unixTimeToDateString {
    var s = '';
    if (this == null || this!.abs() > 999999999999999) {
      return s;
    } else {
      try {
        final dateTime = DateTime.fromMillisecondsSinceEpoch(this!);
        s = DateFormat.yMMMEd(
          Platform.localeName == 'und' ? 'en_US' : Platform.localeName,
        ).format(dateTime);
      } on Exception catch (_) {
        return s;
      }
      return s;
    }
  }
}
