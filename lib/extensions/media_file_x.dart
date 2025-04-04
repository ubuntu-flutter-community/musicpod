import 'dart:io';

import 'package:mime/mime.dart';

extension MediaFileX on File {
  bool get isPlayable => path.isPlayable;
}

extension _ValidPathX on String {
  bool get isPlayable {
    final mime = lookupMimeType(this);
    return (mime?.contains('audio') ?? false) ||
        (mime?.contains('video') ?? false);
  }
}
