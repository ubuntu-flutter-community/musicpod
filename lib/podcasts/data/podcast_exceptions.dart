class FindEpisodesTimeoutException implements Exception {
  final String? message;

  static const Duration timeoutDuration = Duration(seconds: 30);

  FindEpisodesTimeoutException({this.message});

  @override
  String toString() =>
      message ?? 'Timeout while fetching episodes for the podcast';
}

class PodcastSearchNotSuccessfulException implements Exception {
  @override
  String toString() =>
      'This podcast search was not successfull, are you connected to the internet? If yes this might be a server issue.';
}
