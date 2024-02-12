import '../data/audio.dart';

enum AudioFilter {
  trackNumber,
  title,
  artist,
  album,
  genre,
  year,
  diskNumber;
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
              ? b.artist!.compareTo(a.artist!)
              : a.artist!.compareTo(b.artist!);
        }
        return 0;
      });
      break;
    case AudioFilter.title:
      audios.sort((a, b) {
        if (a.title != null && b.title != null) {
          return descending
              ? b.title!.compareTo(a.title!)
              : a.title!.compareTo(b.title!);
        }
        return 0;
      });
      break;
    case AudioFilter.year:
      audios.sort((a, b) {
        if (a.year != null && b.year != null) {
          return descending
              ? b.year!.compareTo(a.year!)
              : a.year!.compareTo(b.year!);
        }
        return 0;
      });
      break;
    case AudioFilter.album:
      audios.sort((a, b) {
        if (a.album != null && b.album != null) {
          final albumComp = descending
              ? b.album!.compareTo(a.album!)
              : a.album!.compareTo(b.album!);
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
      break;
    default:
      audios.sort((a, b) {
        if (a.trackNumber != null && b.trackNumber != null) {
          return descending
              ? b.trackNumber!.compareTo(a.trackNumber!)
              : a.trackNumber!.compareTo(b.trackNumber!);
        }
        return 0;
      });
      break;
  }
}
