import 'dart:async';
import 'dart:io';

import 'package:flutter_it/flutter_it.dart';
import 'package:genius_lyrics/genius_lyrics.dart';
import 'package:injectable/injectable.dart';
import 'package:lrc/lrc.dart';
import 'package:path/path.dart' as p;

import '../common/logging.dart';
import '../settings/settings_service.dart';
import '../settings/shared_preferences_keys.dart';
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
      lyricsString: outputString,
      lrcLines: outputLrcLines,
      artUrl: null,
    );
  }
}

@lazySingleton
class OnlineLyricsService {
  OnlineLyricsService({
    required LocalLyricsService localLyricsService,
    required SettingsService settingsService,
  }) : _localLyricsService = localLyricsService,
       _settingsService = settingsService {
    const fromEnv = String.fromEnvironment('GENIUS_ACCESS_TOKEN');
    _genius = di.get<Genius>(
      param1: fromEnv.isNotEmpty
          ? fromEnv
          : _settingsService.getString(SPKeys.lyricsGeniusAccessToken) ?? '',
    );
  }

  // Note: the genius API is actually capable of much more than just fetching lyrics,
  // but because genius needs an API token, and musicbrainz doesn't, and musicpod should
  // be able to provide artwork without API tokens.
  // If this is set up, the MPV Metadata manager will not use musicbrainz anymore for fetching artwork,
  // because genius provides more reliable results for artwork than musicbrainz
  late final Genius _genius;

  final LocalLyricsService _localLyricsService;
  final SettingsService _settingsService;
  static bool get isRegistered => di.isRegistered<OnlineLyricsService>();

  static Future<void> refreshRegistration(String token) async {
    if (di.isRegistered<OnlineLyricsService>()) {
      di.unregister<OnlineLyricsService>();
    }

    final saved = await di<SettingsService>().setValue(
      SPKeys.lyricsGeniusAccessToken,
      token,
    );

    if (!saved) {
      throw GeniusNotSetupException();
    }

    di.registerLazySingleton(
      () => OnlineLyricsService(
        localLyricsService: di<LocalLyricsService>(),
        settingsService: di<SettingsService>(),
      ),
    );
  }

  final _cache = <String, LyricsAndArtResult>{};
  Timer? _debounceTimer;
  Completer<LyricsAndArtResult?>? _completer;

  Future<LyricsAndArtResult?> fetchLyricsFromGenius({
    required String title,
    String? artist,
  }) {
    if (_settingsService.getBool(SPKeys.neverAskAgainForGeniusToken) ?? false) {
      return Future.value(null);
    }

    final cacheKey = '${artist ?? ''} - $title'.toLowerCase();
    if (_cache.containsKey(cacheKey)) {
      final value = _cache[cacheKey];
      printMessageInDebugMode(
        'Fetched lyrics from Genius for "$artist - $title": ${value?.lyricsString?.substring(0, 10)}..., artUrl: ${value?.artUrl}',
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
        printMessageInDebugMode(
          'Trying to fetch lyrics and art from Genius for "$artist - $title"',
        );

        final song = await _genius.searchSong(artist: artist, title: title);
        if (song != null) {
          final lyrics = await song.lyrics;

          final localParsed = _localLyricsService.parseLocalLyrics(
            inputString: lyrics,
          );

          printMessageInDebugMode(
            'Fetched lyrics from Genius for "$artist - $title": ${lyrics?.substring(0, 10)}..., artUrl: ${song.songArtImageUrl}',
          );

          _cache[cacheKey] = LyricsAndArtResult(
            lyricsString: localParsed?.lyricsString ?? lyrics,
            lrcLines: localParsed?.lrcLines,
            artUrl: song.songArtImageUrl,
          );

          if (_completer?.isCompleted == false) {
            _completer?.complete(
              LyricsAndArtResult(
                lyricsString: localParsed?.lyricsString,
                lrcLines: localParsed?.lrcLines,
                artUrl: song.songArtImageUrl,
              ),
            );
          }
        } else {
          if (_completer?.isCompleted == false) {
            _completer?.complete(null);
          }
        }
      } catch (e) {
        if (_completer?.isCompleted == false) {
          _completer?.completeError(e);
        }
      }
    });

    return _completer!.future;
  }
}

class GeniusNotSetupException implements Exception {
  @override
  String toString() =>
      'Genius API is not setup correctly. Please provide a valid API token in the settings.';
}
