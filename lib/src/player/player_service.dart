import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart' hide PlayerState;
import 'package:media_kit_video/media_kit_video.dart';
import 'package:mpris_service/mpris_service.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:path/path.dart' as p;
import 'package:signals_flutter/signals_flutter.dart';
import 'package:smtc_windows/smtc_windows.dart';

import '../../constants.dart';
import '../../data.dart';
import '../../player.dart';
import '../../utils.dart';
import 'my_audio_handler.dart';

class PlayerService {
  PlayerService({
    required this.controller,
  });

  final VideoController controller;

  MPRIS? _mpris;
  SMTCWindows? _smtc;
  MyAudioHandler? _audioService;

  StreamSubscription<PressedButton>? _smtcSub;
  StreamSubscription<bool>? _isPlayingSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<bool>? _isCompletedSub;
  StreamSubscription<double>? _volumeSub;
  StreamSubscription<Tracks>? _tracksSub;
  StreamSubscription<double>? _rateSub;

  Player get _player => controller.player;

  final Signal<(String, List<Audio>)> queue = signal(('', []));
  void setQueue((String, List<Audio>) value) {
    if (value == queue.value || value.$2.isEmpty) return;
    queue.value = value;
  }

  final Signal<MpvMetaData?> mpvMetaData = signal(null);
  void setMpvMetaData(MpvMetaData value) {
    if (value == mpvMetaData.value) return;
    mpvMetaData.value = value;
  }

  final Signal<Audio?> audio = signal(null);
  void _setAudio(Audio value) async {
    if (value == audio.value) return;
    audio.value = value;
  }

  final Signal<bool?> isVideo = signal(null);
  void _setIsVideo(bool? value) {
    isVideo.value = value;
  }

  final Signal<Audio?> nextAudio = signal(null);
  void setNextAudio(Audio? value) {
    if (value == null || value == nextAudio.value) return;
    nextAudio.value = value;
  }

  final Signal<bool> isPlaying = signal(false);
  void setIsPlaying(bool value) {
    if (value == isPlaying.value) return;
    isPlaying.value = value;
    _setMediaControlsIsPlaying(value);
  }

  final Signal<Duration?> duration = signal(null);
  void setDuration(Duration? value) {
    if (value == null || value.inSeconds == duration.value?.inSeconds) return;
    duration.value = value;
    _setMediaControlDuration(value);
  }

  final Signal<Duration?> position = signal(null);
  void setPosition(Duration? value) {
    if (position.value?.inSeconds == value?.inSeconds) return;
    position.value = value;
    _setMediaControlPosition(value);
  }

  final Signal<bool> repeatSingle = signal(false);
  void setRepeatSingle(bool value) {
    if (value == repeatSingle.value) return;
    repeatSingle.value = value;
    _estimateNext();
  }

  final Signal<bool> shuffle = signal(false);
  void setShuffle(bool value) {
    if (value == shuffle.value) return;
    shuffle.value = value;
    if (value && queue.value.$2.length > 1) {
      _randomNext();
    }
  }

  final Signal<double> volume = signal(100.0);
  Future<void> setVolume(double value) async {
    if (value == volume.value) return;
    await _player.setVolume(value);
  }

  final Signal<double> rate = signal(1.0);
  Future<void> setRate(double value) async {
    if (value == rate.value) return;
    await _player.setRate(value);
  }

  bool _firstPlay = true;
  Future<void> play({Duration? newPosition, Audio? newAudio}) async {
    try {
      batch(() {
        if (newAudio != null) {
          audio.value = newAudio;
        }
        if (audio.value == null) return;

        Media? media = audio.value!.path != null
            ? Media('file://${audio.value!.path!}')
            : (audio.value!.url != null)
                ? Media(audio.value!.url!)
                : null;
        if (media == null) return;
        _player.open(media).then((_) {
          _player.state.tracks;
        });
        if (newPosition != null && audio.value!.audioType != AudioType.radio) {
          _player.setVolume(0).then(
                (_) => Future.delayed(const Duration(seconds: 3)).then(
                  (_) => _player
                      .seek(newPosition)
                      .then((_) => _player.setVolume(100.0)),
                ),
              );
        }
        _setMediaControlsMetaData(audio.value!);
        _loadColor();
        _firstPlay = false;
      });
    } on Exception catch (_) {
      // TODO: instead of disallowing certain file types
      // process via error stream if something went wrong
    }
  }

