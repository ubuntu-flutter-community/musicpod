class PlayAudiosByIdTimeoutException implements Exception {
  final String pageId;

  static const Duration timeoutDuration = Duration(seconds: 10);

  PlayAudiosByIdTimeoutException(this.pageId);

  @override
  String toString() => 'PlayAudiosByIdTimeoutException: $pageId';
}
