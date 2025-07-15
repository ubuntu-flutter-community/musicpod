import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:watch_it/watch_it.dart';

import '../app_config.dart';
import '../common/data/audio.dart';
import '../common/data/audio_type.dart';
import '../extensions/taget_platform_x.dart';
import 'player_service.dart';

Future<AudioServiceHandler> registerAudioServiceHandler() async {
  final playerService = di<PlayerService>();
  final audioHandler = await AudioService.init(
    config: AudioServiceConfig(
      androidNotificationOngoing: false,
      androidStopForegroundOnPause: false,
      androidNotificationChannelName: AppConfig.appName,
      androidNotificationChannelId: isAndroid
          ? AppConfig.androidChannelId
          : null,
      androidNotificationChannelDescription: 'MusicPod Media Controls',
    ),
    builder: () => AudioServiceHandler(
      onPlay: playerService.playOrPause,
      onNext: playerService.playNext,
      onPause: playerService.pause,
      onPrevious: playerService.playPrevious,
      onSeek: (position) async {
        playerService.setPosition(position);
        await playerService.seek();
      },
    ),
  );

  playerService.registerMediaControlsCallBacks(
    onIsPlaying:
        ({required audioType, required isPlaying, required queueNotEmpty}) {
          audioHandler.playbackState.add(
            audioHandler.playbackState.value.copyWith(
              playing: isPlaying,
              controls: [
                if (audioType == AudioType.podcast && (isMacOS || isAndroid))
                  MediaControl.rewind
                else if (queueNotEmpty && audioType != AudioType.radio)
                  MediaControl.skipToPrevious,
                isPlaying ? MediaControl.pause : MediaControl.play,
                if (audioType == AudioType.podcast && (isMacOS || isAndroid))
                  MediaControl.fastForward
                else if (queueNotEmpty && audioType != AudioType.radio)
                  MediaControl.skipToNext,
              ],
              processingState: AudioProcessingState.ready,
            ),
          );
          return Future.value();
        },
    onSetMetaData: ({required Uri? artUri, required Audio audio}) {
      audioHandler.mediaItem.add(
        MediaItem(
          id: audio.toString(),
          title: audio.title ?? AppConfig.appTitle,
          artist: audio.artist ?? '',
          artUri: artUri,
          duration: audio.durationMs == null
              ? null
              : Duration(milliseconds: audio.durationMs!.toInt()),
        ),
      );
      return Future.value();
    },
    onSetPosition: (position) {
      audioHandler.playbackState.add(
        audioHandler.playbackState.value.copyWith(
          updatePosition: position ?? Duration.zero,
        ),
      );
      return Future.value();
    },
    onSetDuration: (duration) {
      if (audioHandler.mediaItem.value != null) {
        audioHandler.mediaItem.add(
          audioHandler.mediaItem.value!.copyWith(duration: duration),
        );
      }

      return Future.value();
    },
  );

  return audioHandler;
}

class AudioServiceHandler extends BaseAudioHandler with SeekHandler {
  final Future<void> Function() onPlay;
  final Future<void> Function() onPause;
  final Future<void> Function() onNext;
  final Future<void> Function() onPrevious;
  final Future<void> Function(Duration position) onSeek;

  @override
  AudioServiceHandler({
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
