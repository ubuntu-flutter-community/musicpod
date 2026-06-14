import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import 'data/retry_capsule.dart';
import 'logging.dart';

@Injectable(cache: true)
class RetryManager {
  RetryManager({@factoryParam required RetryCapsule retryCapsule})
    : _retryCapsule = retryCapsule {
    printInfoInDebugMode(
      'Instance created for ${retryCapsule.retryViewId}',
      tag: '$RetryManager',
    );
    _instances[retryCapsule.retryViewId] = this;

    _retryTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (cooldown.value > 0) {
        cooldown.value--;
      } else {
        if (retryCapsule.autoRetry && cooldown.value < cooldownMaxValue) {
          _retryCapsule = _retryCapsule.copyWith(
            retries: _retryCapsule.retries + 1,
          );
          cooldown.value = cooldownStartValue * _retryCapsule.retries;
          _retryCapsule.onRetry();
        } else {
          _retryTicker?.cancel();
        }
      }
    });
  }

  RetryCapsule _retryCapsule;
  Timer? _retryTicker;
  Timer? get retryTicker => _retryTicker;
  final SafeValueNotifier<int> cooldown = SafeValueNotifier<int>(
    cooldownStartValue,
  );

  static final _instances = <String, RetryManager>{};

  static RetryManager? dispose(String retryViewId) {
    if (_instances.containsKey(retryViewId)) {
      final disposedManager = _instances.remove(retryViewId);

      printInfoInDebugMode(
        'Disposed $RetryManager for $retryViewId',
        tag: '$RetryManager',
      );

      return disposedManager;
    } else {
      return null;
    }
  }
}

const cooldownStartValue = 5;
const cooldownMaxValue = 100;
