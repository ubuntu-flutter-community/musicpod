import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart' hide PlayerState;
import 'package:media_kit_video/media_kit_video.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:path/path.dart' as p;
import 'package:smtc_windows/smtc_windows.dart';

import '../../constants.dart';
import '../../data.dart';
import '../../library.dart';
import '../../online_album_art_utils.dart';
import '../../persistence_utils.dart';
import '../../string_x.dart';

typedef Queue = ({String name, List<Audio> audios});

class PlayerService {
  PlayerService({
    required this.controller,
    required this.libraryService,
  });

  final VideoController controller;
  final LibraryService libraryService;

  SMTCWindows? _smtc;
  _AudioHandler? _audioService;

  StreamSubscription<PressedButton>? _smtcSub;
  StreamSubscription<bool>? _isPlayingSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _bufferSub;
  StreamSubscription<bool>? _isCompletedSub;
  StreamSubscription<double>? _volumeSub;
  StreamSubscription<Tracks>? _tracksSub;
  StreamSubscription<double>? _rateSub;

  Player get _player => controller.player;

  final _queueController = StreamController<bool>.broadcast();
  Stream<bool> get queueChanged => _queueController.stream;
  Queue _queue = (name: '', audios: []);
  Queue get queue => _queue;
  void setQueue(Queue value) {
    if (value == _queue || value.audios.isEmpty) return;
    _queue = value;
    _queueController.add(true);
  }

  final _mpvMetaDataController = StreamController<bool>.broadcast();
  Stream<bool> get mpvMetaDataChanged => _mpvMetaDataController.stream;
  MpvMetaData? _mpvMetaData;
  MpvMetaData? get mpvMetaData => _mpvMetaData;
  void setMpvMetaData(MpvMetaData value) {
    if (_mpvMetaData != null && value.icyTitle == _mpvMetaData?.icyTitle) {
      return;
    }
    _mpvMetaData = value;

    var validHistoryElement = _mpvMetaData?.icyTitle.isNotEmpty == true;

    if (validHistoryElement &&
        _mpvMetaData?.icyDescription.isNotEmpty == true &&
        (_mpvMetaData!.icyTitle.contains(_mpvMetaData!.icyDescription) ||
            _mpvMetaData!.icyTitle.contains(
              _mpvMetaData!.icyDescription
                  .replaceAll(RegExp(r'[^a-zA-Z0-9]'), ''),
            ))) {
      validHistoryElement = false;
    }
    if (validHistoryElement) {
      _addRadioHistoryElement(
        icyTitle: mpvMetaData!.icyTitle.everyWordCapitalized,
        mpvMetaData: mpvMetaData!.copyWith(
          icyName: audio?.title?.trim() ?? _mpvMetaData?.icyName ?? '',
        ),
      );
    }
    _mpvMetaDataController.add(true);
  }

  final _audioController = StreamController<bool>.broadcast();
  Stream<bool> get audioChanged => _audioController.stream;
  Audio? _audio;
  Audio? get audio => _audio;
  void _setAudio(Audio value) async {
    if (value == _audio) return;
    _audio = value;
    _audioController.add(true);
  }

  final _isVideoController = StreamController<bool>.broadcast();
  Stream<bool> get isVideoChanged => _isVideoController.stream;

  bool? _isVideo;
  bool? get isVideo => _isVideo;
  void _setIsVideo(bool? value) {
    _isVideo = value;
    _isVideoController.add(true);
  }

  final _nextAudioController = StreamController<bool>.broadcast();
  Stream<bool> get nextAudioChanged => _nextAudioController.stream;
  Audio? _nextAudio;
  Audio? get nextAudio => _nextAudio;
  set nextAudio(Audio? value) {
    if (value == null || value == _nextAudio) return;
    _nextAudio = value;
    _nextAudioController.add(true);
  }

  final _isPlayingController = StreamController<bool>.broadcast();
  Stream<bool> get isPlayingChanged => _isPlayingController.stream;
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;
  void setIsPlaying(bool value) {
    if (value == _isPlaying) return;
    _isPlaying = value;
    _isPlayingController.add(true);
    _setMediaControlsIsPlaying(value);
  }

  final _durationController = StreamController<bool>.broadcast();
  Stream<bool> get durationChanged => _durationController.stream;
  Duration? _duration;
  Duration? get duration => _duration;
  void setDuration(Duration? value) {
    if (value?.inSeconds == _duration?.inSeconds) return;
    _duration = value;
    _durationController.add(true);
    _setMediaControlDuration(value);
  }

