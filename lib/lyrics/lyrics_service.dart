import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:lrc/lrc.dart';
import 'package:path/path.dart' as p;

import '../app/app_config.dart';
import '../common/logging.dart';
import '../local_audio/persistence/local_audio_dao.dart';
import 'data/lyrics_and_art_result_and_param.dart';
import 'data/online_lyrics_exceptions.dart';
import 'data/online_lyrics_source.dart';

@lazySingleton
class LocalLyricsService {
  LyricsAndArtResult? parseLocalLyrics({
    String? filePath,
    String? inputString,
  }) {
    List<LrcLine>? outputLrcLines;
    String? outputString;

    if (inputString != null) {
      if (inputString.isValidLrc) {
        outputLrcLines = Lrc.parse(inputString).lyrics;
      } else {
        final splitter = inputString.contains(' Read More ')
            ? ' Read More '
            : inputString.contains('Lyrics')
            ? 'Lyrics'
            : inputString.contains('Contributors')
            ? 'Contributors'
            : 'Contributor';
        final cleanedLyrics =
            (inputString.split(splitter).elementAtOrNull(1) ?? inputString)
                .replaceFirst('[', '\n\n[');
        outputString = cleanedLyrics;
      }
    } else {
      if (filePath != null) {
        final base = p.basenameWithoutExtension(filePath);
        final dir = File(filePath).parent;
        final maybe = p.join(dir.path, base + '.lrc');
        final file = File(maybe);
        if (file.existsSync()) {
          final lrcString = file.readAsStringSync();
          if (lrcString.isValidLrc) {
            Logger.i(
              'Parsed local .lrc file at "$maybe"',
              tag: '$LocalLyricsService',
            );
            outputLrcLines = Lrc.parse(lrcString).lyrics;
          } else {
            outputString = lrcString;
          }
        }
      }
    }

    return LyricsAndArtResult(
      plainLyrics: outputString,
      lrcLines: outputLrcLines,
      artUrl: null,
    );
  }
}

@lazySingleton
class OnlineLyricsService {
  OnlineLyricsService({required Dio dio, required LocalAudioDao localAudioDao})
    : _dio = dio,
      _localAudioDao = localAudioDao;

  final Dio _dio;
  final LocalAudioDao _localAudioDao;

  final _cache = <String, LyricsAndArtResult>{};
  Timer? _debounceTimer;
  Completer<LyricsAndArtResult?>? _completer;

  Future<LyricsAndArtResult?> fetchOnlineLyrics({
    required String title,
    String? artist,
    String? album,
    int? durationMs,
    OnlineLyricsSource source = OnlineLyricsSource.lrcLib,
  }) {
    final cacheKey = '${artist ?? ''} - $title'.toLowerCase();
    if (_cache.containsKey(cacheKey)) {
      final value = _cache[cacheKey];
      Logger.i(
        'Fetched lyrics from cache for "$artist - $title": ${value?.plainLyrics?.substring(0, 10)}..., artUrl: ${value?.artUrl}',
        tag: '$OnlineLyricsService',
      );
      return Future.value(value);
    }

    _debounceTimer?.cancel();
    if (_completer?.isCompleted == false) {
      _completer?.complete(null);
    }

    _completer = Completer<LyricsAndArtResult?>();

    _debounceTimer = Timer(const Duration(seconds: 2), () async {
      try {
        Logger.i(
          'Trying to fetch lyrics and art from lrcLib for "$artist - $title"',
          tag: '$OnlineLyricsService',
        );

        LyricsAndArtResult? lyricsAndArtResult;
        switch (source) {
          case OnlineLyricsSource.lrcLib:
            lyricsAndArtResult = await fetchLrcLineFromLrcLib(
              title,
              artist: artist,
              album: album,
              durationMs: durationMs,
            );
          // Here we could add more sources in the future
          // prefably without API keys, so that the user can fetch lyrics without setting up anything
        }

        if (lyricsAndArtResult != null) {
          Logger.i(
            'Fetched lyrics from LrcLib for "$artist - $title": ${lyricsAndArtResult.plainLyrics?.substring(0, 10)}..., artUrl: ${lyricsAndArtResult.artUrl}',
            tag: '$OnlineLyricsService',
          );
          if (_completer?.isCompleted == false) {
            final lrcLines = lyricsAndArtResult.lrcLines;
            if (artist != null && lrcLines != null && lrcLines.isNotEmpty) {
              await _localAudioDao.updateLyricsForTitleAndArtistAndAlbum(
                title: title,
                artist: artist,
                album: album,
                lyrics: lrcLines.map((line) => line.formattedLine).join('\n'),
              );
            }
            _cache[cacheKey] = lyricsAndArtResult;
            _completer?.complete(lyricsAndArtResult);
          }
          return;
        } else {
          if (_completer?.isCompleted == false) {
            _completer?.complete(null);
          }
        }
      } catch (e, s) {
        Logger.e(e, trace: s, tag: '$OnlineLyricsService');
        if (_completer?.isCompleted == false) {
          _completer?.completeError(e);
        }
      }
    });

    return _completer!.future;
  }

  Future<LyricsAndArtResult?> fetchLrcLineFromLrcLib(
    String title, {
    String? artist,
    String? album,
    int? durationMs,
  }) async {
    const url = 'https://lrclib.net/api/get';

    final cancelToken = CancelToken();

    _dio.options.headers['user-agent'] =
        '${AppConfig.appTitle} (${AppConfig.repoUrl})';

    // Note: we do not want to activate the RetryManager for client errors (4xx),
    // as these are not recoverable by retrying. We only want to retry on server errors (5xx).
    _dio.options.validateStatus = (status) => status != null && status < 500;

    final response = await _dio
        .get(
          url,
          queryParameters: {
            'artist_name': artist ?? '',
            'track_name': title,
            'album_name': album ?? '',
            if (durationMs != null) 'duration': (durationMs / 1000).round(),
          },
          cancelToken: cancelToken,
        )
        .timeout(
          FetchOnlineLyricsTimeoutException.timeoutDuration,
          onTimeout: () {
            cancelToken.cancel('Request timed out');
            throw FetchOnlineLyricsTimeoutException(
              'Fetching lyrics from LrcLib timed out',
            );
          },
        );
    if (response.statusCode == 200) {
      final data = response.data;

      final syncedLyrics = data['syncedLyrics'] as String?;
      if (syncedLyrics != null) {
        final lrcLines = Lrc.parse(syncedLyrics).lyrics;
        return LyricsAndArtResult(
          plainLyrics: syncedLyrics,
          lrcLines: lrcLines,
          artUrl: null,
        );
      }
      final plainLyrics = data['plainLyrics'] as String?;
      if (plainLyrics != null) {
        return LyricsAndArtResult(
          lrcLines: null,
          plainLyrics: plainLyrics,
          artUrl: null,
        );
      }
    }

    return null;
  }
}
