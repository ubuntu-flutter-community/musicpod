import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:media_kit/media_kit.dart' hide PlayerState;
import 'package:media_kit_video/media_kit_video.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:path/path.dart' as p;
import 'package:smtc_windows/smtc_windows.dart';

import '../common/data/audio.dart';
import '../common/data/mpv_meta_data.dart';
import '../common/data/player_state.dart';
import '../constants.dart';
import '../extensions/string_x.dart';
import '../local_audio/cover_store.dart';
import '../online_album_art_utils.dart';
import '../persistence_utils.dart';

typedef Queue = ({String name, List<Audio> audios});

class PlayerService {
  PlayerService({
    required VideoController controller,
  }) : _controller = controller;

  final VideoController _controller;
  VideoController get controller => _controller;

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

  Player get _player => _controller.player;

  final _propertiesChangedController = StreamController<bool>.broadcast();
  Stream<bool> get propertiesChanged => _propertiesChangedController.stream;

  Queue _queue = (name: '', audios: []);
  Queue get queue => _queue;
  void setQueue(Queue value) {
    if (value == _queue || value.audios.isEmpty) return;
    _queue = value;
    _propertiesChangedController.add(true);
  }

  MpvMetaData? _mpvMetaData;
  MpvMetaData? get mpvMetaData => _mpvMetaData;
  void setMpvMetaData(MpvMetaData? value) {
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
    _propertiesChangedController.add(true);
  }

  Audio? _audio;
  Audio? get audio => _audio;
  void _setAudio(Audio value) async {
    if (value == _audio) return;
    if (value.audioType != _audio?.audioType) {
      _shuffle = false;
      setRate(1);
    }
    _audio = value;
    _propertiesChangedController.add(true);
    setMpvMetaData(null);
  }

  bool? _isVideo;
  bool? get isVideo => _isVideo;
  void _setIsVideo(bool? value) {
    _isVideo = value;
    _propertiesChangedController.add(true);
  }

  Audio? _nextAudio;
  Audio? get nextAudio => _nextAudio;
  set nextAudio(Audio? value) {
    if (value == null || value == _nextAudio) return;
    _nextAudio = value;
    _propertiesChangedController.add(true);
  }

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;
  void setIsPlaying(bool value) {
    if (value == _isPlaying) return;
    _isPlaying = value;
    _propertiesChangedController.add(true);
    _setMediaControlsIsPlaying(value);
  }

  Duration? _duration;
  Duration? get duration => _duration;
  void setDuration(Duration? value) {
    if (value?.inSeconds == _duration?.inSeconds) return;
    _duration = value;
    _propertiesChangedController.add(true);
    _setMediaControlDuration(value);
  }

  int _playerStateTicker = 0;
  Duration? _position = Duration.zero;
  Duration? get position => _position;
  void setPosition(Duration? value) {
    if (position?.inSeconds == value?.inSeconds) return;
    _position = value;
    _playerStateTicker = value?.inSeconds ?? 0;
    _propertiesChangedController.add(true);
    _setMediaControlPosition(value);
    if (_playerStateTicker >= 5) {
      _playerStateTicker = 0;
      safeLastPosition().then((_) => _writePlayerState());
    }
  }

  Duration? _buffer = Duration.zero;
  Duration? get buffer => _buffer;
  void setBuffer(Duration? value) {
    if (buffer?.inSeconds == value?.inSeconds) return;
    _buffer = value;
    _propertiesChangedController.add(true);
  }

  bool _repeatSingle = false;
  bool get repeatSingle => _repeatSingle;
  void setRepeatSingle(bool value) {
    if (value == _repeatSingle) return;
    _repeatSingle = value;
    _estimateNext();
    _propertiesChangedController.add(true);
  }

  bool _shuffle = false;
  bool get shuffle => _shuffle;
  void setShuffle(bool value) {
    if (value == _shuffle) return;
    _shuffle = value;
    if (value && queue.audios.length > 1) {
      _randomNext();
    }
    _propertiesChangedController.add(true);
  }

