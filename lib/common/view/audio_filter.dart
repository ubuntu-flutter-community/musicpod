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
              ? compareNatural(b.artist!, a.artist!)
              : compareNatural(a.artist!, b.artist!);
        }
        return 0;
      });
    case AudioFilter.title:
      audios.sort((a, b) {
        if (a.title != null && b.title != null) {
          return descending
              ? compareNatural(b.title!, a.title!)
              : compareNatural(a.title!, b.title!);
        }
        return 0;
      });
    case AudioFilter.year:
      audios.sort((a, b) {
        if (a.year != null && b.year != null) {
          return descending
              ? b.year!.compareTo(a.year!)
              : a.year!.compareTo(b.year!);
        }
        return 0;
      });
    case AudioFilter.album:
      audios.sort((a, b) {
        if (a.album != null && b.album != null) {
          final albumComp = descending
              ? compareNatural(b.album!, a.album!)
              : compareNatural(a.album!, b.album!);
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
              ? compareNatural(b.genre!, a.genre!)
              : compareNatural(a.genre!, b.genre!);
        }
        return 0;
      });
  }
}
