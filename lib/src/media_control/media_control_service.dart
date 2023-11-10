import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:media_kit/media_kit.dart';
import 'package:mpris_service/mpris_service.dart';
import 'package:smtc_windows/smtc_windows.dart';

import '../../data.dart';
import '../../utils.dart';
import 'my_audio_handler.dart';

class MediaControlService {
  final MPRIS? mpris;
  final SMTCWindows? smtc;
  final bool? initAudioHandler;
  StreamSubscription<PressedButton>? _smtcSub;
  AudioSession? _audioSession;
  MyAudioHandler? _audioService;

  MediaControlService({this.mpris, this.smtc, this.initAudioHandler});

  Future<void> init({
    required Future<void> Function() onPlay,
    required Future<void> Function() onPause,
    required Future<void> Function() onNext,
    required Future<void> Function() onPrevious,
    Future<void> Function()? onStop,
    required Future<void> Function() onPlayPause,
    required bool isPlaying,
    required PlayerStream playerStream,
  }) async {
    if (smtc != null) {
      _smtcSub = smtc?.buttonPressStream.listen((event) {
        switch (event) {
          case PressedButton.play:
            onPlay()
                .then((_) => smtc?.setPlaybackStatus(PlaybackStatus.Playing));
            break;
          case PressedButton.pause:
            onPause()
                .then((_) => smtc?.setPlaybackStatus(PlaybackStatus.Paused));
            break;
          case PressedButton.next:
            onNext();
            break;
          case PressedButton.previous:
            onPrevious();
            break;
          default:
            break;
        }
      });
    } else if (mpris != null) {
      mpris?.setEventHandler(
        MPRISEventHandler(
          playPause: () async {
            isPlaying ? onPause() : onPlayPause();
            mpris?.playbackStatus = (isPlaying
                ? MPRISPlaybackStatus.paused
                : MPRISPlaybackStatus.playing);
          },
          play: () async {
            onPlay();
          },
          pause: () async {
            onPause();
            mpris?.playbackStatus = MPRISPlaybackStatus.paused;
          },
          next: () async {
            onNext();
          },
          previous: () async {
            onPrevious();
          },
        ),
      );
    } else if (initAudioHandler == true) {
      _audioService = await AudioService.init(
        config: const AudioServiceConfig(
          androidNotificationChannelId:
              'org.feichtmeier.musicpod.channel.audio',
          androidNotificationChannelName: 'MusicPod',
        ),
        builder: () {
          return MyAudioHandler(
            onPlay: onPlay,
            onNext: onNext,
            onPause: onPause,
            onPrevious: onPrevious,
            onPlayPause: onPlayPause,
            isPlaying: isPlaying,
            playerStream: playerStream,
          );
        },
      );

      // _audioSession = await AudioSession.instance;
      await _audioSession?.configure(
        const AudioSessionConfiguration.music(),
      );
      // Activate the audio session before playing audio.
      if (_audioSession != null && await _audioSession!.setActive(true)) {
        // Now play audio.
      } else {
        // The request was denied and the app should not play audio
      }

      _audioSession?.interruptionEventStream.listen((event) {
        if (event.begin) {
          switch (event.type) {
            case AudioInterruptionType.duck:
              // Another app started playing audio and we should duck.
              break;
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              // Another app started playing audio and we should pause.
              break;
          }
        } else {
          switch (event.type) {
            case AudioInterruptionType.duck:
              // The interruption ended and we should unduck.
              break;
            case AudioInterruptionType.pause:
            // The interruption ended and we should resume.
            case AudioInterruptionType.unknown:
              // The interruption ended but we should not resume.
              break;
          }
        }
      });

      _audioSession?.becomingNoisyEventStream.listen((_) {
        // The user unplugged the headphones, so we should pause or lower the volume.
      });
    }
  }

  Future<void> setMetaData(Audio audio) async {
    if (mpris != null) {
      await _setMprisMetadata(audio);
    } else if (smtc != null) {
      await _setSmtcMetaData(audio);
    } else if (_audioService != null) {
      await _setAudioServiceMetaData(audio);
    }
  }

  Future<void> _setAudioServiceMetaData(Audio audio) async {
    _audioService?.mediaItem.add(
      MediaItem(
        id: audio.toString(),
        title: audio.title ?? '',
        artist: audio.artist,
        artUri: await createUriFromAudio(audio),
      ),
    );
  }

  Future<void> setPlayBackStatus(bool isPlaying) async {
    mpris?.playbackStatus =
        isPlaying ? MPRISPlaybackStatus.playing : MPRISPlaybackStatus.paused;
    smtc?.setPlaybackStatus(
      isPlaying ? PlaybackStatus.Playing : PlaybackStatus.Paused,
    );
  }

  Future<void> _setSmtcMetaData(Audio audio) async {
    final uri = await createUriFromAudio(audio);
    smtc?.updateMetadata(
      MusicMetadata(
        title: audio.title,
        album: audio.album,
        albumArtist: audio.albumArtist,
        artist: audio.artist,
        thumbnail: '$uri',
      ),
    );
  }

  Future<void> _setMprisMetadata(Audio audio) async {
    if (audio.url == null && audio.path == null) return;
    mpris?.metadata = MPRISMetadata(
      audio.path != null ? Uri.file(audio.path!) : Uri.parse(audio.url!),
      artUrl: await createUriFromAudio(audio),
      album: audio.album,
      albumArtist: [audio.albumArtist ?? ''],
      artist: [audio.artist ?? ''],
      discNumber: audio.discNumber,
      title: audio.title,
      trackNumber: audio.trackNumber,
    );
  }

  Future<void> dispose() async {
    await _smtcSub?.cancel();
    await mpris?.dispose();
    await smtc?.disableSmtc();
    await smtc?.dispose();
    // await _audioHandler?.
  }
}
