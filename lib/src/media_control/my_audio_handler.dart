import 'package:audio_service/audio_service.dart';
import 'package:media_kit/media_kit.dart';

class MyAudioHandler extends BaseAudioHandler with SeekHandler {
  // mix in default seek callback implementations

  final Future<void> Function() onPlay;
  final Future<void> Function() onPause;
  final Future<void> Function() onNext;
  final Future<void> Function() onPrevious;
  final Future<void> Function()? onStop;
  final Future<void> Function()? onPlayPause;
  final bool isPlaying;
  final PlayerStream playerStream;

  /// Initialise our audio handler.
  MyAudioHandler({
    required this.onPlay,
    required this.onPause,
    required this.onNext,
    required this.onPrevious,
    this.onStop,
    this.onPlayPause,
    required this.isPlaying,
    required this.playerStream,
  }) {
    // So that our clients (the Flutter UI and the system notification) know
    // what state to display, here we set up our audio handler to broadcast all
    // playback state changes as they happen via playbackState...
    playerStream.position
        .map(
          (e) => _transformEvent(
            true,
            e,
          ),
        )
        .pipe(playbackState);

    // ... and also the current media item via mediaItem.
    // mediaItem.add(_item);

    // Load the player.
    // _player.setAudioSource(AudioSource.uri(Uri.parse(_item.id)));
  }

  // The most common callbacks:
  @override
  Future<void> play() async {
    onPlayPause?.call();
  }

  @override
  Future<void> pause() async {
    onPause();
  }

  @override
  Future<void> stop() async {}

  /// Transform a just_audio event into an audio_service state.
  ///
  /// This method is used from the constructor. Every event received from the
  /// just_audio player will be transformed into an audio_service state so that
  /// it can be broadcast to audio_service clients.
  PlaybackState _transformEvent(
    bool isPlaying,
    Duration position,
  ) {
    return PlaybackState(
      controls: [
        // MediaControl.rewind,
        if (isPlaying) MediaControl.pause else MediaControl.play,
        // MediaControl.stop,
        // MediaControl.fastForward,
      ],
      systemActions: const {
        // MediaAction.seek,
        // MediaAction.seekForward,
        // MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      playing: isPlaying,
      updatePosition: position,
    );
  }
}
