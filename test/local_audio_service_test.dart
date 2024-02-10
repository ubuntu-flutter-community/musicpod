// import 'dart:ffi';
// import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:musicpod/data.dart';
// import 'package:musicpod/local_audio.dart';

const Audio testAudio = Audio(
  title: 'test',
  artist: 'musicpod',
  genre: 'Black Metal',
  album: 'podmusic',
);

Future<void> main() async {
  // TODO: find a way to test native
  // final service = LocalAudioService();
  // await service.init(testDir: Directory.current.path);

  test('testTestMp3', () {
    // final audios = service.audios;
    // expect(audios?.isNotEmpty, true);
    // expect(audios?.first.title, testAudio.title);
    // expect(audios?.first.artist, testAudio.artist);
    // expect(audios?.first.genre, testAudio.genre);
    // expect(audios?.first.album, testAudio.album);
  });
}
