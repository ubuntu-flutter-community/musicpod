import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:music/app/local_audio/local_audio_model.dart';
import 'package:music/data/audio.dart';
import 'package:music/l10n/l10n.dart';

String formatTime(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final hours = twoDigits(duration.inHours);
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));

  return <String>[if (duration.inHours > 0) hours, minutes, seconds].join(':');
}

String createPlaylistName(
  String name,
  BuildContext context,
) {
  return name == 'likedAudio' ? context.l10n.likedSongs : name;
}

bool listsAreEqual(List<dynamic>? list1, List<dynamic>? list2) =>
    const ListEquality().equals(list1, list2);

void sortListByAudioFilter({
  required AudioFilter audioFilter,
  required List<Audio> audios,
}) {
  switch (audioFilter) {
    case AudioFilter.artist:
      audios.sort((a, b) {
        if (a.metadata != null &&
            a.metadata!.artist != null &&
            b.metadata != null &&
            b.metadata!.artist != null) {
          return a.metadata!.artist!.compareTo(b.metadata!.artist!);
        }
        return 0;
      });
      break;
    case AudioFilter.title:
      audios.sort((a, b) {
        if (a.metadata != null &&
            a.metadata!.title != null &&
            b.metadata != null &&
            b.metadata!.title != null) {
          return a.metadata!.title!.compareTo(b.metadata!.title!);
        }
        return 0;
      });
      break;
    case AudioFilter.album:
      audios.sort((a, b) {
        if (a.metadata != null &&
            a.metadata!.album != null &&
            b.metadata != null &&
            b.metadata!.album != null) {
          return a.metadata!.album!.compareTo(b.metadata!.album!);
        }
        return 0;
      });
      break;
    default:
      audios.sort((a, b) {
        if (a.metadata != null &&
            a.metadata!.trackNumber != null &&
            b.metadata != null &&
            b.metadata!.trackNumber != null) {
          return a.metadata!.trackNumber!.compareTo(b.metadata!.trackNumber!);
        }
        return 0;
      });
      break;
  }
}
