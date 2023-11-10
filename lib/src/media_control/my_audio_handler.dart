import 'package:audio_service/audio_service.dart';
import 'package:media_kit/media_kit.dart';
import 'package:stream_transform/stream_transform.dart';

class MyAudioHandler extends BaseAudioHandler with SeekHandler {
  // mix in default seek callback implementations

  final Future<void> Function() onPlay;
  final Future<void> Function() onPause;
  final Future<void> Function() onNext;
  final Future<void> Function() onPrevious;
  final Future<void> Function()? onStop;
  final Future<void> Function() onPlayPause;
  final bool isPlaying;
  final PlayerStream playerStream;

  /// Initialise our audio handler.
  MyAudioHandler({
    required this.onPlay,
    required this.onPause,
    required this.onNext,
    required this.onPrevious,
    this.onStop,
    required this.onPlayPause,
    required this.isPlaying,
    required this.playerStream,
  }) {
    _mergeStreams(
      playerStream.playing,
      playerStream.position,
    ).map(_transformEvent).pipe(playbackState);
  }

  @override
  Future<void> play() async {
    await onPlayPause.call();
  }

  @override
  Future<void> pause() async {
    await onPause();
  }

  @override
  Future<void> skipToNext() async {
    await onNext();
  }

  @override
  Future<void> skipToPrevious() async {
    await onPrevious();
  }

  PlaybackState _transformEvent((bool, Duration) e) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (e.$1) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
      },
      androidCompactActionIndices: const [0, 1, 2],
      playing: e.$1,
      updatePosition: e.$2,
      bufferedPosition: e.$2,
    );
  }
}

Stream<(bool, Duration)> _mergeStreams(
  Stream<bool> playing,
  Stream<Duration> position,
) {
  return playing.combineLatest(position, (a, b) => (a, b));
}
