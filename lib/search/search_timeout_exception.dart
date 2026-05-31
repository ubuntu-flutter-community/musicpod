class SearchTimeoutException implements Exception {
  static const searchTimeoutSeconds = 20;

  @override
  String toString() =>
      'The search is taking longer than usual. This might be due to a server issue or a problem with your internet connection.';
}
