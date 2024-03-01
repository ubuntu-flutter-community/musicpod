import '../data/audio.dart';
import 'package:intl/intl.dart';

enum AudioFilter {
  trackNumber,
  title,
  artist,
  album,
  genre,
  year,
  diskNumber;
}

int _compareStrings(String a, String b) {
  final r = RegExp('\\d+');
  final f = NumberFormat('0' * 16);
  final aNew = a.replaceAllMapped(
    r,
    (match) => f.format(int.tryParse(match[0] ?? '0') ?? 0),
  );
  final bNew = b.replaceAllMapped(
    r,
    (match) => f.format(int.tryParse(match[0] ?? '0') ?? 0),
  );
  return aNew.compareTo(bNew);
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
              ? _compareStrings(b.artist!, a.artist!)
              : _compareStrings(a.artist!, b.artist!);
        }
        return 0;
      });
      break;
    case AudioFilter.title:
      audios.sort((a, b) {
        if (a.title != null && b.title != null) {
          return descending
              ? _compareStrings(b.title!, a.title!)
              : _compareStrings(a.title!, b.title!);
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
              ? _compareStrings(b.album!, a.album!)
              : _compareStrings(a.album!, b.album!);
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
    case AudioFilter.diskNumber:
      audios.sort(
        (a, b) {
          if (a.discNumber != null && b.discNumber != null) {
            return descending
                ? b.discNumber!.compareTo(a.discNumber!)
                : a.discNumber!.compareTo(b.discNumber!);
          }
          return 0;
        },
      );
      break;
    case AudioFilter.trackNumber:
      audios.sort((a, b) {
        if (a.trackNumber != null && b.trackNumber != null) {
          return descending
              ? b.trackNumber!.compareTo(a.trackNumber!)
              : a.trackNumber!.compareTo(b.trackNumber!);
        }
        return 0;
      });
      break;
    case AudioFilter.genre:
      audios.sort((a, b) {
        if (a.genre != null && b.genre != null) {
          return descending
              ? _compareStrings(b.genre!, a.genre!)
              : _compareStrings(a.genre!, b.genre!);
        }
        return 0;
      });
      break;
  }
}
