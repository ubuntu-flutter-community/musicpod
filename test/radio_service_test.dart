import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:musicpod/common/data/audio.dart';
import 'package:musicpod/common/data/audio_type.dart';
import 'package:musicpod/common/persistence/database.dart';
import 'package:musicpod/radio/persistence/radio_dao.dart';
import 'package:musicpod/radio/radio_service.dart';

import 'radio_service_test.mocks.dart';

const Audio sixFortyStation = Audio(
  url: 'http://radio.6forty.com:8000/6forty',
  audioType: AudioType.radio,
);

@GenerateMocks([Database])
Future<void> main() async {
  late RadioService service;

  String? host;

  group('radio tests', () {
    setUpAll(() async {
      service = RadioService(dao: RadioDao(db: MockDatabase()));

      host = await service.connectToServer();
    });

    test('initRadioService', () {
      expect(host != null, true);
    });

    test('loadTags', () {
      expect(service.tags?.any((e) => e.name == 'metal'), true);
    });

    test('find6forty', () async {
      final result = await service.search(name: '6forty', limit: 10);
      expect(result?.isNotEmpty, true);
      expect(result?.any((e) => e.title?.contains('6forty') ?? false), true);
      expect(result?.any((e) => e.url == sixFortyStation.url), true);
    });

    test('findByName', () async {
      final result = await service.search(name: 'WDR', limit: 10);
      expect(result?.isNotEmpty, true);
      expect(
        result?.any((e) => e.title?.toLowerCase().contains('wdr') ?? false),
        true,
      );
    });

    test('findByCountry', () async {
      final result = await service.search(country: 'Germany', limit: 10);
      expect(result?.isNotEmpty, true);
    });

    test('findByTag', () async {
      final result = await service.search(tag: 'metal', limit: 10);
      expect(result?.isNotEmpty, true);
    });

    test('findByState', () async {
      final result = await service.search(state: 'nordrhein', limit: 10);
      expect(result?.isNotEmpty, true);
    });

    // a test to check if it throws an exception when the server is unavailable
    test('serverUnavailable', () async {
      final serviceWithInvalidHost = RadioService(
        dao: RadioDao(db: MockDatabase()),
      );
      try {
        await serviceWithInvalidHost.connectToServer(
          newHosts: ['http://invalidhost:8000'],
        );
      } catch (e) {
        expect(e, isA<RadioBrowserServerUnavailableException>());
      }
    });
  });
}
