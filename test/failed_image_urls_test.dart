import 'package:flutter_test/flutter_test.dart';
import 'package:musicpod/common/util/failed_image_urls.dart';

void main() {
  setUp(() {
    FailedImageUrls.clear();
  });

  group('FailedImageUrls', () {
    test('contains returns false for unadded, null, or empty urls', () {
      expect(FailedImageUrls.contains(null), isFalse);
      expect(FailedImageUrls.contains(''), isFalse);
      expect(FailedImageUrls.contains('https://example.com/test.png'), isFalse);
    });

    test('blocks url only after exceeding maxFailures (count > 2)', () {
      const url = 'https://example.com/podcast.jpg';

      FailedImageUrls.add(url);
      expect(FailedImageUrls.contains(url), isFalse);

      FailedImageUrls.add(url);
      expect(FailedImageUrls.contains(url), isFalse);

      FailedImageUrls.add(url);
      expect(FailedImageUrls.contains(url), isTrue);
    });

    test('remove allows url to be retried', () {
      const url = 'https://example.com/podcast.jpg';

      FailedImageUrls.add(url);
      FailedImageUrls.add(url);
      FailedImageUrls.add(url);
      expect(FailedImageUrls.contains(url), isTrue);

      FailedImageUrls.remove(url);
      expect(FailedImageUrls.contains(url), isFalse);
    });

    test('clear resets all recorded urls', () {
      const url1 = 'https://example.com/1.jpg';
      const url2 = 'https://example.com/2.jpg';

      for (var i = 0; i < 3; i++) {
        FailedImageUrls.add(url1);
        FailedImageUrls.add(url2);
      }

      expect(FailedImageUrls.contains(url1), isTrue);
      expect(FailedImageUrls.contains(url2), isTrue);

      FailedImageUrls.clear();

      expect(FailedImageUrls.contains(url1), isFalse);
      expect(FailedImageUrls.contains(url2), isFalse);
    });

    test('handles null and empty strings gracefully in add, remove, contains', () {
      FailedImageUrls.add(null);
      FailedImageUrls.add('');
      expect(FailedImageUrls.contains(null), isFalse);
      expect(FailedImageUrls.contains(''), isFalse);

      FailedImageUrls.remove(null);
      FailedImageUrls.remove('');
    });
  });
}
