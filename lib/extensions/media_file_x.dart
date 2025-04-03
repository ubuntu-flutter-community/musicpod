import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:mime/mime.dart';

extension MediaFileX on File {
  bool get couldHaveMetadata => path.couldHaveMetadata;
  bool get isPlayable => path.isPlayable;
}

extension MediaFileSystemEntityX on FileSystemEntity {
  bool get couldHaveMetadata => path.couldHaveMetadata;
}

extension XFileX on XFile {
  bool get couldHaveMetadata => path.couldHaveMetadata;
  bool get isPlayable => path.isPlayable;
}

extension _ValidPathX on String {
  bool get couldHaveMetadata => _validMediaExtensions.any((e) => endsWith(e));
  bool get isPlayable =>
      (lookupMimeType(this)?.contains('audio') ?? false) ||
      (lookupMimeType(this)?.contains('video') ?? false);
}

const _validMediaExtensions = [
  '.mp3',
  '.flac',
  '.mp4',
  '.opus',
  '.ogg',
  '.m4a',
];
