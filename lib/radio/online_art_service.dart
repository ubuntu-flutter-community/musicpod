import 'dart:async';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../app/app_config.dart';
import '../common/logging.dart';
import '../extensions/string_x.dart';

const _kMusicBrainzAddress = 'https://musicbrainz.org/ws/2/recording/';
const _kCoverArtArchiveAddress = 'https://coverartarchive.org/release/';
const _kMusicBrainzHeaders = {
  'Accept': 'application/json',
  'User-Agent': '${AppConfig.appTitle} (${AppConfig.repoUrl})',
};

const _kInternetArchiveHeaders = {
  'User-Agent': '${AppConfig.appTitle} (${AppConfig.repoUrl})',
};

@lazySingleton
class OnlineArtService {
  OnlineArtService({required Dio dio}) : _dio = dio;
  final Dio _dio;
  final _propertiesChangedController = StreamController<bool>.broadcast();
  Stream<bool> get propertiesChanged => _propertiesChangedController.stream;
  final _errorController = StreamController<String?>.broadcast();
  Stream<String?> get error => _errorController.stream;

  bool _dataSafeMode = false;
  bool get dataSafeMode => _dataSafeMode;
  void setDataSafeMode(bool value) {
    if (value == _dataSafeMode) return;
    _dataSafeMode = value;
    _propertiesChangedController.add(true);
  }

  /// Fetches album art for a given [icyTitle]. If [albumArtOverwrite] is provided,
  /// it will be returned directly without making any network requests.
  /// If [icyTitle] is null, the method will return null.
  Future<String?> fetchAlbumArt({
    String? icyTitle,
    String? albumArtOverwrite,
  }) async {
    _errorController.add(null);

    if (icyTitle == null) {
      return null;
    }

    if (albumArtOverwrite != null) {
      return put(key: icyTitle, url: albumArtOverwrite);
    }

    final albumArtUrl =
        get(icyTitle) ??
        put(
          key: icyTitle,
          url:
              await compute(
                _fetchAlbumArt,
                _ComputeCapsule(icyTitle: icyTitle, dio: _dio),
              ).onError((e, s) {
                printErrorInDebugMode(e, trace: s, tag: '$OnlineArtService');
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
  dio.options.headers = _kMusicBrainzHeaders;
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

    final releaseId = firstRecording == null
        ? null
        : firstRecording?['releases']?[0]?['id'];

    if (releaseId == null) {
      printInfoInDebugMode(
        '${capsule.icyTitle}: No release found}',
        tag: '$OnlineArtService',
      );
      return null;
    }

    printInfoInDebugMode(
      '${capsule.icyTitle}: Release ($releaseId) found, trying to find artwork ...',
      tag: '$OnlineArtService',
    );

    final albumArtUrl = await _fetchAlbumArtUrlFromReleaseId(
      releaseId: releaseId,
      dio: dio,
    );

    if (albumArtUrl != null) {
      printInfoInDebugMode(
        '${capsule.icyTitle}: Resource ($albumArtUrl) found',
        tag: '$OnlineArtService',
      );
    } else {
      printInfoInDebugMode(
        '${capsule.icyTitle}: No resource found for ($releaseId)!',
        tag: '$OnlineArtService',
      );
    }

    return albumArtUrl;
  } on Exception catch (e, s) {
    printErrorInDebugMode(e, trace: s, tag: '$OnlineArtService');
    return null;
  }
}

Future<String?> _fetchAlbumArtUrlFromReleaseId({
  required String releaseId,
  required Dio dio,
}) async {
  try {
    dio.options.headers = _kInternetArchiveHeaders;
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
    final imagesMaps = response.data['images'] as List?;

    if (imagesMaps != null && imagesMaps.isNotEmpty == true) {
      final imageMap = imagesMaps.firstWhereOrNull(
        (e) => (e['front'] as bool?) == true || e != null,
      );

      final thumbnail = imageMap?['thumbnails'] as Map?;

      final url =
          thumbnail?.entries.firstWhere((e) => e.value != null).value
              as String?;

      return url?.replaceAll('http://', 'https://');
    }
  } on Exception catch (e, s) {
    printErrorInDebugMode(e, trace: s, tag: '$OnlineArtService');
    return null;
  }
  return null;
}
