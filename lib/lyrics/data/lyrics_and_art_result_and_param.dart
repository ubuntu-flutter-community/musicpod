import 'package:flutter/foundation.dart';
import 'package:lrc/lrc.dart';

import '../../common/data/audio.dart';

class LyricsAndArtResult {
  final String? plainLyrics;
  final List<LrcLine>? lrcLines;
  final String? artUrl;

  const LyricsAndArtResult({
    required this.plainLyrics,
    required this.lrcLines,
    required this.artUrl,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LyricsAndArtResult &&
        other.plainLyrics == plainLyrics &&
        listEquals(other.lrcLines, lrcLines) &&
        other.artUrl == artUrl;
  }

  @override
  int get hashCode => Object.hash(plainLyrics, lrcLines, artUrl);
}

class LyricsAndArtParam {
  final Audio? audio;
  final String? title;
  final String? artist;
  final bool tryToFetchOnline;

  const LyricsAndArtParam({
    required this.audio,
    required this.title,
    required this.artist,
    this.tryToFetchOnline = true,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LyricsAndArtParam &&
        other.audio == audio &&
        other.title == title &&
        other.artist == artist &&
        other.tryToFetchOnline == tryToFetchOnline;
  }

  @override
  int get hashCode => Object.hash(audio, title, artist, tryToFetchOnline);
}
