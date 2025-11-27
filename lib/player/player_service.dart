import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart' hide PlayerState;
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path/path.dart' as p;
import 'package:yaru/yaru.dart';

import '../app_config.dart';
import '../common/data/audio.dart';
import '../common/data/audio_type.dart';
import '../common/data/player_state.dart';
import '../common/file_names.dart';
import '../common/logging.dart';
import '../expose/expose_service.dart';
import '../extensions/media_file_x.dart';
import '../extensions/string_x.dart';
import '../extensions/taget_platform_x.dart';
import '../local_audio/local_cover_service.dart';
import '../persistence_utils.dart';

typedef Queue = ({String name, List<Audio> audios});

class PlayerService extends BaseAudioHandler with SeekHandler {
  PlayerService({
    required VideoController controller,
    required ExposeService exposeService,
    required LocalCoverService localCoverService,
  }) : _controller = controller,
       _exposeService = exposeService,
       _localCoverService = localCoverService {
    registerMediaControlsCallBacks();
  }

  // External dependencies
  final ExposeService _exposeService;
  final LocalCoverService _localCoverService;
  final VideoController _controller;

  // MediaKit getters
  VideoController get controller => _controller;
  Player get player => _controller.player;

  // Helper stream subscriptions
  StreamSubscription<bool>? _isPlayingSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _bufferSub;
  StreamSubscription<bool>? _isCompletedSub;
  StreamSubscription<double>? _volumeSub;
  StreamSubscription<Tracks>? _tracksSub;
  StreamSubscription<double>? _rateSub;

  // Used to notify whoever is listening
  final _propertiesChangedController = StreamController<bool>.broadcast();
  Stream<bool> get propertiesChanged => _propertiesChangedController.stream;

