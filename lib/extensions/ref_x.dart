import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

extension RefX on Ref {
  /// Keeps the provider alive for [duration] after the last listener is removed.
  ///
  /// If a new listener subscribes before the timer expires, the timer is
  /// cancelled and the provider remains alive.
  void cacheFor(Duration duration) {
    final link = keepAlive();
    Timer? timer;

    onDispose(() => timer?.cancel());

    onCancel(() {
      timer = Timer(duration, () {
        link.close();
      });
    });

    onResume(() {
      timer?.cancel();
    });
  }
}
