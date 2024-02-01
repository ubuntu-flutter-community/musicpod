import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:musicpod/local_audio.dart';

Future<void> main() async {
  DynamicLibrary.open('test/libmetadata_god.so');

  final service = LocalAudioService();
  await service.init(dir: '/home/frederik/Projects/musicpod/test');

  test('testTestmp3', () {
    expect(service.audios?.isNotEmpty, true);
  });
}
