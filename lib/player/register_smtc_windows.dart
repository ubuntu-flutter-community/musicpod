import 'package:smtc_windows/smtc_windows.dart';
import 'package:watch_it/watch_it.dart';

import '../app_config.dart';
import '../common/data/audio_type.dart';
import 'player_service.dart';

Future<SMTCWindows> registerSMTCWindows() async {
  final playerService = di<PlayerService>();

  await SMTCWindows.initialize();
  final smtc = SMTCWindows(
    enabled: true,
    config: const SMTCConfig(
      fastForwardEnabled: false,
      nextEnabled: true,
      pauseEnabled: true,
      playEnabled: true,
      rewindEnabled: false,
      prevEnabled: true,
      stopEnabled: false,
    ),
  );

  smtc.buttonPressStream.listen((event) {
    switch (event) {
      case PressedButton.play:
        playerService.playOrPause().then(
          (_) => smtc.setPlaybackStatus(
            playerService.isPlaying
                ? PlaybackStatus.playing
                : PlaybackStatus.paused,
          ),
        );
      case PressedButton.pause:
        playerService.playOrPause().then(
          (_) => smtc.setPlaybackStatus(
            playerService.isPlaying
                ? PlaybackStatus.playing
                : PlaybackStatus.paused,
          ),
        );
      case PressedButton.next:
        playerService.playNext();
      case PressedButton.previous:
        playerService.playPrevious();
      default:
        break;
    }
  });

  playerService.registerMediaControlsCallBacks(
    onSetMetaData: ({required artUri, required audio}) => smtc.updateMetadata(
      MusicMetadata(
        title: audio.title ?? AppConfig.appTitle,
        album: audio.album,
        albumArtist: audio.artist,
        artist: audio.artist ?? '',
        thumbnail: audio.audioType == AudioType.local
            ? AppConfig.fallbackThumbnailUrl
            : artUri == null
            ? null
            : '$artUri',
      ),
    ),
    onIsPlaying:
        ({required audioType, required isPlaying, required queueNotEmpty}) =>
            smtc.setPlaybackStatus(
              isPlaying ? PlaybackStatus.playing : PlaybackStatus.paused,
            ),
    onSetPosition: (position) => smtc.setPosition(position ?? Duration.zero),
    onSetDuration: null,
  );

  return smtc;
}
