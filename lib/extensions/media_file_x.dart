import 'dart:io';

import 'package:mime/mime.dart';

extension MediaFileX on File {
  bool get isPlayable => path.isPlayable;
}

extension _ValidPathX on String {
  bool get blocked => _blockedExtensions.any((e) => endsWith(e));
  bool get isPlayable =>
      !blocked && (lookupMimeType(this)?.contains('audio') ?? false) ||
      (lookupMimeType(this)?.contains('video') ?? false);
}

const _blockedExtensions = [
  '.ogg',
];
