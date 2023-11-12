import 'dart:async';

import 'package:audio_service/audio_service.dart';
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
  MyAudioHandler? _audioService;

  MediaControlService({this.mpris, this.smtc, this.initAudioHandler});

  Future<void> init({
    required Future<void> Function() onPlay,
    required Future<void> Function() onPause,
    required Future<void> Function() onNext,
    required Future<void> Function() onPrevious,
    required Future<void> Function(Duration position) onSeek,
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
            mpris?.playbackStatus == MPRISPlaybackStatus.playing
                ? onPause()
                : onPlay();
          },
          play: () async {
            onPlay();
          },
          pause: () async {
            onPause();
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
            onSeek: onSeek,
          );
        },
      );
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

  Future<void> setPlayBackStatus(bool playing) async {
    mpris?.playbackStatus =
        playing ? MPRISPlaybackStatus.playing : MPRISPlaybackStatus.paused;
    smtc?.setPlaybackStatus(
      playing ? PlaybackStatus.Playing : PlaybackStatus.Paused,
    );
    _audioService?.playbackState.add(
      PlaybackState(playing: playing),
    );
  }

  Future<void> setPosition(Duration position) async {
    _audioService?.playbackState.add(PlaybackState(updatePosition: position));
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

  Future<void> _setAudioServiceMetaData(Audio audio) async {
    _audioService?.mediaItem.add(
      MediaItem(
        id: audio.toString(),
        duration: audio.durationMs == null
            ? null
            : Duration(milliseconds: audio.durationMs!.toInt()),
        title: audio.title ?? '',
        artist: audio.artist,
        artUri: await createUriFromAudio(audio),
      ),
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