  Future<void> playOrPause() async {
    return _firstPlay
        ? play(newPosition: position.value)
        : _player.playOrPause();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> seek() async {
    if (position.value == null) return;
    await _player.seek(position.value!);
  }

  Future<void> resume() async {
    if (audio.value == null) return;
    await playOrPause();
  }

  Future<void> init() async {
    await _initMediaControl();

    await _readPlayerState();
    lastPositions.value = (await getSettings(kLastPositionsFileName)).map(
      (key, value) => MapEntry(key, parseDuration(value) ?? Duration.zero),
    );

    _isPlayingSub = _player.stream.playing.listen((value) {
      setIsPlaying(value);
    });

    _durationSub = _player.stream.duration.listen((newDuration) {
      setDuration(newDuration);
    });

    _positionSub = _player.stream.position.listen((newPosition) {
      setPosition(newPosition);
    });

    _isCompletedSub = _player.stream.completed.listen((value) async {
      if (value) {
        await playNext();
      }
    });

    await (_player.platform as NativePlayer).observeProperty(
      'metadata',
      (data) async => setMpvMetaData(MpvMetaData.fromJson(data)),
    );

    _volumeSub = _player.stream.volume.listen((value) => setVolume(value));

    _rateSub = _player.stream.rate.listen((value) => setRate(value));

    _tracksSub = _player.stream.tracks.listen((tracks) {
      _setIsVideo(false);
      for (var track in tracks.video) {
        if (track.fps != null && track.fps! > 1) {
          _setIsVideo(true);
          break;
        }
      }
    });
  }

  Future<void> playNext() async {
    safeLastPosition();
    if (!repeatSingle.value && nextAudio.value != null) {
      _setAudio(nextAudio.value!);
      _estimateNext();
    }
    await play();
  }

  void insertIntoQueue(Audio newAudio) {
    if (queue.value.$2.isNotEmpty &&
        !queue.value.$2.contains(newAudio) &&
        audio.value != null) {
      final currentIndex = queue.value.$2.indexOf(audio.value!);
      queue.value.$2.insert(currentIndex + 1, newAudio);
      setNextAudio(newAudio);
    }
  }

  void moveAudioInQueue(int oldIndex, int newIndex) {
    if (queue.value.$2.isNotEmpty && newIndex < queue.value.$2.length) {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }

      final audio = queue.value.$2.removeAt(oldIndex);
      queue.value.$2.insert(newIndex, audio);

      _estimateNext();
    }
  }

  void remove(Audio deleteMe) {
    queue.value.$2.remove(deleteMe);
    _estimateNext();
  }

  void _estimateNext() {
    if (audio.value == null) return;

    if (queue.value.$2.isNotEmpty == true &&
        queue.value.$2.contains(audio.value)) {
      final currentIndex = queue.value.$2.indexOf(audio.value!);

      if (shuffle.value && queue.value.$2.length > 1) {
        _randomNext();
      } else {
        if (currentIndex == queue.value.$2.length - 1) {
          setNextAudio(queue.value.$2.elementAt(0));
        } else {
          setNextAudio(
            queue.value.$2.elementAt(queue.value.$2.indexOf(audio.value!) + 1),
          );
        }
      }
    }
  }

  void _randomNext() {
    if (audio.value == null) return;
    final currentIndex = queue.value.$2.indexOf(audio.value!);
    final max = queue.value.$2.length;
    final random = Random();
    var randomIndex = random.nextInt(max);
    while (randomIndex == currentIndex) {
      randomIndex = random.nextInt(max);
    }
    setNextAudio(queue.value.$2.elementAt(randomIndex));
  }

  Future<void> playPrevious() async {
    if (queue.value.$2.isNotEmpty == true &&
        audio.value != null &&
        queue.value.$2.contains(audio.value)) {
      if (position.value != null && position.value!.inSeconds > 10) {
        setPosition(Duration.zero);
        await seek();
      } else {
        final currentIndex = queue.value.$2.indexOf(audio.value!);
        if (currentIndex == 0) {
          return;
        }
        final mightBePrevious =
            queue.value.$2.elementAtOrNull(currentIndex - 1);
        if (mightBePrevious == null) return;
        _setAudio(mightBePrevious);
        _estimateNext();
        await play();
      }
    }
  }

