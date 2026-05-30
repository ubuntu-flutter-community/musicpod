import 'package:flutter/foundation.dart';
import 'package:lrc/lrc.dart';

import '../../common/data/audio.dart';

class LyricsAndArtResult {
  final String? lyricsString;
  final List<LrcLine>? lrcLines;
  final String? artUrl;

  const LyricsAndArtResult({
    required this.lyricsString,
    required this.lrcLines,
    required this.artUrl,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LyricsAndArtResult &&
        other.lyricsString == lyricsString &&
        listEquals(other.lrcLines, lrcLines) &&
        other.artUrl == artUrl;
  }

  @override
  int get hashCode => Object.hash(lyricsString, lrcLines, artUrl);
}

class LyricsAndArtParam {
  final Audio? audio;
  final String? title;
  final String? artist;

  const LyricsAndArtParam({
    required this.audio,
    required this.title,
    required this.artist,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LyricsAndArtParam &&
        other.audio == audio &&
        other.title == title &&
        other.artist == artist;
  }

  @override
  int get hashCode => Object.hash(audio, title, artist);
}
