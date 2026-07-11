import 'dart:async';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../app/app_config.dart';
import '../../common/logging.dart';
import '../../extensions/string_x.dart';

const _kMusicBrainzAddress = 'https://musicbrainz.org/ws/2/recording/';
const _kCoverArtArchiveAddress = 'https://coverartarchive.org/release/';
const _kMusicBrainzHeaders = {
  'Accept': 'application/json',
  'User-Agent': '${AppConfig.appTitle} (${AppConfig.repoUrl})',
};

const _kInternetArchiveHeaders = {
  'User-Agent': '${AppConfig.appTitle} (${AppConfig.repoUrl})',
};

@Injectable(cache: true)
class OnlineArtService {
  OnlineArtService({required Dio dio}) : _dio = dio;
  final Dio _dio;

  Future<String?> fetchAlbumArt({required String icyTitle}) =>
      compute(
        _fetchAlbumArt,
        FetchAlbumArtParam(icyTitle: icyTitle, dio: _dio),
      ).onError((e, s) {
        Logger.e(e, trace: s, tag: '$OnlineArtService');
        return null;
      });
}

class FetchAlbumArtParam {
  final String icyTitle;
  final Dio dio;

  FetchAlbumArtParam({required this.icyTitle, required this.dio});
}

Future<String?> _fetchAlbumArt(FetchAlbumArtParam capsule) async {
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
      Logger.i(
        '${capsule.icyTitle}: No release found}',
        tag: '$OnlineArtService',
      );
      return null;
    }

    Logger.i(
      '${capsule.icyTitle}: Release ($releaseId) found, trying to find artwork ...',
      tag: '$OnlineArtService',
    );

    final albumArtUrl = await _fetchAlbumArtUrlFromReleaseId(
      releaseId: releaseId,
      dio: dio,
    );

    if (albumArtUrl != null) {
      Logger.i(
        '${capsule.icyTitle}: Resource ($albumArtUrl) found',
        tag: '$OnlineArtService',
      );
    } else {
      Logger.i(
        '${capsule.icyTitle}: No resource found for ($releaseId)!',
        tag: '$OnlineArtService',
      );
    }

    return albumArtUrl;
  } on Exception catch (e, s) {
    Logger.e(e, trace: s, tag: '$OnlineArtService');
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
      if (stringCode.startsWith('2') ||
          stringCode.startsWith('3') ||
          stringCode.startsWith('4')) {
        return true;
      }
      return false;
    };

    final path = '$_kCoverArtArchiveAddress$releaseId';
    final response = await dio.get(path);
    final data = response.data;
    final imagesMaps = data is Map ? data['images'] as List? : null;

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
    Logger.r(
      e,
      trace: s,
      tag: '$OnlineArtService',
      reportType: switch (e.runtimeType) {
        DioException => ReportType.warning,
        _ => ReportType.error,
      },
    );
    return null;
  }
  return null;
}
