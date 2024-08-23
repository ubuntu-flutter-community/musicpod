import 'dart:io';

extension MediaFileX on File {
  bool get isValidMedia => path.isValidPath;
}

extension MediaFileSystemEntityX on FileSystemEntity {
  bool get isValidMedia => path.isValidPath;
}

extension _ValidPathX on String {
  bool get isValidPath => _validMediaExtensions.any((e) => endsWith(e));
}

const _validMediaExtensions = [
  '.mp3',
  '.flac',
  '.mp4',
  '.opus',
  '.ogg',
];
