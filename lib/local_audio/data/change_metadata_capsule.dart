import 'package:audio_metadata_reader/audio_metadata_reader.dart';

import '../../common/data/audio.dart';

class ChangeMetadataCapsule {
  const ChangeMetadataCapsule({
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

  bool textsAreDifferentToAudio(Audio audio) =>
      title != audio.title ||
      artist != audio.artist ||
      album != audio.album ||
      genre != audio.genre ||
      discTotal != audio.discTotal.toString() ||
      discNumber != audio.discNumber.toString() ||
      trackNumber != audio.trackNumber.toString() ||
      durationMs != audio.durationMs.toString() ||
      year != audio.year.toString();

  ChangeMetadataCapsule copyWith({
    String? title,
    String? artist,
    String? album,
    String? genre,
    String? discTotal,
    String? discNumber,
    String? trackNumber,
    String? durationMs,
    String? year,
    List<Picture>? pictures,
  }) {
    return ChangeMetadataCapsule(
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      genre: genre ?? this.genre,
      discTotal: discTotal ?? this.discTotal,
      discNumber: discNumber ?? this.discNumber,
      trackNumber: trackNumber ?? this.trackNumber,
      durationMs: durationMs ?? this.durationMs,
      year: year ?? this.year,
      pictures: pictures ?? this.pictures,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChangeMetadataCapsule &&
        other.title == title &&
        other.artist == artist &&
        other.album == album &&
        other.genre == genre &&
        other.discTotal == discTotal &&
        other.discNumber == discNumber &&
        other.trackNumber == trackNumber &&
        other.durationMs == durationMs &&
        other.year == year &&
        other.pictures == pictures;
  }

  @override
  int get hashCode {
    return Object.hash(
      title,
      artist,
      album,
      genre,
      discTotal,
      discNumber,
      trackNumber,
      durationMs,
      year,
      pictures,
    );
  }
}