  Future<void> startPlaylist({
    required Set<Audio> audios,
    required String listName,
    int? index,
  }) async {
    if (listName == queue.value.$1 &&
        index != null &&
        audios.elementAtOrNull(index) != null) {
      _setAudio(audios.elementAtOrNull(index)!);
    } else {
      setQueue((listName, audios.toList()));
      final a = (index != null && audios.elementAtOrNull(index) != null)
          ? audios.elementAtOrNull(index)!
          : audios.firstOrNull;
      if (a != null) _setAudio(a);
    }

    position.value = getLastPosition.call(audio.value?.url);
    _estimateNext();
    await play(newPosition: position.value);
  }

  final Signal<Color?> color = signal(null);

  Future<void> _loadColor() async {
    if (audio.value == null) {
      color.value = kCardColorDark;
      return;
    }

    if (audio.value?.path != null && audio.value?.pictureData != null) {
      final image = MemoryImage(
        audio.value!.pictureData!,
      );
      final generator = await PaletteGenerator.fromImageProvider(image);
      color.value = generator.dominantColor?.color;
    } else {
      if (audio.value?.imageUrl == null && audio.value?.albumArtUrl == null) {
        return;
      }

      final image = NetworkImage(
        audio.value!.imageUrl ?? audio.value!.albumArtUrl!,
      );
      final generator = await PaletteGenerator.fromImageProvider(image);
      color.value = generator.dominantColor?.color;
    }
  }

  Future<void> _readPlayerState() async {
    final playerState = await readPlayerState();

    if (playerState?.audio != null) {
      _setAudio(playerState!.audio!);

      if (playerState.duration != null) {
        setDuration(parseDuration(playerState.duration!));
      }
      if (playerState.position != null) {
        setPosition(parseDuration(playerState.position!));
      }

      if (playerState.queue?.isNotEmpty == true &&
          playerState.queueName?.isNotEmpty == true) {
        setQueue((playerState.queueName!, playerState.queue!));
      }

      _estimateNext();

      await _setMediaControlsMetaData(playerState.audio!);
    }
  }

  Future<void> _initMediaControl() async {
    if (Platform.isLinux) {
      await _initMpris();
    } else if (Platform.isWindows) {
      _initSmtc();
    } else if (Platform.isAndroid || Platform.isMacOS) {
      await _initAudioService();
    }
  }