  final _positionController = StreamController<bool>.broadcast();
  Stream<bool> get positionChanged => _positionController.stream;
  Duration? _position = Duration.zero;
  Duration? get position => _position;
  void setPosition(Duration? value) {
    if (position?.inSeconds == value?.inSeconds) return;
    _position = value;
    _positionController.add(true);
    _setMediaControlPosition(value);
  }

  final _bufferController = StreamController<bool>.broadcast();
  Stream<bool> get bufferChanged => _bufferController.stream;
  Duration? _buffer = Duration.zero;
  Duration? get buffer => _buffer;
  void setBuffer(Duration? value) {
    if (buffer?.inSeconds == value?.inSeconds) return;
    _buffer = value;
    _bufferController.add(true);
  }

  final _repeatSingleController = StreamController<bool>.broadcast();
  Stream<bool> get repeatSingleChanged => _repeatSingleController.stream;
  bool _repeatSingle = false;
  bool get repeatSingle => _repeatSingle;
  void setRepeatSingle(bool value) {
    if (value == _repeatSingle) return;
    _repeatSingle = value;
    _estimateNext();
    _repeatSingleController.add(true);
  }

  final _shuffleController = StreamController<bool>.broadcast();
  Stream<bool> get shuffleChanged => _shuffleController.stream;
  bool _shuffle = false;
  bool get shuffle => _shuffle;
  void setShuffle(bool value) {
    if (value == _shuffle) return;
    _shuffle = value;
    if (value && queue.audios.length > 1) {
      _randomNext();
    }
    _shuffleController.add(true);
  }

  final _volumeController = StreamController<bool>.broadcast();
  Stream<bool> get volumeChanged => _volumeController.stream;
  double? _volume;
  double? get volume => _volume;
  Future<void> setVolume(double value) async {
    if (value == _volume) return;
    await _player.setVolume(value);
  }

  final _rateController = StreamController<bool>.broadcast();
  Stream<bool> get rateChanged => _rateController.stream;
  double _rate = 1.0;
  double get rate => _rate;
  Future<void> setRate(double value) async {
    if (value == _rate) return;
    await _player.setRate(value);
  }

  /// To not mess up with the queue, this method is private
  /// Use [startPlaylist] instead
  bool _firstPlay = true;
  Future<void> _play({Duration? newPosition, Audio? newAudio}) async {
    try {
      if (newAudio != null) {
        _setAudio(newAudio);
      }
      if (audio == null) return;

      Media? media = audio!.path != null
          ? Media('file://${audio!.path!}')
          : (audio!.url != null)
              ? Media(audio!.url!)
              : null;
      if (media == null) return;
      _player.open(media).then((_) {
        _player.state.tracks;
      });
      if (newPosition != null && _audio!.audioType != AudioType.radio) {
        final tempVol = _volume;
        _player.setVolume(0).then(
              (_) => Future.delayed(const Duration(seconds: 3)).then(
                (_) => _player
                    .seek(newPosition)
                    .then((_) => _player.setVolume(tempVol ?? 100.0)),
              ),
            );
      }
      _setMediaControlsMetaData(audio: audio!);
      _loadColor();
      _firstPlay = false;
    } on Exception catch (_) {
      // TODO: instead of disallowing certain file types
      // process via error stream if something went wrong
    }
  }

  Future<void> playOrPause() async {
    return _firstPlay ? _play(newPosition: _position) : _player.playOrPause();
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
    await playOrPause();
  }

  Future<void> init() async {
    await _initMediaControl();

    _isPlayingSub = _player.stream.playing.listen((value) {
      setIsPlaying(value);
    });

    _durationSub = _player.stream.duration.listen((newDuration) {
      if (newDuration.inSeconds != 0) {
        setDuration(newDuration);
      }
    });

    _positionSub = _player.stream.position.listen((newPosition) {
      setPosition(newPosition);
    });

    _bufferSub = _player.stream.buffer.listen((event) {
      setBuffer(event);
    });

    _isCompletedSub = _player.stream.completed.listen((value) async {
      if (value) {
        if (_queue.audios.length > 1) {
          await playNext();
        }
      } else {
        await safeLastPosition();
      }
    });

    await (_player.platform as NativePlayer).observeProperty(
      'metadata',
      (data) async {
        if (audio?.audioType != AudioType.radio ||
            !data.contains('icy-title')) {
          return;
        }
        final mpvMetaData = MpvMetaData.fromJson(data);
        setMpvMetaData(mpvMetaData);
        final songInfo = mpvMetaData.icyTitle.splitByDash;
        fetchAlbumArt(mpvMetaData.icyTitle).then(
          (albumArt) {
            _setMediaControlsMetaData(
              audio: (_audio ?? const Audio()).copyWith(
                imageUrl: albumArt,
                title: songInfo.songName,
                artist: songInfo.artist,
              ),
            );
            _loadColor(artUrl: albumArt);
          },
        );
      },
    );

    _volumeSub = _player.stream.volume.listen((value) {
      _volume = value;
      _volumeController.add(true);
    });

    _rateSub = _player.stream.rate.listen((value) {
      _rate = value;
      _rateController.add(true);
    });

    _tracksSub = _player.stream.tracks.listen((tracks) {
      _setIsVideo(false);
      for (var track in tracks.video) {
        if (track.fps != null && track.fps! > 1) {
          _setIsVideo(true);
          break;
        }
      }
    });

    await _setPlayerState();
  }

