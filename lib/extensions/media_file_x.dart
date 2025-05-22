import 'dart:io';

import 'package:mime/mime.dart';

final _resolver = MimeTypeResolver();

extension MediaFileX on File {
  bool get isPlayable => path.isPlayable;
}

extension _ValidPathX on String {
  bool get isPlayable {
    for (var v in _SpecialMimeTypes.values) {
      _resolver
        ..addExtension(v.extension, v.mimeType)
        ..addMagicNumber(v.headerBytes, v.mimeType);
    }

    final mime = _resolver.lookup(this);

    return (mime?.contains('audio') ?? false) ||
        (mime?.contains('video') ?? false);
  }
}

enum _SpecialMimeTypes {
  opusAudio;

  String get mimeType => switch (this) {
    opusAudio => 'audio/opus',
  };

  String get extension => switch (this) {
    opusAudio => 'opus',
  };

  List<int> get headerBytes => switch (this) {
    opusAudio => [
      0x4F, // O
      0x67, // g
      0x67, // g
      0x53, // S
    ],
  };
}
