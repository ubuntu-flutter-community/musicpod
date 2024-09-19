import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants.dart';
import '../extensions/string_x.dart';

const _kMusicBrainzAddress = 'https://musicbrainz.org/ws/2/recording/';
const _kCoverArtArchiveAddress = 'https://coverartarchive.org/release/';

class OnlineArtService {
  OnlineArtService({required Dio dio}) : _dio = dio;
  final Dio _dio;

  Future<String?> fetchAlbumArt(String icyTitle) async =>
      get(icyTitle) ??
      put(
        key: icyTitle,
        url: await compute(
          _fetchAlbumArt,
          _ComputeCapsule(icyTitle: icyTitle, dio: _dio),
        ),
      );

  final _value = <String, String?>{};

  String? put({required String key, String? url}) {
    return _value.containsKey(key)
        ? _value.update(key, (value) => url)
        : _value.putIfAbsent(key, () => url);
  }

  String? get(String? icyTitle) => icyTitle == null ? null : _value[icyTitle];
}

class _ComputeCapsule {
  final String icyTitle;
  final Dio dio;

  _ComputeCapsule({required this.icyTitle, required this.dio});
}

Future<String?> _fetchAlbumArt(_ComputeCapsule capsule) async {
  final dio = capsule.dio;
  dio.options.headers = kAlbumArtHeaders;
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

    if (releaseId == null) return null;

    final albumArtUrl = await _fetchAlbumArtUrlFromReleaseId(
      releaseId: releaseId,
      dio: dio,
    );

    return albumArtUrl;
  } on Exception catch (_) {
    return null;
  }
}

Future<String?> _fetchAlbumArtUrlFromReleaseId({
  required String releaseId,
  required Dio dio,
}) async {
  try {
    dio.options.headers = kAlbumArtHeaders;
    final response = await dio.get('$_kCoverArtArchiveAddress$releaseId');

    final images = response.data['images'] as List;

    if (images.isNotEmpty) {
      final artwork = images[0];

      return (artwork['image']) as String?;
    }
  } on Exception catch (_) {
    return null;
  }

  return null;
}
