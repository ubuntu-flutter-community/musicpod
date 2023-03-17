import 'dart:convert';

import 'package:metadata_god/metadata_god.dart';

class Audio {
  final String? path;
  final String? url;
  final String? name;
  final AudioType? audioType;

  /// The url of the image if available.
  final String? imageUrl;

  /// Optional description of the audio.
  final String? description;

  /// Website link or feed url.
  final String? website;

  /// The title of the audio file.
  final String? title;

  /// Duration of the audio file. It can be null if was not set
  final double? durationMs;

  /// The artist(s) of the audio file.
  final String? artist;

  /// The album of the audio file.
  final String? album;

  /// The album artist(s) of the audio file.
  final String? albumArtist;

  final int? trackNumber;
  final int? trackTotal;
  final int? discNumber;
  final int? discTotal;

  /// The year the track was released
  final int? year;

  /// The genre of the track
  final String? genre;

  /// The attached album-art image data with [mimeType]
  final Image? picture;

  /// The file size of the audio file
  final int? fileSize;

  Audio({
    this.path,
    this.url,
    this.name,
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
    this.picture,
    this.fileSize,
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
    Image? picture,
    int? fileSize,
  }) {
    return Audio(
      path: path ?? this.path,
      url: url ?? this.url,
      name: name ?? this.name,
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
      picture: picture ?? this.picture,
      fileSize: fileSize ?? this.fileSize,
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
    if (name != null) {
      result.addAll({'name': name});
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

    if (fileSize != null) {
      result.addAll({'fileSize': fileSize});
    }

    return result;
  }

  factory Audio.fromMap(Map<String, dynamic> map) {
    return Audio(
      path: map['path'],
      url: map['url'],
      name: map['name'],
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
      fileSize: map['fileSize']?.toInt(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Audio.fromJson(String source) => Audio.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Audio(path: $path, url: $url, name: $name, audioType: $audioType, imageUrl: $imageUrl, description: $description, website: $website, title: $title, durationMs: $durationMs, artist: $artist, album: $album, albumArtist: $albumArtist, trackNumber: $trackNumber, trackTotal: $trackTotal, discNumber: $discNumber, discTotal: $discTotal, year: $year, genre: $genre, picture: $picture, fileSize: $fileSize)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Audio &&
        other.path == path &&
        other.url == url &&
        other.name == name &&
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
        other.picture == picture &&
        other.fileSize == fileSize;
  }

  @override
  int get hashCode {
    return path.hashCode ^
        url.hashCode ^
        name.hashCode ^
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
        picture.hashCode ^
        fileSize.hashCode;
  }
}

enum AudioType {
  local,
  radio,
  podcast,
}
