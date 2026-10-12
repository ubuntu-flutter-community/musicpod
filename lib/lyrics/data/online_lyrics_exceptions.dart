class FetchOnlineLyricsTimeoutException implements Exception {
  final String message;
  FetchOnlineLyricsTimeoutException(this.message);

  static const Duration timeoutDuration = Duration(seconds: 5);

  @override
  String toString() => 'FetchOnlineLyricsTimeoutException: $message';
}
