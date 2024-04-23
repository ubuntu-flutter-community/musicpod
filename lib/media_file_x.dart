import 'dart:io';

import 'package:mime/mime.dart';

/// TODO: either guarantee that downloads are saved with the correct extension or manage to detect files without file extensions via magic bytes

extension MediaFileX on File {
  bool get isValidMedia => path.isValidPath;
}

extension MediaFileSystemEntityX on FileSystemEntity {
  bool get isValidMedia => path.isValidPath;
}

extension _ValidPathX on String {
  /// | Bytes | extension | Description |
  /// |:--|:--|:--|
  /// |`49 44 33`| `.mp3` |MP3 file with an ID3v2 container|
  /// |`FF FB / FF F3 / FF F2`|`.mp3`|MPEG-1 Layer 3 file without an ID3 tag or with an ID3v1 tag (which is appended at the end of the file)|
  /// |`4F 67 67 53`| `.ogg`, `.oga`, `.ogv` | Ogg, an open source media container format |
  /// |`66 4C 61 43`| `.flac` | Free Lossless Audio Codec |
  /// |`66 74 79 70 69 73 6F 6D`| `mp4`| 	ISO Base Media file (MPEG-4)|
  /// |`66 74 79 70 4D 53 4E 56`| `mp4`| 	MPEG-4 video file|
  bool get isValidPath {
    final mime = lookupMimeType(this);
    return mime?.startsWith('audio') == true ||
        mime?.startsWith('video') == true ||
        _validMediaExtensions.any((e) => endsWith(e));
  }
}

const _validMediaExtensions = [
  '.mp3',
  '.flac',
  '.mp4',
  '.opus',
  '.ogg',
  '.m4a',
  '.aac',
];
