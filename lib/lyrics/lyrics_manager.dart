import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../common/data/audio.dart';
import 'data/lyrics_and_art_result_and_param.dart';
import 'lyrics_service.dart';

@Injectable(cache: true)
class LyricsManager {
  LyricsManager({
    required LocalLyricsService localLyricsService,
    required OnlineLyricsService onlineLyricsService,
  }) : _localLyricsService = localLyricsService,
       _onlineLyricsService = onlineLyricsService;

  final LocalLyricsService _localLyricsService;
  final OnlineLyricsService _onlineLyricsService;

  late final Command<LyricsAndArtParam, LyricsAndArtResult?> command =
      Command.createAsync(
        (param) => _getLyrics(
          audio: param.audio,
          title: param.title,
          artist: param.artist,
        ),
        initialValue: null,
      );

  Future<LyricsAndArtResult?> _getLyrics({
    required Audio? audio,
    required String? title,
    required String? artist,
  }) async {
    final local = _localLyricsService.parseLocalLyrics(
      filePath: audio?.path,
      inputString: audio?.lyrics,
    );

    if ((local?.lrcLines?.isNotEmpty ?? false) ||
        (local?.lyricsString?.isNotEmpty ?? false)) {
      return LyricsAndArtResult(
        lyricsString: local?.lyricsString,
        lrcLines: local?.lrcLines,
        artUrl: null,
      );
    }

    return _onlineLyricsService.fetchLyricsFromGenius(
      title: title ?? audio?.title ?? '',
      artist: artist ?? audio?.artist,
    );
  }

  void maybeRunCommand(LyricsAndArtParam param) {
    if (_shouldRunCommand(param)) {
      command.run(param);
    }
  }

  Future<LyricsAndArtResult?> maybeRunCommandAsync(
    LyricsAndArtParam param,
  ) async {
    if (_shouldRunCommand(param)) {
      return command.runAsync(param);
    }
    return command.results.value.data;
  }

  bool _shouldRunCommand(LyricsAndArtParam param) {
    return command.results.value.paramData != param;
  }
}
