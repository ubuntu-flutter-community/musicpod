// ignore_for_file: unnecessary_parenthesis

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:media_kit/media_kit.dart' hide PlayerState;
import 'package:media_kit_video/media_kit_video.dart';
import 'package:yaru/yaru.dart';

import '../common/data/audio.dart';
import '../common/data/audio_type.dart';
import '../common/logging.dart';
import '../common/persistence/database.dart';
import '../expose/expose_service.dart';
import '../extensions/media_file_x.dart';
import '../extensions/string_x.dart';
import '../extensions/taget_platform_x.dart';
import '../library/library_service.dart';
import '../local_audio/local_cover_service.dart';

typedef Queue = ({String name, List<Audio> audios});

@singleton
class PlayerService {
  PlayerService({
    required VideoController controller,
    required ExposeService exposeService,
    required LocalCoverService localCoverService,
    required LibraryService libraryService,
    required Database database,
  }) : _controller = controller,
       _exposeService = exposeService,
       _localCoverService = localCoverService,
       _libraryService = libraryService,
       _db = database;

  // External dependencies
  final ExposeService _exposeService;
  final LocalCoverService _localCoverService;
  final VideoController _controller;
  final LibraryService _libraryService;
  final Database _db;

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
  @PostConstruct(preResolve: true)
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
      setPosition(newPosition);
    });

    _bufferSub ??= player.stream.buffer.listen((event) {
      setBuffer(event);
    });

    _isCompletedSub ??= player.stream.completed.listen((value) async {
      if (value) {
        if (_playlistMode == PlaylistMode.single) {
          _play(newAudio: _audio);
        } else if (_playlistMode == PlaylistMode.loop ||
            _audio != null &&
                queue.audios.contains(_audio) &&
                queue.audios.indexOf(_audio!) < queue.audios.length - 1) {
          await playNext();
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

    await _loadPlayerState();

    await _loadLastPositions();
  }

  /// All subscriptions, native media trays and the pause timer need to be closed and disposed
  @disposeMethod
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

  Queue? _oldQueue;
  Queue _queue = (name: '', audios: []);
  Queue get queue => _queue;
  void setQueue(Queue value) {
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
      if (value.isRadio) {
        // NOTE: this is when the radio stream might stop/stutter/end, so it should start again immediately
        _playlistMode = PlaylistMode.loop;
      } else {
        _playlistMode = PlaylistMode.none;
      }
      setRate(1);
    }
    _audio = value;
    _setLocalColor(_audio!);
    _propertiesChangedController.add(true);
  }

  bool _isVideo = false;
  bool get isVideo => _isVideo;
  void _setIsVideo(bool value) {
    if (value == _isVideo) return;
    printMessageInDebugMode('Is video: $value');
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

  Duration? _position = Duration.zero;
  Duration? get position => _position;
  void setPosition(Duration? value) {
    if (position?.inSeconds == value?.inSeconds) return;
    _position = value;
    _propertiesChangedController.add(true);
    _setMediaControlPosition(value);

    if (isWindows && value != null && value.inSeconds % 5 == 0) {
      persistPlayerState();
    }
  }

  Duration? _buffer = Duration.zero;
  Duration? get buffer => _buffer;
  void setBuffer(Duration? value) {
    if (buffer?.inSeconds == value?.inSeconds) return;
    _buffer = value;
    _propertiesChangedController.add(true);
  }

  PlaylistMode _playlistMode = PlaylistMode.none;
  PlaylistMode get playlistMode => _playlistMode;
  void setPlaylistMode() {
    _playlistMode = switch (_playlistMode) {
      PlaylistMode.none => PlaylistMode.single,
      PlaylistMode.single => PlaylistMode.loop,
      PlaylistMode.loop => PlaylistMode.none,
    };
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
      setQueue((audios: List.from(_oldQueue!.audios), name: _oldQueue!.name));
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

      if (_audio!.url != null && _audio!.isPodcast) {
        _audio = audio?.copyWith(
          path: _libraryService.getDownload(_audio!.url!),
        );
      }

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
        artist: audio?.artist ?? audio?.copyright ?? audio?.language ?? '',
        additionalInfo: audio?.album ?? audio?.podcastTitle ?? '',
        imageUrl: audio?.imageUrl ?? audio?.albumArtUrl,
      );
      _firstPlay = false;
    } on Exception catch (e) {
      printMessageInDebugMode(e);
    }
  }

  Future<void> playOrPause() async {
    return _firstPlay ? _play(newPosition: _position) : player.playOrPause();
  }

  Future<void> pause() async {
    await player.pause();
  }

  Timer? _timer;
  void setPauseTimer(Duration duration) {
    _timer = Timer(duration, () => pause());
  }

  Future<void> seek() async {
    if (position == null) return;
    await player.seek(position!);
  }

  Future<void> resume() async {
    if (audio == null) return;
    await playOrPause();
  }

  Future<void> playNext() async {
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

      if (currentIndex == queue.audios.length - 1) {
        nextAudio = queue.audios.elementAt(0);
      } else {
        nextAudio = queue.audios.elementAt(queue.audios.indexOf(audio!) + 1);
      }
    }
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
    if (audios.isEmpty) return;
    if (audios.length == _queue.audios.length &&
        listName == _queue.name &&
        index != null &&
        audios.elementAtOrNull(index) != null) {
      _setAudio(audios.elementAtOrNull(index)!);
    } else {
      setShuffle(false);
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
        var maybeData = await _localCoverService.getCover(
          albumId: audio.albumDbId!,
          path: audio.path!,
        );
        maybeData ??= await _localCoverService.getCover(
          albumId: audio.albumDbId!,
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

  //
  // Last Positions used when the app re-opens and for podcasts
  //

  Map<String, Duration> _lastPositions = {};
  Map<String, Duration> get lastPositions => _lastPositions;
  Future<void> addLastPosition(String key, Duration lastPosition) async {
    await (_db.podcastEpisodeTable.update()
          ..where((t) => t.contentUrl.equals(key)))
        .write(
          PodcastEpisodeTableCompanion(
            positionMs: Value(lastPosition.inMilliseconds),
          ),
        );
    _lastPositions[key] = lastPosition;
    _propertiesChangedController.add(true);
  }

  Future<void> _loadLastPositions() async {
    try {
      final rows =
          await (_db.podcastEpisodeTable.select()
                ..where((t) => t.positionMs.isBiggerThanValue(0)))
              .get();
      _lastPositions = {
        for (final row in rows)
          row.contentUrl: Duration(milliseconds: row.positionMs),
      };
    } on Exception catch (_) {
      printMessageInDebugMode('Error while loading last positions.');
      _lastPositions = {};
    }
  }

  Future<void> markAudiosProgressComplete(List<Audio> audios) async {
    await _db.transaction(() async {
      for (final e in audios) {
        if (e.url != null && e.durationMs != null) {
          await (_db.podcastEpisodeTable.update()
                ..where((t) => t.contentUrl.equals(e.url!)))
              .write(
                PodcastEpisodeTableCompanion(
                  durationMs: Value(e.durationMs!.toInt()),
                  positionMs: Value(e.durationMs!.toInt()),
                ),
              );
        }
      }
    });
    await _loadLastPositions();
    _propertiesChangedController.add(true);
  }

  Future<void> removeLastPosition(String key) async {
    await (_db.podcastEpisodeTable.update()
          ..where((t) => t.contentUrl.equals(key)))
        .write(const PodcastEpisodeTableCompanion(positionMs: Value(0)));
    _lastPositions.remove(key);
    _propertiesChangedController.add(true);
  }

  Future<void> removeLastPositions(List<Audio> audios) async {
    final urls = audios.where((e) => e.url != null).map((e) => e.url!).toList();
    await (_db.podcastEpisodeTable.update()
          ..where((t) => t.contentUrl.isIn(urls)))
        .write(const PodcastEpisodeTableCompanion(positionMs: Value(0)));
    await _loadLastPositions();
    _propertiesChangedController.add(true);
  }

  Future<void> clearAllLastPositions() async {
    await (_db.podcastEpisodeTable.update()).write(
      const PodcastEpisodeTableCompanion(positionMs: Value(0)),
    );
    _lastPositions.clear();
    _propertiesChangedController.add(true);
  }

  Duration? getLastPosition(String? url) => _lastPositions[url];

  Future<void> safeLastPosition() async {
    if (_audio?.audioType != AudioType.podcast ||
        _audio?.url == null ||
        _position == null) {
      return;
    }
    printMessageInDebugMode(
      'Saving last position for ${_audio!.url}: $_position',
    );
    await addLastPosition(_audio!.url!, _position!);
  }

  //
  // Native media trays
  //

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

  void registerMediaControlsCallBacks({
    required Future<void> onIsPlaying({
      required bool isPlaying,
      required AudioType? audioType,
      required bool queueNotEmpty,
    }),
    required Future<void> onSetMetaData({
      required Audio audio,
      required Uri? artUri,
    }),
    required Future<void> onSetPosition(Duration? position),
    required Future<void> onSetDuration(Duration? duration)?,
  }) {
    _onSetMediaControlsIsPlaying = onIsPlaying;
    _onSetMediaControlsMetaData = onSetMetaData;
    _onSetMediaControlsPosition = onSetPosition;
    _onSetMediaControlsDuration = onSetDuration;
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

  Future<void> persistPlayerState() async {
    try {
      await _writePlayerState();
      await safeLastPosition();
    } on Exception catch (e) {
      printMessageInDebugMode('Error while persisting player state: $e');
    }
  }

  Future<void> _loadPlayerState() async {
    try {
      final row = await (_db.select(
        _db.playerStateTable,
      )..where((t) => t.id.equals(1))).getSingleOrNull();
      if (row == null) return;

      Audio? audio;
      if (row.audioJson != null) {
        audio = Audio.fromMap(json.decode(row.audioJson!));
      }
      if (audio == null) return;

      _setAudio(audio);
      setRemoteImageUrl(audio.imageUrl);

      if (row.duration != null) {
        setDuration(row.duration!.parsedDuration);
      }
      if (row.position != null) {
        setPosition(row.position!.parsedDuration);
      }

      if (row.volume != null) {
        setVolume(double.tryParse(row.volume!) ?? 100.0);
      }

      if (row.rate != null) {
        setRate(double.tryParse(row.rate!) ?? 1.0);
      }

      _estimateNext();

      await setMediaControlsMetaData(audio: audio);
    } on Exception catch (e) {
      printMessageInDebugMode('Error loading player state: $e');
    }
  }

  Future<void> _writePlayerState() async {
    final audioJson = _audio != null ? json.encode(_audio!.toMap()) : null;

    await _db
        .into(_db.playerStateTable)
        .insertOnConflictUpdate(
          PlayerStateTableCompanion.insert(
            id: const Value(1),
            audioJson: Value(audioJson),
            position: Value(_position?.toString()),
            duration: Value(_duration?.toString()),
            volume: Value(_volume?.toString()),
            rate: Value(_rate.toString()),
          ),
        );
    printMessageInDebugMode(
      'Player state saved, audio: ${_audio?.title}, position: $_position, volume: $_volume, rate: $_rate,',
    );
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
