import 'package:audio_service/audio_service.dart';

class MyAudioHandler extends BaseAudioHandler with SeekHandler {
  final Future<void> Function() onPlay;
  final Future<void> Function() onPause;
  final Future<void> Function() onNext;
  final Future<void> Function() onPrevious;
  final Future<void> Function(Duration position) onSeek;

  MyAudioHandler({
    required this.onPlay,
    required this.onPause,
    required this.onNext,
    required this.onPrevious,
    required this.onSeek,
  });

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