  void _initSmtc() {
    _smtc = SMTCWindows(
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

    _smtcSub = _smtc?.buttonPressStream.listen((event) {
      switch (event) {
        case PressedButton.play:
          playOrPause().then(
            (_) => _smtc?.setPlaybackStatus(
              isPlaying.value ? PlaybackStatus.Playing : PlaybackStatus.Paused,
            ),
          );
          break;
        case PressedButton.pause:
          playOrPause().then(
            (_) => _smtc?.setPlaybackStatus(
              isPlaying.value ? PlaybackStatus.Playing : PlaybackStatus.Paused,
            ),
          );
          break;
        case PressedButton.next:
          playNext();
          break;
        case PressedButton.previous:
          playPrevious();
          break;
        default:
          break;
      }
    });
  }

  Future<void> _initMpris() async {
    _mpris = await MPRIS.create(
      busName: kBusName,
      identity: kAppName,
      desktopEntry: kDesktopEntry,
    );
    _mpris?.setEventHandler(
      MPRISEventHandler(
        playPause: () async {
          _mpris?.playbackStatus == MPRISPlaybackStatus.playing
              ? pause()
              : playOrPause();
        },
        play: () async {
          play();
        },
        pause: () async {
          pause();
        },
        next: () async {
          playNext();
        },
        previous: () async {
          playPrevious();
        },
      ),
    );
  }

  Future<void> _initAudioService() async {
    _audioService = await AudioService.init(
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'org.feichtmeier.musicpod.channel.audio',
        androidNotificationChannelName: 'MusicPod',
      ),
      builder: () {
        return MyAudioHandler(
          onPlay: playOrPause,
          onNext: playNext,
          onPause: pause,
          onPrevious: playPrevious,
          onSeek: (position) async {
            setPosition(position);
            await seek();
          },
        );
      },
    );
    if (_audioService == null) return;
    _audioService!.playbackState.add(
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

  void _setMediaControlPosition(Duration? position) {
    if (_audioService == null) return;
    _audioService!.playbackState.add(
      _audioService!.playbackState.value.copyWith(
        updatePosition: position ?? Duration.zero,
      ),
    );
  }

  void _setMediaControlDuration(Duration? duration) {
    if (_audioService == null || _audioService!.mediaItem.value == null) return;
    _audioService!.mediaItem
        .add(_audioService!.mediaItem.value!.copyWith(duration: duration));
  }

  Future<void> _setMediaControlsMetaData(Audio audio) async {
    final uri = await createUriFromAudio(audio);

    _setMprisMetadata(audio, uri);
    _setSmtcMetaData(audio, uri);
    _setAudioServiceMetaData(audio, uri);
  }

  Future<void> _setMediaControlsIsPlaying(bool playing) async {
    _mpris?.playbackStatus =
        playing ? MPRISPlaybackStatus.playing : MPRISPlaybackStatus.paused;
    _smtc?.setPlaybackStatus(
      playing ? PlaybackStatus.Playing : PlaybackStatus.Paused,
    );
    if (_audioService != null) {
      _audioService!.playbackState.add(
        _audioService!.playbackState.value.copyWith(
          playing: playing,
          controls: [
            MediaControl.skipToPrevious,
            MediaControl.rewind,
            playing ? MediaControl.pause : MediaControl.play,
            MediaControl.fastForward,
            MediaControl.skipToNext,
          ],
        ),
      );
    }
  }

  void _setSmtcMetaData(Audio audio, Uri? artUri) {
    if (_smtc == null) return;
    _smtc!.updateMetadata(
      MusicMetadata(
        title: audio.title,
        album: audio.album,
        albumArtist: audio.artist,
        artist: audio.artist,
        thumbnail: audio.audioType == AudioType.local
            ? kFallbackThumbnail
            : artUri == null
                ? null
                : '$artUri',
      ),
    );
  }

  void _setMprisMetadata(Audio audio, Uri? artUri) {
    if (_mpris == null || audio.url == null && audio.path == null) return;
    _mpris!.metadata = MPRISMetadata(
      audio.path != null ? Uri.file(audio.path!) : Uri.parse(audio.url!),
      artUrl: artUri,
      album: audio.album,
      albumArtist: [audio.albumArtist ?? ''],
      artist: [audio.artist ?? ''],
      discNumber: audio.discNumber,
      title: audio.title,
      trackNumber: audio.trackNumber,
    );
  }

  void _setAudioServiceMetaData(Audio audio, Uri? artUri) {
    if (_audioService == null) return;
    _audioService!.mediaItem.add(
      MediaItem(
        id: audio.toString(),
        duration: audio.durationMs == null
            ? null
            : Duration(milliseconds: audio.durationMs!.toInt()),
        title: audio.title ?? '',
        artist: audio.artist,
        artUri: artUri,
      ),
    );
  }

  Future<void> dispose() async {
    await writePlayerState();
    await _smtcSub?.cancel();
    await _mpris?.dispose();
    await _smtc?.disableSmtc();
    await _smtc?.dispose();
    await _isPlayingSub?.cancel();
    await _positionSub?.cancel();
    await _durationSub?.cancel();
    await _isCompletedSub?.cancel();
    await _volumeSub?.cancel();
    await _tracksSub?.cancel();
    await _rateSub?.cancel();
    await _player.dispose();
  }

  //
  // last positions
  //
  final Signal<Map<String, Duration>> lastPositions = mapSignal({});
  void safeLastPosition() {
    if (audio.value?.audioType == AudioType.radio ||
        audio.value?.url == null ||
        position.value == null) return;
    _addLastPosition(audio.value!.url!, position.value!);
  }

  void _addLastPosition(String url, Duration lastPosition) {
    writeSetting(url, lastPosition.toString(), kLastPositionsFileName)
        .then((_) {
      if (lastPositions.value.containsKey(url) == true) {
        lastPositions.value.update(url, (value) => lastPosition);
      } else {
        lastPositions.value.putIfAbsent(url, () => lastPosition);
      }
    });
  }

  Duration? getLastPosition(String? url) => lastPositions.value[url];

  // Player State

  Future<void> writePlayerState() async {
    final playerState = PlayerState(
      audio: audio.value,
      duration: duration.value?.toString(),
      position: position.value?.toString(),
      queue: queue.value.$2.take(100).toList(),
      queueName: queue.value.$1,
    );

    await writeJsonToFile(playerState.toMap(), kPlayerStateFileName);
  }

  Future<PlayerState?> readPlayerState() async {
    try {
      final workingDir = await getWorkingDir();
      final file = File(p.join(workingDir, kPlayerStateFileName));

      if (file.existsSync()) {
        final jsonStr = await file.readAsString();

        return PlayerState.fromJson(jsonStr);
      } else {
        return null;
      }
    } on Exception catch (_) {
      return null;
    }
  }
}
