import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/retry_capsule.dart';

part 'retry_manager.g.dart';

@riverpod
class RetryManager extends _$RetryManager {
  Timer? _retryTicker;
  late RetryCapsule _capsule;

  @override
  int build(RetryCapsule capsule) {
    _capsule = capsule;
    ref.onDispose(() {
      _retryTicker?.cancel();
    });

    _retryTicker = _createTimer();
    return _capsule.cooldownStartValue;
  }

  void manualRetry() {
    _capsule.onRetry();
    state = _capsule.cooldownStartValue;
    _retryTicker?.cancel();
    _retryTicker = _createTimer();
  }

  Timer _createTimer() => Timer.periodic(const Duration(seconds: 1), (timer) {
    if (state > 0) {
      state = state - 1;
    } else {
      if (!_capsule.autoRetry) {
        timer.cancel();
      } else {
        final nextRetries = _capsule.retries + 1;
        _capsule = _capsule.copyWith(retries: nextRetries);

        final nextCooldown = _capsule.cooldownStartValue *
            (_capsule.autoIncrementCooldown ? nextRetries : 1);
        final clampedCooldown = _capsule.cooldownMaxValue > 0 &&
                nextCooldown > _capsule.cooldownMaxValue
            ? _capsule.cooldownMaxValue
            : nextCooldown;

        state = clampedCooldown;
        _capsule.onRetry();
      }
    }
  });
}
