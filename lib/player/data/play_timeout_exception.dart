// ignore_for_file: unnecessary_parenthesis

class PlayTimeoutException implements Exception {
  static const Duration timeoutDuration = Duration(seconds: 15);

  @override
  String toString() => 'Failed to open media: Operation timed out';
}
