abstract final class FailedImageUrls {
  static final Map<String, int> _urls = {};

  static void add(String? url) {
    if (url != null && url.isNotEmpty) {
      var count = _urls[url] ?? 0;
      _urls[url] = count++;
    }
  }

  static bool contains(String? url) {
    final count = _urls[url] ?? 0;
    return count > 2;
  }
}