  double? _volume;
  double? get volume => _volume;
  Future<void> setVolume(double value) async {
    if (value == _volume) return;
    await _player.setVolume(value);
  }

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
      _loadColorAndSetRemoteUrl();
      _firstPlay = false;
    } on Exception catch (_) {}
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

    _isPlayingSub ??= _player.stream.playing.listen((value) {
      setIsPlaying(value);
    });

    _durationSub ??= _player.stream.duration.listen((newDuration) {
      if (newDuration.inSeconds != 0) {
        setDuration(newDuration);
      }
    });

    _positionSub ??= _player.stream.position.listen((newPosition) {
      setPosition(newPosition);
    });

    _bufferSub ??= _player.stream.buffer.listen((event) {
      setBuffer(event);
    });

    _isCompletedSub ??= _player.stream.completed.listen((value) async {
      if (value) {
        await playNext();
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

        if (mpvMetaData.icyTitle == _mpvMetaData?.icyTitle) return;
        setMpvMetaData(
          mpvMetaData.copyWith(
            icyTitle: HtmlParser(mpvMetaData.icyTitle).parseFragment().text,
          ),
        );

        final songInfo = mpvMetaData.icyTitle.splitByDash;
        fetchAlbumArt(mpvMetaData.icyTitle).then(
          (albumArt) async {
            await _setMediaControlsMetaData(
              audio: (_audio ?? const Audio()).copyWith(
                imageUrl: albumArt,
                title: songInfo.songName,
                artist: songInfo.artist,
              ),
            );
            await _loadColorAndSetRemoteUrl(artUrl: albumArt);
          },
        );
      },
    );

    _volumeSub ??= _player.stream.volume.listen((value) {
      _volume = value;
      _propertiesChangedController.add(true);
    });

    _rateSub ??= _player.stream.rate.listen((value) {
      _rate = value;
      _propertiesChangedController.add(true);
    });

    _tracksSub ??= _player.stream.tracks.listen((tracks) {
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

      _propertiesChangedController.add(true);
    }
  }

  void remove(Audio deleteMe) {
    _queue.audios.remove(deleteMe);
    _estimateNext();
    _propertiesChangedController.add(true);
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
    required List<Audio> audios,
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

  String? _remoteImageUrl;
  String? get remoteImageUrl => _remoteImageUrl;
  void _setRemoteImageUrl(String? url) {
    _remoteImageUrl = url;
    _propertiesChangedController.add(true);
  }

  Future<void> _loadColorAndSetRemoteUrl({String? artUrl}) async {
    final pic = CoverStore().get(_audio?.albumId);
    if (pic == null &&
        audio?.imageUrl == null &&
        audio?.albumArtUrl == null &&
        artUrl == null) {
      _color = null;
      _setRemoteImageUrl(null);

      return;
    }

    ImageProvider? image;
    if (pic != null) {
      _setRemoteImageUrl(null);
      image = MemoryImage(pic);
    } else {
      final url = artUrl ?? _audio!.imageUrl ?? _audio!.albumArtUrl!;
      _setRemoteImageUrl(url);
      image = NetworkImage(
        url,
      );
    }
    final generator = await PaletteGenerator.fromImageProvider(image);
    _color = generator.dominantColor?.color;
  }

  Future<void> _setPlayerState() async {
    final playerState = await _readPlayerState();

    _lastPositions = (await getCustomSettings(kLastPositionsFileName)).map(
      (key, value) => MapEntry(key, value.parsedDuration ?? Duration.zero),
    );

    if (playerState?.audio != null) {
      _setAudio(playerState!.audio!);
      _setRemoteImageUrl(playerState.audio!.imageUrl);

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

  // TODO: migrate to shared preferences but add a migration routine from the old file so users do not
  // lose their progress
  Map<String, Duration> _lastPositions = {};
  Map<String, Duration> get lastPositions => _lastPositions;
  Future<void> addLastPosition(String key, Duration lastPosition) async {
    await writeCustomSetting(
      key,
      lastPosition.toString(),
      kLastPositionsFileName,
    );
    if (_lastPositions.containsKey(key)) {
      _lastPositions.update(key, (value) => lastPosition);
    } else {
      _lastPositions.putIfAbsent(key, () => lastPosition);
    }
    _propertiesChangedController.add(true);
  }

  Future<void> removeLastPosition(String key) async {
    await removeCustomSetting(key, kLastPositionsFileName);
    _lastPositions.remove(key);
    _propertiesChangedController.add(true);
  }

  Future<void> removeLastPositions(List<Audio> audios) async {
    for (var e in audios) {
      if (e.url != null) {
        await removeCustomSetting(e.url!, kLastPositionsFileName);
        _lastPositions.remove(e.url!);
        _propertiesChangedController.add(true);
      }
    }
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
        case PressedButton.pause:
          playOrPause().then(
            (_) => _smtc?.setPlaybackStatus(
              _isPlaying ? PlaybackStatus.Playing : PlaybackStatus.Paused,
            ),
          );
        case PressedButton.next:
          playNext();
        case PressedButton.previous:
          playPrevious();
        default:
          break;
      }
    });
  }

  Future<void> _initAudioService() async {
    _audioService = await AudioService.init(
      config: const AudioServiceConfig(
        androidNotificationOngoing: true,
        androidNotificationChannelName: kAppName,
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
    } else if (audio?.hasPathAndId == true && File(audio!.path!).existsSync()) {
      final maybeData = CoverStore().get(audio.albumId);
      if (maybeData != null) {
        File newFile = await _safeTempCover(maybeData);

        return Uri.file(newFile.path, windows: Platform.isWindows);
      } else {
        final newData = await getCover(
          albumId: audio.albumId!,
          path: audio.path!,
        );
        if (newData != null) {
          File newFile = await _safeTempCover(newData);

          return Uri.file(newFile.path, windows: Platform.isWindows);
        }
      }
    }

    return null;
  }

  Future<File> _safeTempCover(Uint8List maybeData) async {
    final workingDir = await getWorkingDir();

    final imagesDir = p.join(workingDir, 'images');

    if (Directory(imagesDir).existsSync()) {
      Directory(imagesDir).deleteSync(recursive: true);
    }
    Directory(imagesDir).createSync();
    final now =
        DateTime.now().toUtc().toString().replaceAll(RegExp(r'[^0-9]'), '');
    final file = File(p.join(imagesDir, '$now.png'));
    final newFile = await file.writeAsBytes(maybeData);
    return newFile;
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
  void _addRadioHistoryElement({
    required String icyTitle,
    required MpvMetaData mpvMetaData,
  }) {
    _radioHistory.putIfAbsent(
      icyTitle,
      () => mpvMetaData,
    );
  }

  Timer? _timer;
  void setTimer(Duration duration) {
    _timer = Timer(duration, () => pause());
  }

  Future<void> dispose() async {
    await _propertiesChangedController.close();
    await _smtcSub?.cancel();
    await _smtc?.disableSmtc();
    await _smtc?.dispose();
    await _isPlayingSub?.cancel();
    await _positionSub?.cancel();
    await _durationSub?.cancel();
    await _isCompletedSub?.cancel();
    await _volumeSub?.cancel();
    await _tracksSub?.cancel();
    await _rateSub?.cancel();
    await _bufferSub?.cancel();
    _timer?.cancel();
    await _player.dispose();
  }

  Future<void> _writePlayerState() async {
    final playerState = PlayerState(
      audio: _audio?.copyWith(imageUrl: _remoteImageUrl),
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
