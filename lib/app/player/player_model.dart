import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:mpris_service/mpris_service.dart';
import 'package:musicpod/app/common/constants.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/utils.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class PlayerModel extends SafeChangeNotifier {
  PlayerModel(MPRIS mpris)
      : _player = Player(
          configuration: const PlayerConfiguration(
            title: 'MusicPod',
          ),
        ),
        _mediaControlService = mpris;

  final Player _player;
  final MPRIS _mediaControlService;
  StreamSubscription<bool>? _playerSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<bool>? _isCompletedSub;

  String? _queueName;
  String? get queueName => _queueName;
  void setQueueName(String? value) {
    if (value == null || value == _queueName) return;
    _queueName = value;
    notifyListeners();
  }

  List<Audio>? _queue;
  List<Audio>? get queue => _queue;
  set queue(List<Audio>? value) {
    if (value == null) return;
    _queue = value;
    notifyListeners();
  }

  bool? _fullScreen;
  bool? get fullScreen => _fullScreen;
  void setFullScreen(bool? value) {
    if (value == null || value == _fullScreen) return;
    _fullScreen = value;
    notifyListeners();
  }

  Audio? _audio;
  Audio? get audio => _audio;
  void setAudio(Audio? value) {
    if (value == null || value == _audio) return;
    _audio = value;

    if (audio!.path != null || audio!.url != null) {
      _mediaControlService.metadata = MPRISMetadata(
        audio!.path != null ? Uri.file(audio!.path!) : Uri.parse(audio!.url!),
        artUrl: _audio!.imageUrl == null
            ? null
            : Uri.parse(
                _audio!.imageUrl!,
              ),
        album: _audio?.album,
        albumArtist: [_audio?.albumArtist ?? ''],
        artist: [_audio?.albumArtist ?? ''],
        discNumber: _audio?.discNumber,
        title: _audio?.title,
        trackNumber: _audio?.trackNumber,
      );
    }

    notifyListeners();
  }

  Audio? _nextAudio;
  Audio? get nextAudio => _nextAudio;
  set nextAudio(Audio? value) {
    if (value == null || value == _nextAudio) return;
    _nextAudio = value;
    notifyListeners();
  }

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;
  set isPlaying(bool value) {
    _isPlaying = value;
    notifyListeners();
  }

  Duration? _duration;
  Duration? get duration => _duration;
  void setDuration(Duration? value) {
    _duration = value;
    notifyListeners();
  }

  Duration? _position = Duration.zero;
  Duration? get position => _position;
  void setPosition(Duration? value) {
    _position = value;
    notifyListeners();
  }

  bool _repeatSingle = false;
  bool get repeatSingle => _repeatSingle;
  void setRepeatSingle(bool value) {
    if (value == _repeatSingle) return;
    _repeatSingle = value;
    if (value) {
      _player.setPlaylistMode(PlaylistMode.single);
    } else {
      _player.setPlaylistMode(PlaylistMode.none);
    }
    notifyListeners();
  }

  bool _shuffle = false;
  bool get shuffle => _shuffle;
  void setShuffle(bool value) {
    if (value == _shuffle) return;
    _shuffle = value;
    notifyListeners();
  }

  Future<void> play({bool bigPlay = false, Audio? newAudio}) async {
    if (newAudio != null) {
      setAudio(newAudio);
    }
    if (audio == null) return;
    queue ??= [];
    if (!queue!.contains(audio)) {
      queue!.insert(0, audio!);
    }
    final playList = Playlist([
      if (audio!.path != null)
        Media('file://${audio!.path!}')
      else if (audio!.url != null)
        Media(audio!.url!),
    ]);

    Duration? firstPlayPosition = _position;
    _player.open(playList);
    if (bigPlay &&
        _firstPlay &&
        firstPlayPosition != null &&
        _audio!.audioType != AudioType.radio) {
      _player.setVolume(0).then(
            (_) => Future.delayed(const Duration(seconds: 1)).then(
              (_) => _player
                  .seek(firstPlayPosition)
                  .then((_) => _player.setVolume(100.0)),
            ),
          );
    }
    _firstPlay = false;
    loadColor();
  }

  Future<void> playOrPause() async {
    return _firstPlay ? play(bigPlay: true) : _player.playOrPause();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> seek() async {
    if (position == null) return;
    await _player.seek(position!);
  }

  Future<void> resume() async {
    if (audio == null) return;
    await _player.playOrPause();
  }

  Future<void> init() async {
    _mediaControlService.setEventHandler(
      MPRISEventHandler(
        playPause: () async {
          isPlaying ? pause() : playOrPause();
          _mediaControlService.playbackStatus = (isPlaying
              ? MPRISPlaybackStatus.paused
              : MPRISPlaybackStatus.playing);
        },
        play: () async {
          play();
        },
        pause: () async {
          pause();
          _mediaControlService.playbackStatus = MPRISPlaybackStatus.paused;
        },
        next: () async {
          playNext();
        },
        previous: () async {
          playPrevious();
        },
      ),
    );

    await _readLastAudio();

    _playerSub = _player.streams.playing.listen((p) {
      isPlaying = p;
      _mediaControlService.playbackStatus =
          isPlaying ? MPRISPlaybackStatus.playing : MPRISPlaybackStatus.paused;
    });
    _durationSub = _player.streams.duration.listen((newDuration) {
      setDuration(newDuration);
    });
    _positionSub = _player.streams.position.listen((newPosition) {
      setPosition(newPosition);
    });

    _isCompletedSub = _player.streams.completed.listen((value) async {
      if (value) {
        if (repeatSingle == false) {
          await playNext();
        }
      }
    });

    notifyListeners();
  }

  Future<void> playNext() async {
    if (nextAudio == null) return;
    setAudio(nextAudio);
    estimateNext();

    await play();
  }

  void estimateNext() {
    if (queue?.isNotEmpty == true && audio != null && queue!.contains(audio)) {
      final currentIndex = queue!.indexOf(audio!);
      final max = queue!.length;

      if (shuffle) {
        final random = Random();
        var randomIndex = random.nextInt(max);
        while (randomIndex == currentIndex) {
          randomIndex = random.nextInt(max);
        }
        nextAudio = queue!.elementAt(randomIndex);
      } else {
        if (currentIndex == queue!.length - 1) {
          nextAudio = queue!.elementAt(0);
        } else {
          nextAudio = queue?.elementAt(queue!.indexOf(audio!) + 1);
        }
      }
    }
  }

  Future<void> playPrevious() async {
    if (queue?.isNotEmpty == true && audio != null && queue!.contains(audio)) {
      final currentIndex = queue!.indexOf(audio!);

      if (currentIndex == 0) {
        return;
      }

      nextAudio = queue?.elementAt(currentIndex - 1);

      if (nextAudio == null) return;
      setAudio(nextAudio);

      await play();
    }
  }

  Future<void> startPlaylist(Set<Audio> audios, String listName) async {
    queue = audios.toList();
    setQueueName(listName);
    setAudio(audios.first);
    estimateNext();
    await play();
  }

  Color? _color;
  void resetColor() => _color = null;
  Color? get color => _color;
  Color? get surfaceTintColor => _color?.withOpacity(0.1);

  Future<void> loadColor() async {
    if (audio == null) return;
    if (audio?.path != null && audio?.pictureData != null) {
      final image = MemoryImage(
        audio!.pictureData!,
      );
      final generator = await PaletteGenerator.fromImageProvider(image);
      _color = generator.dominantColor?.color;
    } else {
      if (audio?.imageUrl == null && audio?.albumArtUrl == null) return;

      final image = NetworkImage(
        audio!.imageUrl ?? audio!.albumArtUrl!,
      );
      final generator = await PaletteGenerator.fromImageProvider(image);
      _color = generator.dominantColor?.color;
    }
    notifyListeners();
  }

  bool _isUpNextExpanded = false;
  bool get isUpNextExpanded => _isUpNextExpanded;
  void setUpNextExpanded(bool value) {
    if (value == _isUpNextExpanded) return;
    _isUpNextExpanded = value;
    notifyListeners();
  }

  Future<void> _writeLastAudio() async {
    await writeSetting(kLastPositionAsString, _position.toString());
    await writeSetting(kLastDurationAsString, _duration.toString());
    await writeSetting(kLastAudio, _audio?.toJson());
  }

  bool _firstPlay = true;
  Future<void> _readLastAudio() async {
    final positionAsString = await readSetting(kLastPositionAsString);
    final durationAsString = await readSetting(kLastDurationAsString);
    if (positionAsString != null) {
      setPosition(parseDuration(positionAsString));
    }
    final maybeAudio = await readSetting(kLastAudio);
    if (maybeAudio != null) {
      _audio = Audio.fromJson(maybeAudio);
      if (durationAsString != null) {
        setDuration(parseDuration(durationAsString));
      }
    }
  }

  @override
  Future<void> dispose() async {
    await _writeLastAudio();
    await _mediaControlService.dispose();
    await _playerSub?.cancel();
    await _positionSub?.cancel();
    await _durationSub?.cancel();
    await _isCompletedSub?.cancel();
    await _player.dispose();
    super.dispose();
  }
}