  /// All stream subscriptions and the initial [PlayerState] are set here
  Future<void> init() async {
    _isPlayingSub ??= player.stream.playing.listen((value) {
      setIsPlaying(value);
    });

    _durationSub ??= player.stream.duration.listen((newDuration) {
      if (newDuration.inSeconds != 0) {
        setDuration(newDuration);
      }
    });

    _positionSub ??= player.stream.position.listen((newPosition) {
      _setPosition(newPosition);
    });

    _bufferSub ??= player.stream.buffer.listen((event) {
      setBuffer(event);
    });

    _isCompletedSub ??= player.stream.completed.listen((value) async {
      if (value) {
        if (_repeatSingle) {
          _play(newAudio: _audio);
        } else {
          await skipToNext();
        }
      }
    });

    _volumeSub ??= player.stream.volume.listen((value) {
      _volume = value;
      _propertiesChangedController.add(true);
    });

    _rateSub ??= player.stream.rate.listen((value) {
      _rate = value;
      _propertiesChangedController.add(true);
    });

    _tracksSub ??= player.stream.tracks.listen((tracks) {
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

  /// All subscriptions, native media trays and the pause timer need to be closed and disposed
  Future<void> dispose() async {
    await _propertiesChangedController.close();
    await _isPlayingSub?.cancel();
    await _positionSub?.cancel();
    await _durationSub?.cancel();
    await _isCompletedSub?.cancel();
    await _volumeSub?.cancel();
    await _tracksSub?.cancel();
    await _rateSub?.cancel();
    await _bufferSub?.cancel();
    _timer?.cancel();
    await player.dispose();
  }

  // Because we don't want to work with the [Media] class from media_kit
  // we create our own queue
  Queue? _oldQueue;
  Queue _queue = (name: '', audios: []);
  Queue get theQueue => _queue;
  void _setQueue(Queue value) {
    if (value.audios.isEmpty) return;
    _queue = value;
    _propertiesChangedController.add(true);
  }

  void clearQueue() {
    _queue.audios.removeWhere((e) => e != _audio);
    _nextAudio = _audio;
    _propertiesChangedController.add(true);
  }

  Audio? _audio;
  Audio? get audio => _audio;
  void _setAudio(Audio value) async {
    if (value == _audio) return;
    if (_color != null && value.audioType != AudioType.local) {
      _setColor(null);
    }
    if (value.audioType != _audio?.audioType) {
      _shuffle = false;
      _repeatSingle = false;
      setRate(1);
    }
    _audio = value;
    _propertiesChangedController.add(true);
    _setLocalColor(_audio!);
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
  void _setPosition(Duration? value) {
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
    if (value) {
      _oldQueue = (audios: List.from(_queue.audios), name: _queue.name);
      _queue.audios.shuffle();
    } else if (_oldQueue != null &&
        _oldQueue?.name != null &&
        _oldQueue!.name == _queue.name) {
      _setQueue((audios: List.from(_oldQueue!.audios), name: _oldQueue!.name));
    }
    _estimateNext();
    _propertiesChangedController.add(true);
  }

  double? _volume;
  double? get volume => _volume;
  Future<void> setVolume(double value) async {
    if (value == _volume) return;
    await player.setVolume(value);
  }

  double _rate = 1.0;
  double get rate => _rate;
  Future<void> setRate(double value) async {
    if (value == _rate) return;
    await player.setRate(value);
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

      final Media? media = audio!.path != null
          ? Media('file://${audio!.path!}')
          : (audio!.url != null)
          ? Media(audio!.url!)
          : null;
      if (media == null) return;
      player.open(media).then((_) {
        player.state.tracks;
      });
      if (newPosition != null && _audio!.audioType != AudioType.radio) {
        final tempVol = _volume;
        player
            .setVolume(0)
            .then(
              (_) => Future.delayed(const Duration(seconds: 3)).then(
                (_) => player
                    .seek(newPosition)
                    .then((_) => player.setVolume(tempVol ?? 100.0)),
              ),
            );
      }
      setRemoteImageUrl(_audio?.imageUrl ?? _audio?.albumArtUrl);

      await setMediaControlsMetaData(audio: audio!);
      await _exposeService.exposeTitleOnline(
        title: audio?.title ?? '',
        artist: audio?.artist ?? '',
        additionalInfo: audio?.album ?? '',
        imageUrl: audio?.imageUrl ?? audio?.albumArtUrl,
      );
      _firstPlay = false;
    } on Exception catch (e) {
      printMessageInDebugMode(e);
    }
  }

  @override
  Future<void> play() async {
    return _firstPlay ? _play(newPosition: _position) : player.playOrPause();
  }

  @override
  Future<void> pause() => player.pause();

  Timer? _timer;
  void setPauseTimer(Duration duration) {
    _timer = Timer(duration, () => pause());
  }

  @override
  Future<void> seek(Duration position) => player.seek(position);

  Future<void> resume() async {
    if (audio == null) return;
    await play();
  }

  @override
  Future<void> skipToNext() async {
    await safeLastPosition();
    if (nextAudio != null) {
      _setAudio(nextAudio!);
      _estimateNext();
    }
    await _play();
  }

  void insertIntoQueue(List<Audio> newAudios) {
    for (var audio in newAudios.reversed) {
      _insertAudioIntoQueue(audio);
    }
  }

  void _insertAudioIntoQueue(Audio newAudio) {
    if (_queue.audios.isNotEmpty &&
        !_queue.audios.contains(newAudio) &&
        _audio != null) {
      final currentIndex = theQueue.audios.indexOf(_audio!);
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

    if (theQueue.audios.isNotEmpty && theQueue.audios.contains(audio)) {
      final currentIndex = theQueue.audios.indexOf(audio!);

      if (currentIndex == theQueue.audios.length - 1) {
        nextAudio = theQueue.audios.elementAt(0);
      } else {
        nextAudio = theQueue.audios.elementAt(
          theQueue.audios.indexOf(audio!) + 1,
        );
      }
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (theQueue.audios.isNotEmpty == true &&
        audio != null &&
        theQueue.audios.contains(audio)) {
      if (position != null && position!.inSeconds > 10) {
        await seek(Duration.zero);
      } else {
        final currentIndex = theQueue.audios.indexOf(audio!);
        if (currentIndex == 0) {
          return;
        }
        final mightBePrevious = theQueue.audios.elementAtOrNull(
          currentIndex - 1,
        );
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
    if (audios.isEmpty) return;
    if (audios.length == _queue.audios.length &&
        listName == _queue.name &&
        index != null &&
        audios.elementAtOrNull(index) != null) {
      _setAudio(audios.elementAtOrNull(index)!);
    } else {
      setShuffle(false);
      _setQueue((name: listName, audios: audios.toList()));
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

  String? _remoteImageUrl;
  String? get remoteImageUrl => _remoteImageUrl;
  void setRemoteImageUrl(String? url) {
    if (_color != null) {
      _setColor(null);
    }
    _remoteImageUrl = url;
    _propertiesChangedController.add(true);
  }

  Future<void> setRemoteColorFromImageProvider(ImageProvider provider) async {
    try {
      final colorScheme = await ColorScheme.fromImageProvider(
        provider: provider,
      );
      _setColor(colorScheme.primary.scale(saturation: 1));
    } on Exception catch (e) {
      printMessageInDebugMode(e);
    }
  }

  Color? _color;
  Color? get color => _color;
  void _setColor(Color? value) {
    if (value == _color) return;
    _color = value;
    _propertiesChangedController.add(true);
  }

  Future<void> _setLocalColor(Audio audio) async {
    try {
      if (audio.canHaveLocalCover) {
        var maybeData = _localCoverService.get(audio.albumId);
        maybeData ??= await _localCoverService.getCover(
          albumId: audio.albumId!,
          path: audio.path!,
        );

        if (maybeData != null) {
          final colorScheme = await ColorScheme.fromImageProvider(
            provider: MemoryImage(maybeData),
          );
          _setColor(colorScheme.primary);
        }
      }
    } on Exception catch (e) {
      printMessageInDebugMode(e);
    }
  }

  Future<void> _setPlayerState() async {
    final playerState = await _readPlayerState();

    await _loadLastPositions();

    if (playerState?.audio != null) {
      _setAudio(playerState!.audio!);
      setRemoteImageUrl(playerState.audio!.imageUrl);

      if (playerState.queue?.isNotEmpty == true &&
          playerState.queueName?.isNotEmpty == true) {
        _setQueue((name: playerState.queueName!, audios: playerState.queue!));
      }

      if (playerState.duration?.parsedDuration != null) {
        setDuration(playerState.duration!.parsedDuration);
      }
      if (playerState.position?.parsedDuration != null) {
        _setPosition(playerState.position!.parsedDuration!);
        seek(playerState.position!.parsedDuration!);
      }

      if (playerState.volume != null) {
        setVolume(double.tryParse(playerState.volume!) ?? 100.0);
      }

      if (playerState.rate != null) {
        setRate(double.tryParse(playerState.rate!) ?? 1.0);
      }

      _estimateNext();

      await setMediaControlsMetaData(audio: playerState.audio!);
    }
  }

  Future<void> _loadLastPositions() async {
    _lastPositions = (await getCustomSettings(FileNames.lastPositions)).map(
      (key, value) => MapEntry(key, value.parsedDuration ?? Duration.zero),
    );
  }

  //
  // Last Positions used when the app re-opens and for podcasts
  //

  Map<String, Duration> _lastPositions = {};
  Map<String, Duration> get lastPositions => _lastPositions;
  Future<void> addLastPosition(String key, Duration lastPosition) async {
    await writeCustomSetting(
      key: key,
      value: lastPosition.toString(),
      filename: FileNames.lastPositions,
    );
    if (_lastPositions.containsKey(key)) {
      _lastPositions.update(key, (value) => lastPosition);
    } else {
      _lastPositions.putIfAbsent(key, () => lastPosition);
    }
    _propertiesChangedController.add(true);
  }

  Future<void> safeAllLastPositions(List<Audio> audios) async {
    await writeCustomSettings(
      entries: audios
          .where((e) => e.url != null && e.durationMs != null)
          .map(
            (e) => MapEntry(
              e.url!,
              Duration(milliseconds: e.durationMs!.toInt()).toString(),
            ),
          )
          .toList(),
      filename: FileNames.lastPositions,
    );
    await _loadLastPositions();

    _propertiesChangedController.add(true);
  }

  Future<void> removeLastPosition(String key) async {
    await removeCustomSetting(key: key, filename: FileNames.lastPositions);
    _lastPositions.remove(key);
    _propertiesChangedController.add(true);
  }

  Future<void> removeLastPositions(List<Audio> audios) async {
    await removeCustomSettings(
      keys: audios.where((e) => e.url != null).map((e) => e.url!).toList(),
      filename: FileNames.lastPositions,
    );

    await _loadLastPositions();

    _propertiesChangedController.add(true);
  }

  void clearAllLastPositions() {
    _lastPositions.clear();
    _propertiesChangedController.add(true);
  }

  Duration? getLastPosition(String? url) => _lastPositions[url];

  Future<void> safeLastPosition() async {
    if (_audio?.audioType == AudioType.radio ||
        _audio?.url == null ||
        _position == null) {
      return;
    }
    await addLastPosition(_audio!.url!, _position!);
  }

  //
  // Native media trays
  //

  // Just in case we need to change the third party library in the future
  // the callbacks are setup here.

  Future<void>? Function({
    required bool isPlaying,
    required AudioType? audioType,
    required bool queueNotEmpty,
  })?
  _onSetMediaControlsIsPlaying;
  Future<void>? Function({required Audio audio, required Uri? artUri})?
  _onSetMediaControlsMetaData;
  Future<void>? Function(Duration? position)? _onSetMediaControlsPosition;
  Future<void>? Function(Duration? duration)? _onSetMediaControlsDuration;

  void registerMediaControlsCallBacks() {
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

    _onSetMediaControlsIsPlaying =
        ({
          required audioType,
          required isPlaying,
          required queueNotEmpty,
        }) async {
          playbackState.add(
            playbackState.value.copyWith(
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
        };
    _onSetMediaControlsMetaData =
        ({required Uri? artUri, required Audio audio}) {
          mediaItem.add(
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
        };
    _onSetMediaControlsPosition = (position) {
      playbackState.add(
        playbackState.value.copyWith(updatePosition: position ?? Duration.zero),
      );
      return Future.value();
    };
    _onSetMediaControlsDuration = (duration) {
      if (mediaItem.value != null) {
        mediaItem.add(mediaItem.value!.copyWith(duration: duration));
      }

      return Future.value();
    };
  }

  Future<void> _setMediaControlsIsPlaying(bool playing) async =>
      await _onSetMediaControlsIsPlaying?.call(
        isPlaying: playing,
        audioType: _audio?.audioType,
        queueNotEmpty: _queue.audios.isNotEmpty,
      );

  Future<void> _setMediaControlPosition(Duration? position) async =>
      await _onSetMediaControlsPosition?.call(position);

  Future<void> _setMediaControlDuration(Duration? duration) async =>
      await _onSetMediaControlsDuration?.call(duration);

  Future<void> setMediaControlsMetaData({required Audio audio}) async {
    final artUri = await _localCoverService.createMediaControlsArtUri(
      audio: audio,
    );
    await _onSetMediaControlsMetaData?.call(audio: audio, artUri: artUri);
  }

  Future<void> _writePlayerState() async {
    final playerState = PlayerState(
      audio: _audio,
      duration: _duration?.toString(),
      position: _position?.toString(),
      queue: _queue.audios.length > 100
          ? _queue.audios.take(100).toList()
          : _queue.audios,
      queueName: _queue.name,
      volume: _volume.toString(),
      rate: _rate.toString(),
    );

    await writeJsonToFile(playerState.toMap(), FileNames.playerState);
  }

  Future<PlayerState?> _readPlayerState() async {
    try {
      final workingDir = await getWorkingDir();
      final file = File(p.join(workingDir, FileNames.playerState));

      if (file.existsSync()) {
        final jsonStr = await file.readAsString();

        return PlayerState.fromJson(jsonStr);
      } else {
        return null;
      }
    } on Exception catch (e) {
      printMessageInDebugMode(e);
      return null;
    }
  }

  void playPath([String? path]) {
    if (path == null) {
      return;
    }
    try {
      final file = File(path);

      if (file.existsSync() && file.isPlayable) {
        startPlaylist(
          listName: path,
          audios: [Audio.local(file, getImage: true)],
        );
      }
    } on Exception catch (e) {
      printMessageInDebugMode(e);
    }
  }
}
