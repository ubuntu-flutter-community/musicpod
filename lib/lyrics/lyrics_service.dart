import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:lrc/lrc.dart';
import 'package:path/path.dart' as p;

import '../app/app_config.dart';
import '../common/logging.dart';
import '../l10n/app_localizations.dart';
import 'data/lyrics_and_art_result_and_param.dart';

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
  OnlineLyricsService({required Dio dio}) : _dio = dio;

  final Dio _dio;

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
      printInfoInDebugMode(
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
        printInfoInDebugMode(
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
          printInfoInDebugMode(
            'Fetched lyrics from LrcLib for "$artist - $title": ${lyricsAndArtResult.plainLyrics?.substring(0, 10)}..., artUrl: ${lyricsAndArtResult.artUrl}',
            tag: '$OnlineLyricsService',
          );
          if (_completer?.isCompleted == false) {
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
        printErrorInDebugMode(e, trace: s, tag: '$OnlineLyricsService');
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
          const Duration(seconds: 10),
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

enum OnlineLyricsSource {
  lrcLib;

  String localize(AppLocalizations l10n) => switch (this) {
    OnlineLyricsSource.lrcLib => l10n.onlineLyricsSourceLrcLib,
  };

  OnlineLyricsSource fromString(String s) => switch (s.toLowerCase()) {
    'lrclib' => OnlineLyricsSource.lrcLib,
    _ => throw ArgumentError('Unknown online lyrics source: $s'),
  };
}

class FetchOnlineLyricsTimeoutException implements Exception {
  final String message;
  FetchOnlineLyricsTimeoutException(this.message);

  static const Duration timeoutDuration = Duration(seconds: 10);

  @override
  String toString() => 'FetchOnlineLyricsTimeoutException: $message';
}
