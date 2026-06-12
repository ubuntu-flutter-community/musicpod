class RetryCapsule {
  const RetryCapsule({
    required this.onRetry,
    required this.retryViewId,
    this.retries = 1,
    this.autoRetry = true,
  });

  final String retryViewId;
  final dynamic Function() onRetry;
  final int retries;
  final bool autoRetry;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RetryCapsule &&
          retryViewId == other.retryViewId &&
          autoRetry == other.autoRetry;

  @override
  int get hashCode => Object.hash(retryViewId, autoRetry);

  RetryCapsule copyWith({
    dynamic Function()? onRetry,
    int? retries,
    bool? autoRetry,
  }) {
    return RetryCapsule(
      retryViewId: this.retryViewId,
      onRetry: onRetry ?? this.onRetry,
      retries: retries ?? this.retries,
      autoRetry: autoRetry ?? this.autoRetry,
    );
  }
}
