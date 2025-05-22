import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:musicpod/common/data/audio.dart';
import 'package:musicpod/local_audio/local_cover_service.dart';
import 'package:musicpod/local_audio/local_audio_service.dart';

import 'local_audio_service_test.mocks.dart';

const Audio testMp3 = Audio(
  title: 'test',
  artist: 'musicpod',
  genre: 'Black Metal',
  album: 'podmusic',
);

const Audio testOgg = Audio(
  title: 'Cold Stones',
  artist: 'Backslash Zero',
  album: 'DEMO2017',
  genre: 'Rock',
);

@GenerateMocks([LocalCoverService])
Future<void> main() async {
  LocalAudioService? service;
  final localCoverService = MockLocalCoverService();

  setUpAll(() async {
    service = LocalAudioService(localCoverService: localCoverService);
    await service?.init(newDirectory: Directory.current.path);
  });

  group('test metadata', () {
    test('testTestMp3', () {
      final audios = service?.audios;
      expect(audios?.isNotEmpty, true);

      final testTestMp3 = audios?.firstWhereOrNull(
        (e) => e.path?.contains('test.mp3') == true,
      );
      expect(testTestMp3?.title, testMp3.title);
      expect(testTestMp3?.artist, testMp3.artist);
      expect(testTestMp3?.album, testMp3.album);
      expect(testTestMp3?.genre, testMp3.genre);
    });

    test('testTestOgg', () {
      final audios = service?.audios;
      expect(audios?.isNotEmpty, true);

      final coldStones = audios?.firstWhereOrNull(
        (e) => e.path?.contains('Backslash Zero') == true,
      );
      expect(coldStones?.title, testOgg.title);
      expect(coldStones?.artist, testOgg.artist);
      expect(coldStones?.album, testOgg.album);
      expect(coldStones?.genre, testOgg.genre);
    });
  });
}
