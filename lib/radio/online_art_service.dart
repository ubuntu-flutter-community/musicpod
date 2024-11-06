import 'dart:async';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../common/logging.dart';
import '../constants.dart';
import '../extensions/string_x.dart';

const _kMusicBrainzAddress = 'https://musicbrainz.org/ws/2/recording/';
const _kCoverArtArchiveAddress = 'https://coverartarchive.org/release/';

class OnlineArtService {
  OnlineArtService({required Dio dio}) : _dio = dio;
  final Dio _dio;
  final _propertiesChangedController = StreamController<bool>.broadcast();
  Stream<bool> get propertiesChanged => _propertiesChangedController.stream;
  final _errorController = StreamController<String?>.broadcast();
  Stream<String?> get error => _errorController.stream;

  Future<String?> fetchAlbumArt(String icyTitle) async {
    _errorController.add(null);
    final albumArtUrl = get(icyTitle) ??
        put(
          key: icyTitle,
          url: await compute(
            _fetchAlbumArt,
            _ComputeCapsule(icyTitle: icyTitle, dio: _dio),
          ).onError((e, s) {
            printMessageInDebugMode(e.toString());
            _errorController.add('$e : $s');
            return null;
          }),
        );
    _propertiesChangedController.add(true);

    return albumArtUrl;
  }

  final _store = <String, String?>{};

  String? put({required String key, String? url}) {
    return _store.containsKey(key)
        ? _store.update(key, (value) => url)
        : _store.putIfAbsent(key, () => url);
  }

  String? get(String? icyTitle) => icyTitle == null ? null : _store[icyTitle];

  Future<void> dispose() async {
    await _errorController.close();
    await _propertiesChangedController.close();
  }
}

class _ComputeCapsule {
  final String icyTitle;
  final Dio dio;

  _ComputeCapsule({required this.icyTitle, required this.dio});
}

Future<String?> _fetchAlbumArt(_ComputeCapsule capsule) async {
  final dio = capsule.dio;
  dio.options.headers = kMusicBrainzHeaders;
  final songInfo = capsule.icyTitle.splitByDash;
  if (songInfo.songName == null || songInfo.artist == null) return null;

  try {
    final searchResponse = await dio.get(
      _kMusicBrainzAddress,
      queryParameters: {
        'query':
            'recording:"${songInfo.songName}"%20AND%20artist:"${songInfo.artist}"',
      },
    );

    final recordings = searchResponse.data['recordings'] as List;

    final firstRecording = recordings.firstOrNull;

    final releaseId =
        firstRecording == null ? null : firstRecording?['releases']?[0]?['id'];

    if (releaseId == null) {
      printMessageInDebugMode('${capsule.icyTitle}: No release found}');
      return null;
    }

    printMessageInDebugMode(
      '${capsule.icyTitle}: Release ($releaseId) found, trying to find artwork ...',
    );

    final albumArtUrl = await _fetchAlbumArtUrlFromReleaseId(
      releaseId: releaseId,
      dio: dio,
    );

    if (albumArtUrl != null) {
      printMessageInDebugMode(
        '${capsule.icyTitle}: Resource ($albumArtUrl) found',
      );
    } else {
      printMessageInDebugMode(
        '${capsule.icyTitle}: No resource found for ($releaseId)!',
      );
    }

    return albumArtUrl;
  } on Exception {
    printMessageInDebugMode('No release found!');
    return null;
  }
}

Future<String?> _fetchAlbumArtUrlFromReleaseId({
  required String releaseId,
  required Dio dio,
}) async {
  try {
    dio.options.headers = kInternetArchiveHeaders;
    dio.options.followRedirects = true;
    dio.options.maxRedirects = 5;
    dio.options.receiveTimeout = const Duration(seconds: 25);
    dio.options.validateStatus = (code) {
      final stringCode = code.toString();
      if (stringCode.startsWith('2') || stringCode.startsWith('3')) {
        return true;
      }
      return false;
    };

    final path = '$_kCoverArtArchiveAddress$releaseId';
    final response = await dio.get(path);
    final imagesMaps = response.data['images'] as List;

    if (imagesMaps.isNotEmpty == true) {
      final imageMap = imagesMaps
          .firstWhereOrNull((e) => (e['front'] as bool?) == true || e != null);

      final thumbnail = imageMap?['thumbnails'] as Map?;

      final url = thumbnail?['large'] as String? ??
          thumbnail?['small'] as String? ??
          thumbnail?['500'] as String? ??
          thumbnail?['1200'] as String? ??
          imageMap['image'] as String?;

      return url?.replaceAll('http://', 'https://');
    }
  } on Exception catch (e) {
    printMessageInDebugMode(e.toString());
    return null;
  }
  return null;
}
