import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:musicpod/data.dart';
import 'package:musicpod/local_audio.dart';
import 'package:musicpod/settings.dart';

import 'local_audio_service_test.mocks.dart';

@GenerateMocks([SettingsService])
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
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final service = LocalAudioService(
    settingsService: MockSettingsService(),
  );
  await service.init(testDir: Directory.current.path);

  test('testTestMp3', () {
    final audios = service.audios;
    expect(audios?.isNotEmpty, true);

    final testTestMp3 =
        audios?.firstWhere((e) => e.path?.contains('test.mp3') == true);
    expect(audios?.first.title, testTestMp3?.title);
    expect(audios?.first.artist, testTestMp3?.artist);
    expect(audios?.first.genre, testTestMp3?.genre);
    expect(audios?.first.album, testTestMp3?.album);
  });

  test('testTestOgg', () {
    final audios = service.audios;
    expect(audios?.isNotEmpty, true);

    final coldStones =
        audios?.firstWhere((e) => e.path?.contains('Backslash Zero') == true);
    expect(audios?.last.title, coldStones?.title);
    expect(audios?.last.artist, coldStones?.artist);
    expect(audios?.last.album, coldStones?.album);
  });
}
