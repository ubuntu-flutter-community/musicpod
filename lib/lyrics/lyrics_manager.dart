import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'package:lrc/lrc.dart';

import '../common/data/audio.dart';
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

  late final Command<
    ({Audio audio, String? title, String? artist}),
    ({String? outputString, List<LrcLine>? outputLrcLines})?
  >
  command = Command.createAsync(
    (param) => _getLyrics(
      audio: param.audio,
      title: param.title,
      artist: param.artist,
    ),
    initialValue: null,
  );

  Future<({String? outputString, List<LrcLine>? outputLrcLines})?> _getLyrics({
    required Audio audio,
    required String? title,
    required String? artist,
  }) async {
    final local = _localLyricsService.parseLocalLyrics(
      filePath: audio.path,
      inputString: audio.lyrics,
    );

    if ((local?.outputLrcLines?.isNotEmpty ?? false) ||
        (local?.outputString?.isNotEmpty ?? false)) {
      return local;
    }

    return _onlineLyricsService.fetchLyricsFromGenius(
      title: title ?? audio.title ?? '',
      artist: artist ?? audio.artist,
    );
  }

  void maybeRunCommand({
    required Audio audio,
    required String? title,
    required String? artist,
  }) {
    final shouldRun =
        command.results.value.paramData?.audio != audio ||
        command.results.value.paramData?.title != title ||
        command.results.value.paramData?.artist != artist;
    if (shouldRun) {
      command.run((audio: audio, title: title, artist: artist));
    }
  }
}
