class _FailedUrlRecord {
  _FailedUrlRecord({required this.count, required this.lastFailedAt});

  int count;
  DateTime lastFailedAt;
}

abstract final class FailedImageUrls {
  static final Map<String, _FailedUrlRecord> _records = {};

  /// Time after which a failed URL is given another chance to load.
  static const Duration cooldown = Duration(minutes: 5);

  /// Number of failures allowed before a URL is blocked until the cooldown expires.
  static const int maxFailures = 2;

  static void add(String? url) {
    if (url != null && url.isNotEmpty) {
      final now = DateTime.now();
      final record = _records[url];
      if (record != null) {
        if (now.difference(record.lastFailedAt) > cooldown) {
          record.count = 1;
        } else {
          record.count += 1;
        }
        record.lastFailedAt = now;
      } else {
        _records[url] = _FailedUrlRecord(count: 1, lastFailedAt: now);
      }
    }
  }

  static bool contains(String? url) {
    if (url == null || url.isEmpty) return false;
    final record = _records[url];
    if (record == null) return false;

    if (DateTime.now().difference(record.lastFailedAt) > cooldown) {
      _records.remove(url);
      return false;
    }

    return record.count > maxFailures;
  }

  static void remove(String? url) {
    if (url != null) {
      _records.remove(url);
    }
  }

  static void clear() => _records.clear();
}
