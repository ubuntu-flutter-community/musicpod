import 'dart:convert';

import 'package:flutter/services.dart';

class Audio {
  /// The local path if available.
  final String? path;

  /// The remote URL if available.
  final String? url;

  /// The [AudioType]
  final AudioType? audioType;

  /// The url of the image if available.
  final String? imageUrl;

  /// Optional description of the audio.
  final String? description;

  /// Website link or feed url.
  final String? website;

  /// The ID3-Tag title of the audio file.
  final String? title;

  /// The ID3-Tag duration of the audio file. It can be null if was not set
  final double? durationMs;

  /// The ID3-Tag artist(s) of the audio file.
  final String? artist;

  /// The ID3-Tag album of the audio file.
  final String? album;

  /// The ID3-Tag album artist(s) of the audio file.
  final String? albumArtist;

  /// The ID3-Tag track number of the audio file.
  final int? trackNumber;

  /// The ID3-Tag track total of the audio file.
  final int? trackTotal;

  /// The ID3-Tag discNumber of the audio file.
  final int? discNumber;

  /// The ID3-Tag discTotal of the audio file.
  final int? discTotal;

  /// The ID3-Tag year the track was released
  final int? year;

  /// The ID3-Tag genre of the track
  final String? genre;

  /// The ID3-Tag picture's MIME type.
  final String? pictureMimeType;

  /// The ID3-Tag image data.
  final Uint8List? pictureData;

  /// The ID3-Tag file size of the audio file
  final int? fileSize;

  /// Optional art that belongs to parent element
  final String? albumArtUrl;

  Audio({
    this.path,
    this.url,
    this.audioType,
    this.imageUrl,
    this.description,
    this.website,
    this.title,
    this.durationMs,
    this.artist,
    this.album,
    this.albumArtist,
    this.trackNumber,
    this.trackTotal,
    this.discNumber,
    this.discTotal,
    this.year,
    this.genre,
    this.pictureMimeType,
    this.pictureData,
    this.fileSize,
    this.albumArtUrl,
  });

