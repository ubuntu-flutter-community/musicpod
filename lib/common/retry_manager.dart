import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import 'data/retry_capsule.dart';
import 'keep_alive_registry.dart';

@injectable
class RetryManager {
  RetryManager._({required RetryCapsule retryCapsule}) {
    _retryTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (cooldown.value > 0) {
        cooldown.value--;
      } else {
        if (retryCapsule.autoRetry && cooldown.value < cooldownMaxValue) {
          retryCapsule = retryCapsule.copyWith(
            retries: retryCapsule.retries + 1,
          );
          cooldown.value = cooldownStartValue * retryCapsule.retries;
          retryCapsule.onRetry();
        } else {
          _retryTicker?.cancel();
        }
      }
    });
  }

  @factoryMethod
  static RetryManager create({
    @factoryParam required RetryCapsule retryCapsule,
  }) => _registry.getOrRegister(
    id: retryCapsule.retryViewId,
    factoryFunction: () => RetryManager._(retryCapsule: retryCapsule),
    autoDisposeAfter: const Duration(minutes: 5),
  );

  static final _registry = KeepAliveRegistry<String, RetryManager>();

  static RetryManager? dispose(String retryViewId) =>
      _registry.dispose(retryViewId);

  Timer? _retryTicker;
  Timer? get retryTicker => _retryTicker;
  final SafeValueNotifier<int> cooldown = SafeValueNotifier<int>(
    cooldownStartValue,
  );
}

const cooldownStartValue = 5;
const cooldownMaxValue = 100;
