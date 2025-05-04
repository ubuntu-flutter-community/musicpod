import '../common/data/audio.dart';

extension StringExtension on String {
  String get capitalized {
    return isEmpty
        ? this
        : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  String get camelToSentence {
    return replaceAllMapped(
      RegExp(r'^([a-z])|[A-Z]'),
      (Match m) => m[1] == null ? ' ${m[0]}' : m[1]!.toUpperCase(),
    );
  }

  String get everyWordCapitalized {
    return split(' ').map((word) => word.capitalized).join(' ');
  }

  ({String? songName, String? artist}) get splitByDash {
    String? songName;
    String? artist;
    var split = this.split(' - ');
    if (split.isNotEmpty) {
      artist = split.elementAtOrNull(0);
      songName = split.elementAtOrNull(1);
      if (split.length == 3 && songName != null) {
        songName = songName + (split.elementAtOrNull(2) ?? '');
      }
    } else {
      split = this.split('-');
      if (split.isNotEmpty) {
        artist = split.elementAtOrNull(0);
        songName = split.elementAtOrNull(1);
        if (split.length == 3 && songName != null) {
          songName = songName + (split.elementAtOrNull(2) ?? '');
        }
      }
    }
    return (songName: songName, artist: artist);
  }

  String get albumOfId => (split(Audio.albumIdSplitter).lastOrNull ?? '')
      .replaceAll(Audio.albumIdReplacer, Audio.albumIdReplacement);
  String get artistOfId => (split(Audio.albumIdSplitter).firstOrNull ?? '')
      .replaceAll(Audio.albumIdReplacer, Audio.albumIdReplacement);
}

extension NullableStringX on String? {
  Duration? get parsedDuration {
    final durationAsString = this;
    if (durationAsString == null || durationAsString == 'null') return null;
    int hours = 0;
    int minutes = 0;
    int micros;
    final List<String> parts = durationAsString.split(':');
    if (parts.length > 2) {
      hours = int.parse(parts[parts.length - 3]);
    }
    if (parts.length > 1) {
      minutes = int.parse(parts[parts.length - 2]);
    }
    micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
    return Duration(hours: hours, minutes: minutes, microseconds: micros);
  }
}
