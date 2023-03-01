import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
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
