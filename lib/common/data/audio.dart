import 'dart:convert';
import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:radio_browser_api/radio_browser_api.dart';

import '../../app/app_config.dart';
import '../../extensions/media_file_x.dart';
import '../../extensions/string_x.dart';
import '../../extensions/taget_platform_x.dart';
import '../../local_audio/data/local_audio_genres.dart';
import '../logging.dart';
import 'audio_type.dart';

class Audio {
  /// The local path if available.
  final String? path;

  /// The remote URL if available.
  final String? url;

  /// The [AudioType]
  final AudioType? audioType;

  /// The url of the image if remote.
  final String? imageUrl;

  /// The description of the audio file or stream.
  final String? description;

  /// Website link.
  final String? website;

  /// The title of the audio file or stream.
  final String? title;

  /// The duration of the audio file or stream. It can be null if was not set
  final double? durationMs;

  /// The artist(s) of the audio file or stream.
  final String? artist;

  /// The album of the audio file or stream.
  final String? album;

  /// The album artist(s) of the audio file or stream.
  final String? albumArtist;

  /// The track number of the audio file or stream.
  final int? trackNumber;

  /// The track total of the audio file or stream.
  final int? trackTotal;

  /// The discNumber of the audio file or stream.
  final int? discNumber;

  /// The discTotal of the audio file or stream.
  final int? discTotal;

  /// The date the audio was released.
  final int? year;

  /// The genre of the audio file or stream.
  final String? genre;

  /// The picture's MIME type. Only for local audio.
  final String? pictureMimeType;

  /// The image data. Only for local audio.
  final Uint8List? pictureData;

  /// The file size of the audio file.
  final int? fileSize;

  /// Optional art that can belong to a parent element.
  final String? albumArtUrl;

  final String? lyrics;

  // Radio-specific fields
  /// The UUID of the radio station.
  final String? uuid;

  /// The language of the radio station.
  final String? language;

  /// Comma-separated tags for the radio station.
  final String? radioTags;

  /// The codec of the radio station stream.
  final String? codec;

  /// The click count of the radio station.
  final int? clicks;

  /// The bitrate of the radio station stream in kbps.
  final int? bitRate;

  // Podcast-specific fields
  /// The feed URL for the podcast.
  final String? feedUrl;

  /// The title of the podcast series.
  final String? podcastTitle;

  /// The copyright of the podcast.
  final String? copyright;

  /// The description of the podcast series.
  final String? podcastDescription;

  /// The description of the podcast episode.
  final String? episodeDescription;

  /// The publication date of the podcast episode in milliseconds since epoch.
  final int? publicationDate;

