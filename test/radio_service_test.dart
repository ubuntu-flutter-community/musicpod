import 'package:flutter_test/flutter_test.dart';
import 'package:media_kit/media_kit.dart';
import 'package:mockito/annotations.dart';
import 'package:musicpod/common/data/audio.dart';
import 'package:musicpod/expose/expose_service.dart';
import 'package:musicpod/player/player_service.dart';
import 'package:musicpod/radio/online_art_service.dart';
import 'package:musicpod/radio/radio_service.dart';

import 'radio_service_test.mocks.dart';

const Audio sixFortyStation = Audio(url: 'http://radio.6forty.com:8000/6forty');

@GenerateMocks([PlayerService, ExposeService, OnlineArtService, Player])
Future<void> main() async {
  late MockPlayerService mockPlayerService;
  late RadioService service;

  String? host;

  group('radio tests', () {
    setUpAll(() async {
      mockPlayerService = MockPlayerService();

      service = RadioService(
        playerService: mockPlayerService,
        exposeService: MockExposeService(),
        onlineArtService: MockOnlineArtService(),
      );

      await service.init(observePlayer: false);
      host = service.connectedHost;
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
      expect(result?.any((e) => e.name.contains('6forty')), true);
      expect(result?.any((e) => e.urlResolved == sixFortyStation.url), true);
    });

    test('findByName', () async {
      final result = await service.search(name: 'WDR', limit: 10);
      expect(result?.isNotEmpty, true);
      expect(result?.any((e) => e.name.toLowerCase().contains('wdr')), true);
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
  });
}
