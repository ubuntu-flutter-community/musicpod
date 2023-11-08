import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../media_control/media_control_service.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../../data.dart';
import '../../library.dart';
import '../../player.dart';

class PlayerModel extends SafeChangeNotifier {
  PlayerModel({
    required VideoController videoController,
    required MediaControlService mediaControlService,
    required LibraryService libraryService,
  })  : controller = videoController,
        _player = videoController.player,
        _mediaControlService = mediaControlService,
        _libraryService = libraryService;

  final Player _player;
  final VideoController controller;
  final MediaControlService _mediaControlService;
  final LibraryService _libraryService;
  StreamSubscription<bool>? _playerSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<bool>? _isCompletedSub;
  StreamSubscription<double>? _volumeSub;

  String? _queueName;
  String? get queueName => _queueName;
  void setQueueName(String? value) {
    if (value == null || value == _queueName) return;
    _queueName = value;
    notifyListeners();
  }

  List<Audio> _queue = [];
  List<Audio> get queue => _queue;
  set queue(List<Audio>? value) {
    if (value == null) return;
    _queue = value;
    notifyListeners();
  }

  MpvMetaData? _mpvMetaData;
  MpvMetaData? get mpvMetaData => _mpvMetaData;
  void setMpvMetaData(MpvMetaData value) {
    if (value == _mpvMetaData) return;
    _mpvMetaData = value;
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
  Future<void> _setAudio(Audio? value) async {
    if (value == null || value == _audio) return;
    _audio = value;
    _libraryService.setLastAudio(value);
    _setIsVideo();

    notifyListeners();

    if (audio != null) {
      _mediaControlService.setMetaData(audio!);
    }
  }

  void _setIsVideo() {
    _isVideo = false;
    for (var t in _videoTypes) {
      if (audio?.url?.contains(t) == true) {
        _isVideo = true;
        break;
      }
    }
  }

  bool? _isVideo;
  bool? get isVideo => _isVideo;
  void setIsVideo(bool? value) {
    if (value == _isVideo) return;
    _isVideo = value;
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
    _libraryService.setDuration(value);
    notifyListeners();
  }

  Duration? _position = Duration.zero;
  Duration? get position => _position;
  void setPosition(Duration? value) {
    _position = value;
    _libraryService.setPosition(value);
    notifyListeners();
  }

  bool _repeatSingle = false;
  bool get repeatSingle => _repeatSingle;
  void setRepeatSingle(bool value) {
    if (value == _repeatSingle) return;
    _repeatSingle = value;
    _estimateNext();
    notifyListeners();
  }

  bool _shuffle = false;
  bool get shuffle => _shuffle;
  void setShuffle(bool value) {
    if (value == _shuffle) return;
    _shuffle = value;
    if (value && queue.length > 1) {
      _randomNext();
    }
    notifyListeners();
  }

  double _volume = 100.0;
  double get volume => _volume;
  Future<void> setVolume(double value) async {
    if (value == _volume) return;
    await _player.setVolume(value);
  }

  bool _firstPlay = true;
  Future<void> play({Duration? newPosition, Audio? newAudio}) async {
    final currentIndex =
        (audio == null || queue.isEmpty || !queue.contains(audio!))
            ? 0
            : queue.indexOf(audio!);
    if (newAudio != null) {
      _setAudio(newAudio);
    }
    if (audio == null) return;

    if (!queue.contains(audio)) {
      queue.insert(currentIndex, audio!);
      if (queue.length > 1) {
        nextAudio = queue[1];
      }
    }
    final playList = Playlist([
      if (audio!.path != null)
        Media('file://${audio!.path!}')
      else if (audio!.url != null)
        Media(audio!.url!),
    ]);

    _player.open(playList);
    if (newPosition != null && _audio!.audioType != AudioType.radio) {
      _player.setVolume(0).then(
            (_) => Future.delayed(const Duration(seconds: 3)).then(
              (_) => _player
                  .seek(newPosition)
                  .then((_) => _player.setVolume(100.0)),
            ),
          );
    }
    loadColor();
    _firstPlay = false;
  }

  Future<void> playOrPause() async {
    return _firstPlay ? play(newPosition: _position) : _player.playOrPause();
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
    await _mediaControlService.init(
      onPlay: play,
      onPause: pause,
      onNext: playNext,
      onPrevious: playPrevious,
      isPlaying: isPlaying,
      onPlayPause: playOrPause,
      playerStream: _player.stream,
    );

    await _readPlayerState();

    _playerSub = _player.stream.playing.listen((p) {
      isPlaying = p;
      _mediaControlService.setPlayBackStatus(isPlaying);
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

    _volumeSub = _player.stream.volume.listen((value) {
      _volume = value;
      notifyListeners();
    });

    notifyListeners();
  }

  Future<void> playNext() async {
    safeLastPosition();
    if (!repeatSingle && nextAudio != null) {
      _setAudio(nextAudio);
      _estimateNext();
    }
    await play();
  }

  Future<void> insertIntoQueue(Audio audio) async {
    if (_queue.isNotEmpty && !_queue.contains(audio)) {
      _queue.insert(1, audio);
      nextAudio = queue[1];
      notifyListeners();
    }
  }

  void _estimateNext() {
    if (audio == null) return;

    if (queue.isNotEmpty == true && queue.contains(audio)) {
      final currentIndex = queue.indexOf(audio!);

      if (shuffle && queue.length > 1) {
        _randomNext();
      } else {
        if (currentIndex == queue.length - 1) {
          nextAudio = queue.elementAt(0);
        } else {
          nextAudio = queue.elementAt(queue.indexOf(audio!) + 1);
        }
      }
    }
  }

  void _randomNext() {
    if (audio == null) return;
    final currentIndex = queue.indexOf(audio!);
    final max = queue.length;
    final random = Random();
    var randomIndex = random.nextInt(max);
    while (randomIndex == currentIndex) {
      randomIndex = random.nextInt(max);
    }
    nextAudio = queue.elementAt(randomIndex);
  }

  Future<void> playPrevious() async {
    if (queue.isNotEmpty == true && audio != null && queue.contains(audio)) {
      final currentIndex = queue.indexOf(audio!);

      if (currentIndex == 0) {
        return;
      }

      nextAudio = queue.elementAt(currentIndex - 1);

      if (nextAudio == null) return;
      _setAudio(nextAudio);

      await play();
    }
  }

  Future<void> startPlaylist(Set<Audio> audios, String listName) async {
    queue = audios.toList();
    setQueueName(listName);
    _setAudio(audios.first);
    _position = _libraryService.getLastPosition.call(_audio?.url);
    _estimateNext();
    await play(newPosition: _position);
  }

  Color? _color;
  void resetColor() => _color = null;
  Color? get color => _color;

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

  Future<void> _readPlayerState() async {
    final playerState = await _libraryService.readPlayerState();

    if (playerState.$1 != null) {
      setPosition(playerState.$1!);
    }
    if (playerState.$2 != null) {
      setDuration(playerState.$2);
    }
    if (playerState.$3 != null) {
      _audio = playerState.$3;

      if (_audio != null) {
        _mediaControlService.setMetaData(audio!);
      }
      _setIsVideo();
    }
  }

  void safeLastPosition() {
    if (_audio?.audioType == AudioType.radio ||
        _audio?.url == null ||
        _position == null) return;
    _libraryService.addLastPosition(_audio!.url!, _position!);
  }

  @override
  Future<void> dispose() async {
    await _playerSub?.cancel();
    await _positionSub?.cancel();
    await _durationSub?.cancel();
    await _isCompletedSub?.cancel();
    await _volumeSub?.cancel();
    super.dispose();
  }
}

Set<String> _videoTypes = {
  '.3g2',
  '.3gp',
  '.aaf',
  '.asf',
  '.avchd',
  '.avi',
  '.drc',
  '.flv',
  '.m2v',
  '.m3u8',
  '.m4p',
  '.m4v',
  '.mkv',
  '.mng',
  '.mov',
  '.mp2',
  '.mp4',
  '.mpe',
  '.mpeg',
  '.mpg',
  '.mpv',
  '.mxf',
  '.nsv',
  '.ogg',
  '.ogv',
  '.qt',
  '.rm',
  '.rmvb',
  '.roq',
  '.svi',
  '.vob',
  '.webm',
  '.wmv',
  '.yuv',
};
