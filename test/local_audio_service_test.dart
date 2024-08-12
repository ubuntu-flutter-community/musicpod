import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musicpod/common/data/audio.dart';
import 'package:musicpod/local_audio/local_audio_service.dart';
import 'package:musicpod/settings/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final service = LocalAudioService(
    settingsService: SettingsService(sharedPreferences: prefs),
  );
  await service.init(directory: Directory.current.path);

  group('test metadata', () {
    test('testTestMp3', () {
      final audios = service.audios;
      expect(audios?.isNotEmpty, true);

      final testTestMp3 =
          audios?.firstWhereOrNull((e) => e.path?.contains('test.mp3') == true);
      expect(testTestMp3?.title, testMp3.title);
      expect(testTestMp3?.artist, testMp3.artist);
      expect(testTestMp3?.album, testMp3.album);
      expect(testTestMp3?.genre, testMp3.genre);
    });

    test('testTestOgg', () {
      final audios = service.audios;
      expect(audios?.isNotEmpty, true);

      final coldStones = audios
          ?.firstWhereOrNull((e) => e.path?.contains('Backslash Zero') == true);
      expect(coldStones?.title, testOgg.title);
      expect(coldStones?.artist, testOgg.artist);
      expect(coldStones?.album, testOgg.album);
      expect(coldStones?.genre, testOgg.genre);
    });
  });
}
