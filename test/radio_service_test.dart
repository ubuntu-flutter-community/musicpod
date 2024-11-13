import 'package:flutter_test/flutter_test.dart';
import 'package:musicpod/common/data/audio.dart';
import 'package:musicpod/radio/radio_service.dart';

const Audio sixFortyStation = Audio(
  url: 'http://radio.6forty.com:8000/6forty',
);

Future<void> main() async {
  final service = RadioService();
  String? host;
  setUp(() async {
    await service.init();
    host = service.connectedHost;
  });

  group('radio tests', () {
    test('initRadioService', () {
      expect(host != null, true);
    });

    test('loadTags', () {
      expect(service.tags?.any((e) => e.name == 'metal'), true);
    });

    test('find6forty', () async {
      final result = await service.search(
        name: '6forty',
        limit: 10,
      );
      expect(result?.isNotEmpty, true);
      expect(result?.any((e) => e.name.contains('6forty')), true);
      expect(
        result?.any((e) => e.urlResolved == sixFortyStation.url),
        true,
      );
    });

    test('findByName', () async {
      final result = await service.search(
        name: 'WDR',
        limit: 10,
      );
      expect(result?.isNotEmpty, true);
      expect(result?.any((e) => e.name.toLowerCase().contains('wdr')), true);
    });

    test('findByCountry', () async {
      final result = await service.search(
        country: 'Germany',
        limit: 10,
      );
      expect(result?.isNotEmpty, true);
    });

    test('findByTag', () async {
      final result = await service.search(
        tag: 'metal',
        limit: 10,
      );
      expect(result?.isNotEmpty, true);
    });

    test('findByState', () async {
      final result = await service.search(
        state: 'nordrhein',
        limit: 10,
      );
      expect(result?.isNotEmpty, true);
    });
  });
}
