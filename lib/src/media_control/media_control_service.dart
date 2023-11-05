import 'package:mpris_service/mpris_service.dart';
import 'package:musicpod/utils.dart';
import 'package:smtc_windows/smtc_windows.dart';

import '../../data.dart';

class MediaControlService {
  final MPRIS? _mpris;
  final SMTCWindows? _smtc;

  MediaControlService([this._mpris, this._smtc]);

  Future<void> init({
    required Future<void> Function() onPlay,
    required Future<void> Function() onPause,
    required Future<void> Function() onNext,
    required Future<void> Function() onPrevious,
    Future<void> Function()? onStop,
    Future<void> Function()? onPlayPause,
    required bool isPlaying,
  }) async {
    if (_smtc != null) {
      _smtc?.buttonPressStream.listen((event) {
        switch (event) {
          case PressedButton.play:
            onPlay();
            _smtc?.setPlaybackStatus(PlaybackStatus.Playing);
            break;
          case PressedButton.pause:
            onPause();
            _smtc?.setPlaybackStatus(PlaybackStatus.Paused);
            break;
          case PressedButton.next:
            onNext();
            break;
          case PressedButton.previous:
            onPrevious();
            break;
          case PressedButton.stop:
            onStop?.call();
            _smtc?.setPlaybackStatus(PlaybackStatus.Stopped);
            _smtc?.disableSmtc();
            break;
          default:
            break;
        }
      });
    } else if (_mpris != null) {
      _mpris?.setEventHandler(
        MPRISEventHandler(
          playPause: () async {
            isPlaying ? onPause() : onPlayPause?.call();
            _mpris?.playbackStatus = (isPlaying
                ? MPRISPlaybackStatus.paused
                : MPRISPlaybackStatus.playing);
          },
          play: () async {
            onPlay();
          },
          pause: () async {
            onPause();
            _mpris!.playbackStatus = MPRISPlaybackStatus.paused;
          },
          next: () async {
            onNext();
          },
          previous: () async {
            onPrevious();
          },
        ),
      );
    }
  }

  Future<void> setMetaData(Audio audio) async {
    if (_mpris != null) {
      _mpris?.metadata = await _createMprisMetadata(audio);
    } else if (_smtc != null) {
      await _setSmtcMetaData(audio);
    }
  }

  Future<void> setPlayBackStatus(bool isPlaying) async {
    _mpris?.playbackStatus =
        isPlaying ? MPRISPlaybackStatus.playing : MPRISPlaybackStatus.paused;
    _smtc?.setPlaybackStatus(
      isPlaying ? PlaybackStatus.Playing : PlaybackStatus.Paused,
    );
  }

  Future<void> _setSmtcMetaData(Audio audio) async {
    final uri = await createUriFromAudio(audio);
    _smtc?.updateMetadata(
      MusicMetadata(
        title: audio.title,
        album: audio.album,
        albumArtist: audio.albumArtist,
        artist: audio.artist,
        thumbnail: '$uri',
      ),
    );
  }

  Future<MPRISMetadata> _createMprisMetadata(Audio audio) async {
    return MPRISMetadata(
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
    await _mpris?.dispose();
    await _smtc?.dispose();
  }
}
