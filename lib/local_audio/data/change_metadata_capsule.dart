import 'package:audio_metadata_reader/audio_metadata_reader.dart';

import '../../common/data/audio.dart';

class ChangeMetadataCapsule {
  const ChangeMetadataCapsule({
    required this.audio,
    this.title,
    this.artist,
    this.album,
    this.genre,
    this.discTotal,
    this.discNumber,
    this.trackNumber,
    this.durationMs,
    this.year,
    this.pictures,
  });

  final Audio audio;
  final String? title;
  final String? artist;
  final String? album;
  final String? genre;
  final String? discTotal;
  final String? discNumber;
  final String? trackNumber;
  final String? durationMs;
  final String? year;
  final List<Picture>? pictures;
}
