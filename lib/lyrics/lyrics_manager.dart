import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../dependencies.dart';
import 'data/lyrics_and_art_result_and_param.dart';
import 'lyrics_service.dart';

part 'lyrics_manager.g.dart';

@Riverpod(keepAlive: true)
class LyricsManager extends _$LyricsManager {
  @override
  Future<LyricsAndArtResult?> build(LyricsAndArtParam param) async {
    final localLyricsService = di<LocalLyricsService>();
    final onlineLyricsService = di<OnlineLyricsService>();

    final local = localLyricsService.parseLocalLyrics(
      filePath: param.audio?.path,
      inputString: param.audio?.lyrics,
    );

    if ((local?.lrcLines?.isNotEmpty ?? false) ||
        (local?.plainLyrics?.isNotEmpty ?? false)) {
      return LyricsAndArtResult(
        plainLyrics: local?.plainLyrics,
        lrcLines: local?.lrcLines,
        artUrl: null,
      );
    }

    if (param.tryToFetchOnline) {
      return onlineLyricsService.fetchOnlineLyrics(
        title: param.title ?? param.audio?.title ?? '',
        artist: param.artist ?? param.audio?.artist,
        durationMs: param.audio?.durationMs?.toInt(),
        album: param.audio?.album,
      );
    }

    return null;
  }
}
