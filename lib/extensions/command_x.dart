import 'dart:async';

import 'package:flutter_it/flutter_it.dart';

enum RunWhen { paramChanges, hasNoValueAndNoErrors }

extension CommandX<TParam, TResult> on Command<TParam, TResult> {
  void runRestricted({
    TParam? param,
    bool immediatelyClearErrors = false,
    RunWhen runWhen = RunWhen.hasNoValueAndNoErrors,
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
