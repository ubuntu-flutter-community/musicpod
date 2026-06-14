class RetryCapsule {
  const RetryCapsule({
    required this.onRetry,
    required this.retryViewId,
    this.retries = 1,
    this.autoRetry = true,
    this.autoIncrementCooldown = true,
  });

  final String retryViewId;
  final dynamic Function() onRetry;
  final int retries;
  final bool autoRetry;
  final bool autoIncrementCooldown;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RetryCapsule &&
          retryViewId == other.retryViewId &&
          autoRetry == other.autoRetry &&
          autoIncrementCooldown == other.autoIncrementCooldown;

  @override
  int get hashCode =>
      Object.hash(retryViewId, autoRetry, autoIncrementCooldown);

  RetryCapsule copyWith({
    dynamic Function()? onRetry,
    int? retries,
    bool? autoRetry,
    bool? autoIncrementCooldown,
  }) {
    return RetryCapsule(
      retryViewId: this.retryViewId,
      onRetry: onRetry ?? this.onRetry,
      retries: retries ?? this.retries,
      autoRetry: autoRetry ?? this.autoRetry,
      autoIncrementCooldown:
          autoIncrementCooldown ?? this.autoIncrementCooldown,
    );
  }
}
