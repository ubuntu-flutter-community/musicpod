import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:musicpod/extensions/media_file_x.dart';

void main() {
  group('MediaFileX.isPlayable', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('media_file_x_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('should return true for regular audio files', () async {
      // Create a mock mp3 file (with proper mp3 header)
      final mp3File = File('${tempDir.path}/song.mp3');
      // MP3 files start with ID3 tag or sync word (0xFFE)
      await mp3File.writeAsBytes([0xFF, 0xFB, 0x90, 0x00]);

      expect(mp3File.isPlayable, isTrue);
    });

    test('should return false for macOS dot underscore hidden files', () async {
      // Create a macOS hidden file (._filename.mp3)
      final macHiddenFile = File('${tempDir.path}/._song.mp3');
      await macHiddenFile.writeAsBytes([0x00, 0x00, 0x00, 0x00]);

      expect(macHiddenFile.isPlayable, isFalse);
    });

    test('should return false for other hidden files like .DS_Store', () async {
      // Create a .DS_Store file
      final dsStoreFile = File('${tempDir.path}/.DS_Store');
      await dsStoreFile.writeAsBytes([0x00, 0x00, 0x00, 0x01]);

      expect(dsStoreFile.isPlayable, isFalse);
    });

    test('should return false for non-media files', () async {
      // Create a text file
      final textFile = File('${tempDir.path}/readme.txt');
      await textFile.writeAsString('This is a test file');

      expect(textFile.isPlayable, isFalse);
    });

    test('should handle files with paths containing directories', () async {
      // Create a file in a subdirectory with dot underscore name
      final subDir = Directory('${tempDir.path}/Music');
      await subDir.create();

      final macHiddenFile = File('${subDir.path}/._hidden.mp3');
      await macHiddenFile.writeAsBytes([0xFF, 0xFB, 0x90, 0x00]);

      expect(macHiddenFile.isPlayable, isFalse);
    });
  });
}
