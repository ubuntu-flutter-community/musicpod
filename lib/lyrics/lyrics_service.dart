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

@lazySingleton
class LocalLyricsService {
  ({String? outputString, List<LrcLine>? outputLrcLines})? parseLocalLyrics({
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

    return (outputString: outputString, outputLrcLines: outputLrcLines);
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
  // be able to provide artwork without API tokens,
  // we only use it for lyrics for now.
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

  final _cache =
      <String, ({String? outputString, List<LrcLine>? outputLrcLines})>{};
  Timer? _debounceTimer;
  Completer<({String? outputString, List<LrcLine>? outputLrcLines})?>?
  _completer;

  Future<({String? outputString, List<LrcLine>? outputLrcLines})?>
  fetchLyricsFromGenius({required String title, String? artist}) {
    if (_settingsService.getBool(SPKeys.neverAskAgainForGeniusToken) ?? false) {
      return Future.value(null);
    }

    final cacheKey = '${artist ?? ''} - $title'.toLowerCase();
    if (_cache.containsKey(cacheKey)) {
      printMessageInDebugMode('Returning cached lyrics for "$artist - $title"');
      return Future.value(_cache[cacheKey]);
    }

    _debounceTimer?.cancel();
    if (_completer?.isCompleted == false) {
      _completer?.complete(null);
    }

    _completer =
        Completer<({String? outputString, List<LrcLine>? outputLrcLines})?>();

    _debounceTimer = Timer(const Duration(seconds: 2), () async {
      try {
        printMessageInDebugMode(
          'Fetching lyrics from Genius for "$artist - $title"',
        );

        final song = await _genius.searchSong(artist: artist, title: title);
        if (song != null) {
          final lyrics = await song.lyrics;

          final result = _localLyricsService.parseLocalLyrics(
            inputString: lyrics,
          );

          if (result != null) {
            _cache[cacheKey] = result;
          }
          if (_completer?.isCompleted == false) {
            _completer?.complete(result);
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
