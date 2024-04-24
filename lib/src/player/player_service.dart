import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart' hide PlayerState;
import 'package:media_kit_video/media_kit_video.dart';
import 'package:mpris_service/mpris_service.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:path/path.dart' as p;
import 'package:smtc_windows/smtc_windows.dart';

import '../../constants.dart';
import '../../data.dart';
import '../../library.dart';
import '../../online_album_art_utils.dart';
import '../../string_x.dart';
import '../../persistence_utils.dart';
import '../../theme.dart';

class PlayerService {
  PlayerService({
    required this.controller,
    required this.libraryService,
  });

  final VideoController controller;
  final LibraryService libraryService;

  MPRIS? _mpris;
  SMTCWindows? _smtc;
  _AudioHandler? _audioService;

  StreamSubscription<PressedButton>? _smtcSub;
  StreamSubscription<bool>? _isPlayingSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<bool>? _isCompletedSub;
  StreamSubscription<double>? _volumeSub;
  StreamSubscription<Tracks>? _tracksSub;
  StreamSubscription<double>? _rateSub;

  Player get _player => controller.player;

  final _queueController = StreamController<bool>.broadcast();
  Stream<bool> get queueChanged => _queueController.stream;
  (String, List<Audio>) _queue = ('', []);
  (String, List<Audio>) get queue => _queue;
  void setQueue((String, List<Audio>) value) {
    if (value == _queue || value.$2.isEmpty) return;
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
      libraryService.addRadioHistoryElement(
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
    if (value && queue.$2.length > 1) {
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
      (data) async {
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

    await _readPlayerState();
  }

  Future<void> playNext() async {
    safeLastPosition();
    if (!repeatSingle && nextAudio != null) {
      _setAudio(nextAudio!);
      _estimateNext();
    }
    await _play();
  }

  void insertIntoQueue(Audio newAudio) {
    if (_queue.$2.isNotEmpty &&
        !_queue.$2.contains(newAudio) &&
        _audio != null) {
      final currentIndex = queue.$2.indexOf(_audio!);
      _queue.$2.insert(currentIndex + 1, newAudio);
      nextAudio = newAudio;
    }
  }

  void moveAudioInQueue(int oldIndex, int newIndex) {
    if (_queue.$2.isNotEmpty && newIndex < _queue.$2.length) {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }

      final audio = _queue.$2.removeAt(oldIndex);
      _queue.$2.insert(newIndex, audio);

      _estimateNext();

      _queueController.add(true);
    }
  }

  void remove(Audio deleteMe) {
    _queue.$2.remove(deleteMe);
    _estimateNext();
    _queueController.add(true);
  }

  void _estimateNext() {
    if (audio == null) return;

    if (queue.$2.isNotEmpty == true && queue.$2.contains(audio)) {
      final currentIndex = queue.$2.indexOf(audio!);

      if (shuffle && queue.$2.length > 1) {
        _randomNext();
      } else {
        if (currentIndex == queue.$2.length - 1) {
          nextAudio = queue.$2.elementAt(0);
        } else {
          nextAudio = queue.$2.elementAt(queue.$2.indexOf(audio!) + 1);
        }
      }
    }
  }

  void _randomNext() {
    if (audio == null) return;
    final currentIndex = queue.$2.indexOf(audio!);
    final max = queue.$2.length;
    final random = Random();
    var randomIndex = random.nextInt(max);
    while (randomIndex == currentIndex) {
      randomIndex = random.nextInt(max);
    }
    nextAudio = queue.$2.elementAt(randomIndex);
  }

  Future<void> playPrevious() async {
    if (queue.$2.isNotEmpty == true &&
        audio != null &&
        queue.$2.contains(audio)) {
      if (position != null && position!.inSeconds > 10) {
        setPosition(Duration.zero);
        await seek();
      } else {
        final currentIndex = queue.$2.indexOf(audio!);
        if (currentIndex == 0) {
          return;
        }
        final mightBePrevious = queue.$2.elementAtOrNull(currentIndex - 1);
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
    if (listName == _queue.$1 &&
        index != null &&
        audios.elementAtOrNull(index) != null) {
      _setAudio(audios.elementAtOrNull(index)!);
    } else {
      setQueue((listName, audios.toList()));
      _setAudio(
        (index != null && audios.elementAtOrNull(index) != null)
            ? audios.elementAtOrNull(index)!
            : audios.first,
      );
    }

    _position = libraryService.getLastPosition(_audio?.url);
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
      _color = getAlphabetColor(_audio?.title ?? 'a');
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

  Future<void> _readPlayerState() async {
    final playerState = await readPlayerState();

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
        setQueue((playerState.queueName!, playerState.queue!));
      }

      if (playerState.volume != null) {
        setVolume(double.tryParse(playerState.volume!) ?? 100.0);
      }

      _estimateNext();

      await _setMediaControlsMetaData(audio: playerState.audio!);
    }
  }

  void safeLastPosition() {
    if (_audio?.audioType == AudioType.radio ||
        _audio?.url == null ||
        _position == null) return;
    libraryService.addLastPosition(_audio!.url!, _position!);
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
          _play();
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

  Future<void> _setMediaControlsMetaData({required Audio audio}) async {
    final artUri = await _createMediaControlsArtUri(audio: audio);
    _setMprisMetadata(audio: audio, artUri: artUri);
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

  void _setMprisMetadata({required Audio audio, required Uri? artUri}) {
    if (_mpris == null || (audio.url == null && audio.path == null)) {
      return;
    }
    _mpris!.metadata = MPRISMetadata(
      audio.path != null ? Uri.file(audio.path!) : Uri.parse(audio.url!),
      artUrl: artUri,
      album: audio.album,
      albumArtist: [audio.albumArtist ?? ''],
      artist: [audio.artist ?? ''],
      discNumber: audio.discNumber,
      title: audio.title ?? '',
      trackNumber: audio.trackNumber,
    );
  }

  void _setAudioServiceMetaData({required Audio audio, required Uri? artUri}) {
    if (_audioService == null) return;
    _audioService!.mediaItem.add(
      MediaItem(
        id: audio.toString(),
        duration: audio.durationMs == null
            ? null
            : Duration(milliseconds: audio.durationMs!.toInt()),
        title: audio.title ?? kAppTitle,
        artist: audio.artist ?? '',
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

    await _player.dispose();
  }

  Future<void> writePlayerState() async {
    final playerState = PlayerState(
      audio: _audio,
      duration: _duration?.toString(),
      position: _position?.toString(),
      queue: _queue.$2.take(100).toList(),
      queueName: _queue.$1,
      volume: _volume.toString(),
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

class _AudioHandler extends BaseAudioHandler with SeekHandler {
  final Future<void> Function() onPlay;
  final Future<void> Function() onPause;
  final Future<void> Function() onNext;
  final Future<void> Function() onPrevious;
  final Future<void> Function(Duration position) onSeek;

  _AudioHandler({
    required this.onPlay,
    required this.onPause,
    required this.onNext,
    required this.onPrevious,
    required this.onSeek,
  });

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
