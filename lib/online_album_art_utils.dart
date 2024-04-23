import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'string_x.dart';
import 'url_store.dart';

Future<String?> fetchAlbumArt(String icyTitle) async {
  return UrlStore().get(icyTitle) ??
      UrlStore()
          .put(key: icyTitle, url: await compute(_fetchAlbumArt, icyTitle));
}

Future<String?> _fetchAlbumArt(String icyTitle) async {
  final songInfo = icyTitle.splitByDash;
  if (songInfo.songName == null || songInfo.artist == null) return null;

  final searchUrl = getAlbumArtServiceUri(songInfo);
  if (searchUrl == null) return null;

  try {
    final searchResponse = await http.get(searchUrl, headers: kAlbumArtHeaders);

    if (searchResponse.statusCode == 200) {
      final searchData = jsonDecode(searchResponse.body);
      final recordings = searchData['recordings'] as List;

      final firstRecording = recordings.firstOrNull;

      final releaseId = firstRecording == null
          ? null
          : firstRecording?['releases']?[0]?['id'];

      if (releaseId == null) return null;

      final albumArtUrl = await _fetchAlbumArtUrlFromReleaseId(releaseId);

      return albumArtUrl;
    }
  } on Exception catch (_) {
    return null;
  }

  return null;
}

Future<String?> _fetchAlbumArtUrlFromReleaseId(String releaseId) async {
  final url = Uri.parse(
    'https://coverartarchive.org/release/$releaseId',
  );
  try {
    final response = await http.get(url, headers: kAlbumArtHeaders);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final images = data['images'] as List;

      if (images.isNotEmpty) {
        final artwork = images[0];

        return (artwork['image']) as String?;
      }
    }
  } on Exception catch (_) {
    return null;
  }

  return null;
}

Uri? getAlbumArtServiceUri(({String? artist, String? songName}) artInfo) {
  final address =
      'https://musicbrainz.org/ws/2/recording/?query=recording:"${artInfo.songName}"%20AND%20artist:"${artInfo.artist}"';
  return Uri.tryParse(address);
}
