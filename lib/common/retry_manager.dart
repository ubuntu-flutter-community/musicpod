import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import 'data/retry_capsule.dart';
import 'logging.dart';

final _retryManagers = <String, RetryManager>{};

@Injectable(cache: true)
class RetryManager {
  static RetryManager? dispose(String retryViewId) {
    final disposedManager = _retryManagers.remove(retryViewId);
    printInfoInDebugMode(
      'Disposed $RetryManager for $retryViewId',
      tag: '$RetryManager',
    );
    return disposedManager;
  }

  RetryManager({@factoryParam required RetryCapsule retryCapsule})
    : _retryCapsule = retryCapsule {
    printInfoInDebugMode(
      'Instace created for ${retryCapsule.retryViewId}',
      tag: '$RetryManager',
    );
    _retryManagers[retryCapsule.retryViewId] = this;

    _retryTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (cooldown.value > 0) {
        cooldown.value--;
      } else {
        if (retryCapsule.autoRetry) {
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

  Timer? _retryTicker;
  Timer? get retryTicker => _retryTicker;
  final SafeValueNotifier<int> cooldown = SafeValueNotifier<int>(
    cooldownStartValue,
  );

  RetryCapsule _retryCapsule;
  RetryCapsule get retryCapsule => _retryCapsule;
}

const cooldownStartValue = 20;
