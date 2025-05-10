import 'dart:async';
import 'dart:ui';

import 'package:media_kit_video/media_kit_video.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../common/data/audio.dart';
import '../common/data/mpv_meta_data.dart';
import '../common/view/theme.dart';
import '../radio/online_art_service.dart';
import 'player_service.dart';

class PlayerModel extends SafeChangeNotifier {
  PlayerModel({
    required PlayerService service,
    required OnlineArtService onlineArtService,
  })  : _playerService = service,
        _onlineArtService = onlineArtService {
    _propertiesChangedSub ??=
        _playerService.propertiesChanged.listen((_) => notifyListeners());
  }

  static const rateValues = [.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  final PlayerService _playerService;
  final OnlineArtService _onlineArtService;

  VideoController get controller => _playerService.controller;

  StreamSubscription<bool>? _propertiesChangedSub;

  Stream<String?> get onlineArtError => _onlineArtService.error;

  String? get queueName => _playerService.queue.name;

  List<Audio> get queue => _playerService.queue.audios;
  void clearQueue() => _playerService.clearQueue();
  MpvMetaData? get mpvMetaData => _playerService.mpvMetaData;

  Audio? get audio => _playerService.audio;

  Color? get color => _playerService.color;

  bool? get isVideo => _playerService.isVideo;

  Audio? get nextAudio => _playerService.nextAudio;

  bool get isPlaying => _playerService.isPlaying;

  Duration? get duration => _playerService.duration;

  Duration? get position => _playerService.position;
  void setPosition(Duration? value) => _playerService.setPosition(value);

  Duration? get buffer => _playerService.buffer;

  Future<void> seekInSeconds(int seconds) async {
    if (position != null && position!.inSeconds + seconds >= 0) {
      setPosition(
        Duration(
          seconds: position!.inSeconds + seconds,
        ),
      );
      await seek();
    }
  }

  bool get repeatSingle => _playerService.repeatSingle;
  void setRepeatSingle(bool value) => _playerService.setRepeatSingle(value);

  bool get shuffle => _playerService.shuffle;
  void setShuffle(bool value) => _playerService.setShuffle(value);

  double? get volume => _playerService.volume;
  Future<void> setVolume(double value) async => _playerService.setVolume(value);

  double get rate => _playerService.rate;
  Future<void> setRate(double value) async => _playerService.setRate(value);

  Future<void> playOrPause() async => _playerService.playOrPause();

  Future<void> pause() async => _playerService.pause();

  Future<void> seek() async => _playerService.seek();

  Future<void> resume() async => _playerService.resume();

  Future<void> playNext() async => _playerService.playNext();

  void insertIntoQueue(List<Audio> newAudios) async =>
      _playerService.insertIntoQueue(newAudios);

  void moveAudioInQueue(int oldIndex, int newIndex) async =>
      _playerService.moveAudioInQueue(oldIndex, newIndex);

  void remove(Audio deleteMe) => _playerService.remove(deleteMe);

  Future<void> playPrevious() async => _playerService.playPrevious();

  Future<void> startPlaylist({
    required List<Audio> audios,
    required String listName,
    int? index,
  }) async =>
      _playerService.startPlaylist(
        audios: audios,
        listName: listName,
        index: index,
      );

  String? get remoteImageUrl => _playerService.remoteImageUrl;

  bool _isUpNextExpanded = false;
  bool get isUpNextExpanded => _isUpNextExpanded;
  void setUpNextExpanded(bool value) {
    if (value == _isUpNextExpanded) return;
    _isUpNextExpanded = value;
    notifyListeners();
  }

  Map<String, Duration>? get lastPositions => _playerService.lastPositions;
  Duration? getLastPosition(String? url) => _playerService.getLastPosition(url);
  Future<void> safeLastPosition() => _playerService.safeLastPosition();

  Future<void> safeAllLastPositions(List<Audio> audios) =>
      _playerService.safeAllLastPositions(audios);

  Future<void> removeLastPosition(String key) =>
      _playerService.removeLastPosition(key);
  Future<void> removeLastPositions(List<Audio> audios) =>
      _playerService.removeLastPositions(audios);

  int getRadioHistoryLength({String? filter}) =>
      filteredRadioHistory(filter: filter).length;
  MpvMetaData? getMetadata(String? icyTitle) =>
      icyTitle == null ? null : _playerService.radioHistory[icyTitle];

  Iterable<MapEntry<String, MpvMetaData>> filteredRadioHistory({
    required String? filter,
  }) {
    return _playerService.radioHistory.entries.where(
      (e) => filter == null
          ? true
          : e.value.icyName.contains(filter) ||
              filter.contains(e.value.icyName),
    );
  }

  String getRadioHistoryList({String? filter}) {
    return filteredRadioHistory(filter: filter)
        .map((e) => '${e.value.icyTitle}\n')
        .toList()
        .reversed
        .join();
  }

  void setTimer(Duration duration) => _playerService.setPauseTimer(duration);

  double _bottomPlayerHeight = bottomPlayerDefaultHeight;
  double get bottomPlayerHeight => _bottomPlayerHeight;
  set bottomPlayerHeight(double value) {
    if (value == _bottomPlayerHeight || value < bottomPlayerDefaultHeight) {
      return;
    }
    _bottomPlayerHeight = value;
    notifyListeners();
  }

  void setDataSafeMode(bool value) => _playerService.setDataSafeMode(value);
  bool get dataSafeMode => _playerService.dataSafeMode;

  @override
  Future<void> dispose() async {
    await _propertiesChangedSub?.cancel();
    super.dispose();
  }
}