  const Audio({
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
    this.lyrics,
    this.uuid,
    this.language,
    this.radioTags,
    this.codec,
    this.clicks,
    this.bitRate,
    this.feedUrl,
    this.podcastTitle,
    this.copyright,
    this.podcastDescription,
    this.episodeDescription,
    this.publicationDate,
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
    String? lyrics,
    String? uuid,
    String? language,
    String? radioTags,
    String? codec,
    int? clicks,
    int? bitRate,
    String? feedUrl,
    String? podcastTitle,
    String? copyright,
    String? podcastDescription,
    String? episodeDescription,
    int? publicationDate,
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
      lyrics: lyrics ?? this.lyrics,
      uuid: uuid ?? this.uuid,
      language: language ?? this.language,
      radioTags: radioTags ?? this.radioTags,
      codec: codec ?? this.codec,
      clicks: clicks ?? this.clicks,
      bitRate: bitRate ?? this.bitRate,
      feedUrl: feedUrl ?? this.feedUrl,
      podcastTitle: podcastTitle ?? this.podcastTitle,
      copyright: copyright ?? this.copyright,
      podcastDescription: podcastDescription ?? this.podcastDescription,
      episodeDescription: episodeDescription ?? this.episodeDescription,
      publicationDate: publicationDate ?? this.publicationDate,
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
    if (lyrics != null) {
      result.addAll({'lyrics': lyrics});
    }
    if (uuid != null) {
      result.addAll({'uuid': uuid});
    }
    if (language != null) {
      result.addAll({'language': language});
    }
    if (radioTags != null) {
      result.addAll({'radioTags': radioTags});
    }
    if (codec != null) {
      result.addAll({'codec': codec});
    }
    if (clicks != null) {
      result.addAll({'clicks': clicks});
    }
    if (bitRate != null) {
      result.addAll({'bitRate': bitRate});
    }
    if (feedUrl != null) {
      result.addAll({'feedUrl': feedUrl});
    }
    if (podcastTitle != null) {
      result.addAll({'podcastTitle': podcastTitle});
    }
    if (copyright != null) {
      result.addAll({'copyright': copyright});
    }
    if (podcastDescription != null) {
      result.addAll({'podcastDescription': podcastDescription});
    }
    if (episodeDescription != null) {
      result.addAll({'episodeDescription': episodeDescription});
    }
    if (publicationDate != null) {
      result.addAll({'publicationDate': publicationDate});
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
      pictureData: map['pictureData'] != null
          ? base64Decode(map['pictureData'])
          : null,
      fileSize: map['fileSize']?.toInt(),
      albumArtUrl: map['albumArtUrl'],
      lyrics: map['lyrics'],
      uuid: map['uuid'],
      language: map['language'],
      radioTags: map['radioTags'],
      codec: map['codec'],
      clicks: map['clicks']?.toInt(),
      bitRate: map['bitRate']?.toInt(),
      feedUrl: map['feedUrl'],
      podcastTitle: map['podcastTitle'],
      copyright: map['copyright'],
      podcastDescription: map['podcastDescription'],
      episodeDescription: map['episodeDescription'],
      publicationDate: map['publicationDate']?.toInt(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is Audio) {
      if (other.audioType != null &&
          other.audioType == AudioType.radio &&
          audioType == AudioType.radio) {
        return other.uuid == uuid;
      }

      return (other.url != null && other.url == url) ||
          (other.path != null && other.path == path);
    }

    return false;
  }

  @override
  int get hashCode => path.hashCode ^ url.hashCode ^ uuid.hashCode;

  /// Be sure that the file exists and is playable before calling this method!
  factory Audio.local(
    File file, {
    bool getImage = false,
    Function(String path)? onError,
    Function(String path)? onParseError,
  }) {
    if (!file.existsSync() || !file.isPlayable) {
      onError?.call(file.path);
      throw Exception(
        'Audio creation aborted! File does not exist or is not playable',
      );
    }

    Audio audio;
    try {
      final metadata = readMetadata(file, getImage: getImage);
      audio = Audio._fromMetadata(metadata);
    } on MetadataParserException catch (error) {
      printMessageInDebugMode(error);
      onParseError?.call(file.path);
      audio = Audio._localWithoutMetadata(path: file.path);
    } on Exception catch (error) {
      printMessageInDebugMode(error);
      onError?.call(file.path);
      audio = Audio._localWithoutMetadata(path: file.path);
    } catch (error) {
      printMessageInDebugMode(error);
      onError?.call(file.path);
      audio = Audio._localWithoutMetadata(path: file.path);
    }
    return audio;
  }

  factory Audio._fromMetadata(AudioMetadata data) {
    final path = data.file.path;
    final fileName = data.file.uri.pathSegments.lastOrNull;
    final genre = data.genres.isEmpty
        ? null
        : data.genres.firstOrNull?.startsWith('(') == true &&
              data.genres.firstOrNull?.endsWith(')') == true
        ? localAudioGenres[data.genres.firstOrNull
              ?.replaceAll('(', '')
              .replaceAll(')', '')]
        : data.genres.firstOrNull;

    return Audio(
      path: path,
      audioType: AudioType.local,
      artist: data.artist,
      title: (data.title?.isNotEmpty == true ? data.title : fileName) ?? path,
      album: data.album,
      // TODO(#339): wait for fix
      albumArtist: data.artist,
      discNumber: data.discNumber,
      discTotal: data.totalDisc,
      durationMs: data.duration?.inMilliseconds.toDouble(),
      // fileSize: data.,
      genre: genre?.everyWordCapitalized,
      pictureData: data.pictures
          .firstWhereOrNull((e) => e.bytes.isNotEmpty)
          ?.bytes,
      pictureMimeType: data.pictures.firstOrNull?.mimetype,
      trackNumber: data.trackNumber,
      year: data.year?.year,
      lyrics: data.lyrics,
    );
  }

  factory Audio._localWithoutMetadata({required String path}) => Audio(
    path: path,
    title: basenameWithoutExtension(path),
    album: 'Unknown',
    artist: 'Unknown',
    albumArtist: 'Unknown',
    genre: 'Unknown',
    audioType: AudioType.local,
  );

  List<String>? get tags => radioTags?.isNotEmpty == false
      ? null
      : <String>[for (final tag in radioTags?.split(',') ?? <String>[]) tag];

  factory Audio.fromStation(Station station) {
    return Audio(
      url: station.urlResolved,
      title: station.name.trim(),
      audioType: AudioType.radio,
      imageUrl: station.favicon,
      website: station.homepage,
      uuid: station.stationUUID,
      language: station.language,
      radioTags: station.tags ?? '',
      codec: station.codec,
      clicks: station.clickCount,
      bitRate: station.bitrate,
    );
  }

  factory Audio.fromPodcast({
    required Episode episode,
    required Podcast? podcast,
    required String? itemImageUrl,
    required String? genre,
  }) {
    return Audio(
      url: episode.contentUrl,
      audioType: AudioType.podcast,
      imageUrl: episode.imageUrl,
      albumArtUrl: itemImageUrl ?? podcast?.image,
      title: episode.title,
      durationMs: episode.duration?.inMilliseconds.toDouble(),
      genre: genre,
      feedUrl: podcast?.url,
      podcastTitle: podcast?.title,
      copyright: podcast?.copyright,
      podcastDescription: podcast?.description,
      episodeDescription: episode.description,
      publicationDate: episode.publicationDate?.millisecondsSinceEpoch,
    );
  }

  String? get albumId {
    final albumName = album;
    final artistName = artist;
    return albumName == null && artistName == null
        ? null
        : createAlbumId(artistName, albumName);
  }

  static String createAlbumId(String? artistName, String? albumName) {
    final id = '${artistName ?? ''}$albumIdSplitter${albumName ?? ''}'
        .replaceAll(albumIdReplacement, albumIdReplacer);

    if (isMobile) {
      return id.replaceAll(':', '');
    }

    return id;
  }

  // Note this assumes that no artist or no album includes ___ on their own =)
  static const String albumIdSplitter =
      '$albumIdReplacer${AppConfig.appId}$albumIdReplacer';
  static const String albumIdReplacer = '___';
  static const String albumIdReplacement = ' ';

  bool get canHaveLocalCover =>
      albumId != null &&
      albumId!.isNotEmpty &&
      path != null &&
      audioType == AudioType.local;

  bool get isLocal => audioType == AudioType.local;
  bool get isPodcast => audioType == AudioType.podcast;
  bool get isRadio => audioType == AudioType.radio;
}
