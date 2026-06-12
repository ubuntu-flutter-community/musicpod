import 'dart:async';

import 'package:safe_change_notifier/safe_change_notifier.dart';

class RetryCapsule {
  RetryCapsule({required this.onRetry, this.cooldownStartValue = 20}) {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      this.timer = timer;
      if (cooldown.value > 0) {
        cooldown.value--;
      } else {
        cooldown.value = cooldownStartValue;
        onRetry();
      }
    });
  }

  final int cooldownStartValue;

  Timer? timer;
  final dynamic Function() onRetry;
  final SafeValueNotifier<int> cooldown = SafeValueNotifier<int>(20);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RetryCapsule && onRetry == other.onRetry;

  @override
  int get hashCode => onRetry.hashCode;
}
