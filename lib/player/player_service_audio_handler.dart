import 'dart:async';
import 'package:audio_service/audio_service.dart';

class PlayerServiceAudioHandler extends BaseAudioHandler with SeekHandler {
  final Future<void> Function() onPlay;
  final Future<void> Function() onPause;
  final Future<void> Function() onNext;
  final Future<void> Function() onPrevious;
  final Future<void> Function(Duration position) onSeek;

  @override
  PlayerServiceAudioHandler({
    required this.onPlay,
    required this.onPause,
    required this.onNext,
    required this.onPrevious,
    required this.onSeek,
  }) {
    playbackState.add(
      PlaybackState(
        playing: false,
        systemActions: {
          MediaAction.seek,
          MediaAction.seekBackward,
          MediaAction.seekForward,
        },
        controls: [
          MediaControl.skipToPrevious,
          MediaControl.rewind,
          MediaControl.play,
          MediaControl.fastForward,
          MediaControl.skipToNext,
        ],
      ),
    );
  }

  @override
  Future<void> play() async {
    await onPlay();
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

  @override
  Future<void> seek(Duration position) async {
    await onSeek(position);
  }
}
