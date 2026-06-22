class RetryCapsule {
  const RetryCapsule({
    required this.onRetry,
    required this.retryViewId,
    this.retries = 1,
    this.autoRetry = true,
    this.autoIncrementCooldown = true,
    this.cooldownMaxValue = 60,
    this.cooldownStartValue = 5,
  });

  final String retryViewId;
  final dynamic Function() onRetry;
  final int retries;
  final bool autoRetry;
  final bool autoIncrementCooldown;
  final int cooldownStartValue;

  /// If 0, there is no max cooldown value.
  final int cooldownMaxValue;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RetryCapsule && retryViewId == other.retryViewId;

  @override
  int get hashCode => retryViewId.hashCode;

  RetryCapsule copyWith({
    dynamic Function()? onRetry,
    int? retries,
    bool? autoRetry,
    bool? autoIncrementCooldown,
    int? cooldownStartValue,
    int? cooldownMaxValue,
  }) {
    return RetryCapsule(
      retryViewId: this.retryViewId,
      onRetry: onRetry ?? this.onRetry,
      retries: retries ?? this.retries,
      autoRetry: autoRetry ?? this.autoRetry,
      autoIncrementCooldown:
          autoIncrementCooldown ?? this.autoIncrementCooldown,
      cooldownStartValue: cooldownStartValue ?? this.cooldownStartValue,
      cooldownMaxValue: cooldownMaxValue ?? this.cooldownMaxValue,
    );
  }
}
