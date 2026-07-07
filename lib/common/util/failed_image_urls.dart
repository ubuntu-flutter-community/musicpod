/// A process-wide registry of image URLs that are known to be unreachable
/// (e.g. returned a 404 or another load error).
///
/// It is used to avoid retrying broken artwork, both in the UI
/// (`SafeNetworkImage`) and when handing an `artUri` to the OS media controls
/// via `audio_service` (which would otherwise print noisy load errors).
abstract final class FailedImageUrls {
  static final Set<String> _urls = <String>{};

  /// Marks [url] as failed so future loads can be skipped.
  static void add(String? url) {
    if (url != null && url.isNotEmpty) {
      _urls.add(url);
    }
  }

  /// Whether [url] has previously failed to load.
  static bool contains(String? url) => url != null && _urls.contains(url);
}
