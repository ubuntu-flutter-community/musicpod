import 'dart:async';

import 'package:injectable/injectable.dart';

import 'data/retry_capsule.dart';

@lazySingleton
class RetryManager {
  Timer? _cooldownTimer;
  Timer? get cooldownTimer => _cooldownTimer;

  final _capsules = <String, RetryCapsule>{};
  RetryCapsule addRetry({
    required String retryViewId,
    required RetryCapsule capsule,
  }) => _capsules.putIfAbsent(retryViewId, () => capsule);

  void removeRetry({required String retryViewId}) =>
      _capsules.remove(retryViewId)?.timer?.cancel();
}
