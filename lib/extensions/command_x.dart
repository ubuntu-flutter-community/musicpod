import 'dart:async';

import 'package:flutter_it/flutter_it.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

// Expandos must be declared outside the extension as top-level or static variables
final Expando<SafeValueNotifier<int>> _cooldownStorage = Expando();
final Expando<Timer> _timerStorage = Expando();

enum RunWhen { paramChanges, hasNoValueAndNoErrors }

extension CommandX<TParam, TResult> on Command<TParam, TResult> {
  SafeValueNotifier<int> get cooldown {
    return _cooldownStorage[this] ??= SafeValueNotifier<int>(0);
  }

  Timer? get _cooldownTimer => _timerStorage[this];
  set _cooldownTimer(Timer? timer) {
    if (timer == null) {
      _timerStorage[this] = null;
    } else {
      _timerStorage[this] = timer;
    }
  }

  void runRestricted({
    TParam? param,
    bool immediatelyClearErrors = false,
    RunWhen runWhen = RunWhen.hasNoValueAndNoErrors,
    int coolDownSeconds = 20,
  }) {
    if (immediatelyClearErrors) {
      this.clearErrors();
    }

    if (runWhen == RunWhen.hasNoValueAndNoErrors && _hasValueAndNoErrors) {
      return;
    }

    if (runWhen == RunWhen.paramChanges
        ? _paramHasChangedOrIsOnlyNull(param)
        : _hasNoValueAndNoErrors) {
      run(param);
      return;
    }

    if (errors.value != null && _cooldownTimer == null) {
      cooldown.value = coolDownSeconds;

      _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (cooldown.isDisposed) {
          timer.cancel();
          _cooldownTimer = null;
          return;
        }

        if (cooldown.value > 0) {
          cooldown.value--;
        } else {
          timer.cancel();
          _cooldownTimer = null;
          runRestricted(
            param: param,
            coolDownSeconds: coolDownSeconds,
            immediatelyClearErrors: true,
            runWhen: runWhen,
          );
        }
      });
    }
  }

  Future<TResult?> runRestrictedAsync({
    TParam? param,
    bool immediatelyClearErrors = false,
    RunWhen runWhen = RunWhen.hasNoValueAndNoErrors,
    int coolDownSeconds = 20,
  }) async {
    if (immediatelyClearErrors) {
      this.clearErrors();
    }

    if (runWhen == RunWhen.hasNoValueAndNoErrors &&
        (value != null && errors.value == null)) {
      return value;
    }

    if (runWhen == RunWhen.paramChanges
        ? _paramHasChangedOrIsOnlyNull(param)
        : _hasNoValueAndNoErrors) {
      return runAsync(param);
    }

    if (errors.value != null && _cooldownTimer == null) {
      cooldown.value = coolDownSeconds;

      _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (
        timer,
      ) async {
        if (cooldown.isDisposed) {
          timer.cancel();
          _cooldownTimer = null;
          return;
        }

        if (cooldown.value > 0) {
          cooldown.value--;
        } else {
          timer.cancel();
          _cooldownTimer = null;

          await runRestrictedAsync(
            param: param,
            coolDownSeconds: coolDownSeconds,
            immediatelyClearErrors: true,
            runWhen: runWhen,
          );
        }
      });
    }
    return value;
  }

  bool get _hasValueAndNoErrors => value != null && errors.value == null;

  bool get _hasNoValueAndNoErrors => value == null && errors.value == null;

  bool _paramHasChangedOrIsOnlyNull(TParam? param) {
    final lastParam = this.results.value.paramData;

    if (param == null && lastParam == null) {
      return true;
    }

    return lastParam != param;
  }
}
