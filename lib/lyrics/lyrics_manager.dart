import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../common/data/audio.dart';
import '../common/util/family.dart';
import '../extensions/command_x.dart';
import 'data/lyrics_and_art_result_and_param.dart';
import 'lyrics_service.dart';

@injectable
class LyricsManager {
  LyricsManager._({
    required LocalLyricsService localLyricsService,
    required OnlineLyricsService onlineLyricsService,
  }) : _localLyricsService = localLyricsService,
       _onlineLyricsService = onlineLyricsService;

  @factoryMethod
  static LyricsManager create({
    required LocalLyricsService localLyricsService,
    required OnlineLyricsService onlineLyricsService,
  }) => Family.of(
    '$LyricsManager',
    () => LyricsManager._(
      localLyricsService: localLyricsService,
      onlineLyricsService: onlineLyricsService,
    ),
    shouldDispose: (m) => m.command.safeToDispose,
    onDispose: (m) => m.command.dispose(),
  );

  final LocalLyricsService _localLyricsService;
  final OnlineLyricsService _onlineLyricsService;

  late final Command<LyricsAndArtParam, LyricsAndArtResult?> command =
      Command.createAsync(
        (param) => _getLyrics(
          audio: param.audio,
          title: param.title,
          artist: param.artist,
          searchOnline: param.tryToFetchOnline,
        ),
        initialValue: null,
      );

  Future<LyricsAndArtResult?> _getLyrics({
    required Audio? audio,
    required String? title,
    required String? artist,
    required bool searchOnline,
  }) async {
    final local = _localLyricsService.parseLocalLyrics(
      filePath: audio?.path,
      inputString: audio?.lyrics,
    );

    if ((local?.lrcLines?.isNotEmpty ?? false) ||
        (local?.plainLyrics?.isNotEmpty ?? false)) {
      return LyricsAndArtResult(
        plainLyrics: local?.plainLyrics,
        lrcLines: local?.lrcLines,
        artUrl: null,
      );
    }

    if (searchOnline) {
      return _onlineLyricsService.fetchOnlineLyrics(
        title: title ?? audio?.title ?? '',
        artist: artist ?? audio?.artist,
        durationMs: audio?.durationMs?.toInt(),
        album: audio?.album,
      );
    }

    return null;
  }
}