  Future<void> playNext() async {
    await safeLastPosition();
    if (!repeatSingle && nextAudio != null) {
      _setAudio(nextAudio!);
      _estimateNext();
    }
    await _play();
  }

  void insertIntoQueue(Audio newAudio) {
    if (_queue.audios.isNotEmpty &&
        !_queue.audios.contains(newAudio) &&
        _audio != null) {
      final currentIndex = queue.audios.indexOf(_audio!);
      _queue.audios.insert(currentIndex + 1, newAudio);
      nextAudio = newAudio;
    }
  }

  void moveAudioInQueue(int oldIndex, int newIndex) {
    if (_queue.audios.isNotEmpty && newIndex < _queue.audios.length) {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }

      final audio = _queue.audios.removeAt(oldIndex);
      _queue.audios.insert(newIndex, audio);

      _estimateNext();

      _queueController.add(true);
    }
  }

  void remove(Audio deleteMe) {
    _queue.audios.remove(deleteMe);
    _estimateNext();
    _queueController.add(true);
  }

  void _estimateNext() {
    if (audio == null) return;

    if (queue.audios.isNotEmpty && queue.audios.contains(audio)) {
      final currentIndex = queue.audios.indexOf(audio!);

      if (shuffle && queue.audios.length > 1) {
        _randomNext();
      } else {
        if (currentIndex == queue.audios.length - 1) {
          nextAudio = queue.audios.elementAt(0);
        } else {
          nextAudio = queue.audios.elementAt(queue.audios.indexOf(audio!) + 1);
        }
      }
    }
  }

  void _randomNext() {
    if (audio == null) return;
    final currentIndex = queue.audios.indexOf(audio!);
    final max = queue.audios.length;
    final random = Random();
    var randomIndex = random.nextInt(max);
    while (randomIndex == currentIndex) {
      randomIndex = random.nextInt(max);
    }
    nextAudio = queue.audios.elementAt(randomIndex);
  }

  Future<void> playPrevious() async {
    if (queue.audios.isNotEmpty == true &&
        audio != null &&
        queue.audios.contains(audio)) {
      if (position != null && position!.inSeconds > 10) {
        setPosition(Duration.zero);
        await seek();
      } else {
        final currentIndex = queue.audios.indexOf(audio!);
        if (currentIndex == 0) {
          return;
        }
        final mightBePrevious = queue.audios.elementAtOrNull(currentIndex - 1);
        if (mightBePrevious == null) return;
        _setAudio(mightBePrevious);
        _estimateNext();
        await _play();
      }
    }
  }

  Future<void> startPlaylist({
    required Set<Audio> audios,
    required String listName,
    int? index,
  }) async {
    if (listName == _queue.name &&
        index != null &&
        audios.elementAtOrNull(index) != null) {
      _setAudio(audios.elementAtOrNull(index)!);
    } else {
      setQueue((name: listName, audios: audios.toList()));
      _setAudio(
        (index != null && audios.elementAtOrNull(index) != null)
            ? audios.elementAtOrNull(index)!
            : audios.first,
      );
    }

    _position = getLastPosition(_audio?.url);
    _estimateNext();
    await _play(newPosition: _position);
  }

  Color? _color;
  Color? get color => _color;

  Future<void> _loadColor({String? artUrl}) async {
    if (_audio?.pictureData == null &&
        audio?.imageUrl == null &&
        audio?.albumArtUrl == null &&
        artUrl == null) {
      _color = null;
      return;
    }

    ImageProvider? image;
    if (_audio?.pictureData != null) {
      image = MemoryImage(
        _audio!.pictureData!,
      );
    } else {
      image = NetworkImage(
        artUrl ?? _audio!.imageUrl ?? _audio!.albumArtUrl!,
      );
    }
    final generator = await PaletteGenerator.fromImageProvider(image);
    _color = generator.dominantColor?.color;
  }

  Future<void> _setPlayerState() async {
    final playerState = await _readPlayerState();

    _lastPositions = (await getSettings(kLastPositionsFileName)).map(
      (key, value) => MapEntry(key, value.parsedDuration ?? Duration.zero),
    );

    if (playerState?.audio != null) {
      _setAudio(playerState!.audio!);

      if (playerState.duration != null) {
        setDuration(playerState.duration!.parsedDuration);
      }
      if (playerState.position != null) {
        setPosition(playerState.position!.parsedDuration);
      }

      if (playerState.queue?.isNotEmpty == true &&
          playerState.queueName?.isNotEmpty == true) {
        setQueue((name: playerState.queueName!, audios: playerState.queue!));
      }

      if (playerState.volume != null) {
        setVolume(double.tryParse(playerState.volume!) ?? 100.0);
      }

      _estimateNext();

      await _setMediaControlsMetaData(audio: playerState.audio!);
    }
  }

  //
  // last positions
  //
  Map<String, Duration> _lastPositions = {};
  Map<String, Duration> get lastPositions => _lastPositions;
  final _lastPositionsController = StreamController<bool>.broadcast();
  Stream<bool> get lastPositionsChanged => _lastPositionsController.stream;
  Future<void> addLastPosition(String url, Duration lastPosition) async {
    await writeSetting(url, lastPosition.toString(), kLastPositionsFileName);
    if (_lastPositions.containsKey(url) == true) {
      _lastPositions.update(url, (value) => lastPosition);
    } else {
      _lastPositions.putIfAbsent(url, () => lastPosition);
    }
    _lastPositionsController.add(true);
  }

  Duration? getLastPosition(String? url) => _lastPositions[url];

  Future<void> safeLastPosition() async {
    if (_audio?.audioType == AudioType.radio ||
        _audio?.url == null ||
        _position == null) return;
    await addLastPosition(_audio!.url!, _position!);
  }

  Future<void> _initMediaControl() async {
    if (Platform.isWindows) {
      _initSmtc();
    } else if (Platform.isLinux || Platform.isAndroid || Platform.isMacOS) {
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
              _isPlaying ? PlaybackStatus.Playing : PlaybackStatus.Paused,
            ),
          );
          break;
        case PressedButton.pause:
          playOrPause().then(
            (_) => _smtc?.setPlaybackStatus(
              _isPlaying ? PlaybackStatus.Playing : PlaybackStatus.Paused,
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

  Future<void> _initAudioService() async {
    _audioService = await AudioService.init(
      config: const AudioServiceConfig(
        androidNotificationOngoing: true,
      ),
      builder: () {
        return _AudioHandler(
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
  }

  void _setMediaControlPosition(Duration? position) {
    if (_audioService != null) {
      _audioService!.playbackState.add(
        _audioService!.playbackState.value.copyWith(
          updatePosition: position ?? Duration.zero,
        ),
      );
    } else if (_smtc != null && position != null) {
      _smtc?.setPosition(position);
    }
  }

  void _setMediaControlDuration(Duration? duration) {
    if (_audioService == null || _audioService!.mediaItem.value == null) return;
    _audioService!.mediaItem
        .add(_audioService!.mediaItem.value!.copyWith(duration: duration));
  }

  Future<void> _setMediaControlsMetaData({required Audio audio}) async {
    final artUri = await _createMediaControlsArtUri(audio: audio);
    _setSmtcMetaData(audio: audio, artUri: artUri);
    _setAudioServiceMetaData(audio: audio, artUri: artUri);
  }

  Future<Uri?> _createMediaControlsArtUri({Audio? audio}) async {
    if (audio?.imageUrl != null || audio?.albumArtUrl != null) {
      return Uri.tryParse(
        audio?.imageUrl ?? audio!.albumArtUrl!,
      );
    } else if (audio?.pictureData != null) {
      Uint8List imageInUnit8List = audio!.pictureData!;
      final workingDir = await getWorkingDir();

      final imagesDir = p.join(workingDir, 'images');

      if (Directory(imagesDir).existsSync()) {
        Directory(imagesDir).deleteSync(recursive: true);
      }
      Directory(imagesDir).createSync();
      final now =
          DateTime.now().toUtc().toString().replaceAll(RegExp(r'[^0-9]'), '');
      final file = File(p.join(imagesDir, '$now.png'));
      final newFile = await file.writeAsBytes(imageInUnit8List);

      return Uri.file(newFile.path, windows: Platform.isWindows);
    } else {
      return null;
    }
  }

  Future<void> _setMediaControlsIsPlaying(bool playing) async {
    if (_audioService != null) {
      _audioService!.playbackState.add(
        _audioService!.playbackState.value.copyWith(
          playing: playing,
          controls: _determineMediaControls(playing),
        ),
      );
    } else if (_smtc != null) {
      _smtc!.setPlaybackStatus(
        playing ? PlaybackStatus.Playing : PlaybackStatus.Paused,
      );
    }
  }

  List<MediaControl> _determineMediaControls(bool playing) {
    final showSkipControls =
        _queue.audios.isNotEmpty && _audio?.audioType != AudioType.radio;

    final showSeekControls = _audio?.audioType == AudioType.podcast &&
        (Platform.isMacOS || Platform.isAndroid);

    return [
      if (showSeekControls)
        MediaControl.rewind
      else if (showSkipControls)
        MediaControl.skipToPrevious,
      playing ? MediaControl.pause : MediaControl.play,
      if (showSeekControls)
        MediaControl.fastForward
      else if (showSkipControls)
        MediaControl.skipToNext,
    ];
  }

  void _setAudioServiceMetaData({required Audio audio, required Uri? artUri}) {
    if (_audioService == null) return;
    _audioService!.mediaItem.add(
      MediaItem(
        id: audio.toString(),
        title: audio.title ?? kAppTitle,
        artist: audio.artist ?? '',
        artUri: artUri,
        duration: audio.durationMs == null
            ? null
            : Duration(milliseconds: audio.durationMs!.toInt()),
      ),
    );
  }

  void _setSmtcMetaData({required Audio audio, required Uri? artUri}) {
    if (_smtc == null) return;
    _smtc!.updateMetadata(
      MusicMetadata(
        title: audio.title ?? kAppTitle,
        album: audio.album,
        albumArtist: audio.artist,
        artist: audio.artist ?? '',
        thumbnail: audio.audioType == AudioType.local
            ? kFallbackThumbnail
            : artUri == null
                ? null
                : '$artUri',
      ),
    );
  }

  final Map<String, MpvMetaData> _radioHistory = {};
  Map<String, MpvMetaData> get radioHistory => _radioHistory;
  final _radioHistoryController = StreamController<bool>.broadcast();
  Stream<bool> get radioHistoryChanged => _radioHistoryController.stream;
  void _addRadioHistoryElement({
    required String icyTitle,
    required MpvMetaData mpvMetaData,
  }) {
    _radioHistory.putIfAbsent(
      icyTitle,
      () => mpvMetaData,
    );
    _radioHistoryController.add(true);
  }

  Future<void> dispose() async {
    await _writePlayerState();
    await _smtcSub?.cancel();
    await _smtc?.disableSmtc();
    await _smtc?.dispose();
    await _queueController.close();
    await _mpvMetaDataController.close();
    await _audioController.close();
    await _nextAudioController.close();
    await _volumeController.close();
    await _shuffleController.close();
    await _durationController.close();
    await _isVideoController.close();
    await _positionController.close();
    await _isPlayingController.close();
    await _repeatSingleController.close();
    await _isPlayingSub?.cancel();
    await _positionSub?.cancel();
    await _durationSub?.cancel();
    await _isCompletedSub?.cancel();
    await _volumeSub?.cancel();
    await _tracksSub?.cancel();
    await _rateSub?.cancel();
    await _rateController.close();
    await _radioHistoryController.close();
    await _bufferSub?.cancel();

    await _player.dispose();
  }

  Future<void> _writePlayerState() async {
    final playerState = PlayerState(
      audio: _audio,
      duration: _duration?.toString(),
      position: _position?.toString(),
      queue:
          _queue.audios.length <= 100 ? _queue.audios.take(100).toList() : null,
      queueName: _queue.audios.length <= 100 ? _queue.name : null,
      volume: _volume.toString(),
    );

    await writeJsonToFile(playerState.toMap(), kPlayerStateFileName);
  }

  Future<PlayerState?> _readPlayerState() async {
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

class _AudioHandler extends BaseAudioHandler with SeekHandler {
  final Future<void> Function() onPlay;
  final Future<void> Function() onPause;
  final Future<void> Function() onNext;
  final Future<void> Function() onPrevious;
  final Future<void> Function(Duration position) onSeek;

  @override
  _AudioHandler({
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