  Audio copyWith({
    String? path,
    String? url,
    String? name,
    AudioType? audioType,
    String? imageUrl,
    String? description,
    String? website,
    String? title,
    double? durationMs,
    String? artist,
    String? album,
    String? albumArtist,
    int? trackNumber,
    int? trackTotal,
    int? discNumber,
    int? discTotal,
    int? year,
    String? genre,
    String? pictureMimeType,
    Uint8List? pictureData,
    int? fileSize,
    String? albumArtUrl,
  }) {
    return Audio(
      path: path ?? this.path,
      url: url ?? this.url,
      audioType: audioType ?? this.audioType,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      website: website ?? this.website,
      title: title ?? this.title,
      durationMs: durationMs ?? this.durationMs,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      albumArtist: albumArtist ?? this.albumArtist,
      trackNumber: trackNumber ?? this.trackNumber,
      trackTotal: trackTotal ?? this.trackTotal,
      discNumber: discNumber ?? this.discNumber,
      discTotal: discTotal ?? this.discTotal,
      year: year ?? this.year,
      genre: genre ?? this.genre,
      pictureMimeType: pictureMimeType ?? this.pictureMimeType,
      pictureData: pictureData ?? this.pictureData,
      fileSize: fileSize ?? this.fileSize,
      albumArtUrl: albumArtUrl ?? this.albumArtUrl,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    if (path != null) {
      result.addAll({'path': path});
    }
    if (url != null) {
      result.addAll({'url': url});
    }
    if (audioType != null) {
      result.addAll({'audioType': audioType!.name});
    }
    if (imageUrl != null) {
      result.addAll({'imageUrl': imageUrl});
    }
    if (description != null) {
      result.addAll({'description': description});
    }
    if (website != null) {
      result.addAll({'website': website});
    }
    if (title != null) {
      result.addAll({'title': title});
    }
    if (durationMs != null) {
      result.addAll({'durationMs': durationMs});
    }
    if (artist != null) {
      result.addAll({'artist': artist});
    }
    if (album != null) {
      result.addAll({'album': album});
    }
    if (albumArtist != null) {
      result.addAll({'albumArtist': albumArtist});
    }
    if (trackNumber != null) {
      result.addAll({'trackNumber': trackNumber});
    }
    if (trackTotal != null) {
      result.addAll({'trackTotal': trackTotal});
    }
    if (discNumber != null) {
      result.addAll({'discNumber': discNumber});
    }
    if (discTotal != null) {
      result.addAll({'discTotal': discTotal});
    }
    if (year != null) {
      result.addAll({'year': year});
    }
    if (genre != null) {
      result.addAll({'genre': genre});
    }
    if (pictureMimeType != null) {
      result.addAll({'pictureMimeType': pictureMimeType});
    }
    if (pictureData != null) {
      result.addAll({'pictureData': base64Encode(pictureData!)});
    }
    if (fileSize != null) {
      result.addAll({'fileSize': fileSize});
    }
    if (albumArtUrl != null) {
      result.addAll({'albumArtUrl': albumArtUrl});
    }

    return result;
  }

  factory Audio.fromMap(Map<String, dynamic> map) {
    return Audio(
      path: map['path'],
      url: map['url'],
      audioType: map['audioType'] != null
          ? AudioType.values.byName(map['audioType'])
          : null,
      imageUrl: map['imageUrl'],
      description: map['description'],
      website: map['website'],
      title: map['title'],
      durationMs: map['durationMs']?.toDouble(),
      artist: map['artist'],
      album: map['album'],
      albumArtist: map['albumArtist'],
      trackNumber: map['trackNumber']?.toInt(),
      trackTotal: map['trackTotal']?.toInt(),
      discNumber: map['discNumber']?.toInt(),
      discTotal: map['discTotal']?.toInt(),
      year: map['year']?.toInt(),
      genre: map['genre'],
      pictureMimeType: map['pictureMimeType'],
      pictureData:
          map['pictureData'] != null ? base64Decode(map['pictureData']) : null,
      fileSize: map['fileSize']?.toInt(),
      albumArtUrl: map['albumArtUrl'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Audio.fromJson(String source) => Audio.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Audio(path: $path, url: $url,  audioType: $audioType, imageUrl: $imageUrl, description: $description, website: $website, title: $title, durationMs: $durationMs, artist: $artist, album: $album, albumArtist: $albumArtist, trackNumber: $trackNumber, trackTotal: $trackTotal, discNumber: $discNumber, discTotal: $discTotal, year: $year, genre: $genre, pictureMimeType: $pictureMimeType, pictureData: $pictureData, fileSize: $fileSize, albumArtUrl: $albumArtUrl)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Audio &&
        (other.path == path ||
            (other.url == url && other.path != null) ||
            other.url == url) &&
        other.audioType == audioType &&
        other.imageUrl == imageUrl &&
        other.description == description &&
        other.website == website &&
        other.title == title &&
        other.durationMs == durationMs &&
        other.artist == artist &&
        other.album == album &&
        other.albumArtist == albumArtist &&
        other.trackNumber == trackNumber &&
        other.trackTotal == trackTotal &&
        other.discNumber == discNumber &&
        other.discTotal == discTotal &&
        other.year == year &&
        other.genre == genre &&
        other.pictureMimeType == pictureMimeType &&
        other.fileSize == fileSize &&
        other.albumArtUrl == albumArtUrl;
  }

  @override
  int get hashCode {
    return path.hashCode ^
        url.hashCode ^
        audioType.hashCode ^
        imageUrl.hashCode ^
        description.hashCode ^
        website.hashCode ^
        title.hashCode ^
        durationMs.hashCode ^
        artist.hashCode ^
        album.hashCode ^
        albumArtist.hashCode ^
        trackNumber.hashCode ^
        trackTotal.hashCode ^
        discNumber.hashCode ^
        discTotal.hashCode ^
        year.hashCode ^
        genre.hashCode ^
        pictureMimeType.hashCode ^
        fileSize.hashCode ^
        albumArtUrl.hashCode;
  }
}

enum AudioType {
  local,
  radio,
  podcast;
}
