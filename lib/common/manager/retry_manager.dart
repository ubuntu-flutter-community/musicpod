import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../data/retry_capsule.dart';
import '../util/family.dart';

@injectable
class RetryManager {
  late RetryCapsule _capsule;

  RetryManager._({required RetryCapsule capsule}) {
    _capsule = capsule;
    cooldown = SafeValueNotifier<int>(_capsule.cooldownStartValue);

    _retryTicker = _createTimer();
  }

  @factoryMethod
  static RetryManager create({@factoryParam required RetryCapsule capsule}) =>
      Family.of(
        capsule.retryViewId,
        () => RetryManager._(capsule: capsule),
        shouldDispose: (t) => !t.cooldown.hasListeners,
        autoDisposeAfter: const Duration(minutes: 5),
      );

  void manualRetry() {
    _capsule.onRetry();
    cooldown.value = _capsule.cooldownStartValue;
    _retryTicker = _createTimer();
  }

  Timer _createTimer() => Timer.periodic(const Duration(seconds: 1), (timer) {
    if (cooldown.value > 0) {
      cooldown.value--;
    } else
    // Now we reached 0
    {
      // if auto retrying is disabled
      if (!_capsule.autoRetry) {
        // we stop the timer
        timer.cancel();
      } else {
        // increment the retries
        _capsule = _capsule.copyWith(retries: _capsule.retries + 1);

        // set the cooldown either to the startvalue
        // increment with the retry factor if autoIncrement is true
        cooldown.value =
            _capsule.cooldownStartValue *
            (_capsule.autoIncrementCooldown ? _capsule.retries : 1);

        _capsule.onRetry();
      }
    }
  });

  Timer? _retryTicker;
  Timer? get retryTicker => _retryTicker;
  late final SafeValueNotifier<int> cooldown;
}
