import 'package:collection/collection.dart';

import '../data/audio.dart';

enum AudioFilter { trackNumber, title, artist, album, genre, year, diskNumber }

Iterable<Audio> splitByDiscs(Iterable<Audio> audios) {
  final discNumbers = <int>{};
  for (var a in audios) {
    if (a.discNumber != null) {
      discNumbers.add(a.discNumber!);
    }
  }

  audios = discNumbers.isEmpty
      ? audios
      : [
          for (var d in discNumbers.sorted((a, b) => a.compareTo(b)))
            ...audios.where((e) => e.discNumber == d),
        ];
  return audios;
}

int _compareCaseInsensitive(String a, String b) {
  return compareNatural(a.toLowerCase(), b.toLowerCase());
}

void sortListByAudioFilter({
  required AudioFilter audioFilter,
  required List<Audio> audios,
  bool descending = false,
}) {
  switch (audioFilter) {
    case AudioFilter.artist:
      audios.sort((a, b) {
        if (a.artist != null && b.artist != null) {
          return descending
              ? _compareCaseInsensitive(b.artist!, a.artist!)
              : _compareCaseInsensitive(a.artist!, b.artist!);
        }
        return 0;
      });
    case AudioFilter.title:
      audios.sort((a, b) {
        if (a.title != null && b.title != null) {
          return descending
              ? _compareCaseInsensitive(b.title!, a.title!)
              : _compareCaseInsensitive(a.title!, b.title!);
        }
        return 0;
      });
    case AudioFilter.year:
      audios.sort((a, b) {
        final aYear = a.year ?? a.publicationDate;
        final bYear = b.year ?? b.publicationDate;
        if (aYear != null && bYear != null) {
          return descending ? bYear.compareTo(aYear) : aYear.compareTo(bYear);
        }
        return 0;
      });
    case AudioFilter.album:
      audios.sort((a, b) {
        if (a.album != null && b.album != null) {
          final albumComp = descending
              ? _compareCaseInsensitive(b.album!, a.album!)
              : _compareCaseInsensitive(a.album!, b.album!);
          if (albumComp == 0 &&
              a.trackNumber != null &&
              b.trackNumber != null) {
            final trackComp = a.trackNumber!.compareTo(b.trackNumber!);

            return trackComp;
          }
          return albumComp;
        }
        return 0;
      });
    case AudioFilter.diskNumber:
      audios = List.from(splitByDiscs(audios));
    case AudioFilter.trackNumber:
      audios.sort((a, b) {
        if (a.trackNumber != null && b.trackNumber != null) {
          return descending
              ? b.trackNumber!.compareTo(a.trackNumber!)
              : a.trackNumber!.compareTo(b.trackNumber!);
        }
        return 0;
      });
    case AudioFilter.genre:
      audios.sort((a, b) {
        if (a.genre != null && b.genre != null) {
          return descending
              ? _compareCaseInsensitive(b.genre!, a.genre!)
              : _compareCaseInsensitive(a.genre!, b.genre!);
        }
        return 0;
      });
  }
}
