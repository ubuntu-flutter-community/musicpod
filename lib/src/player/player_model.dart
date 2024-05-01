import 'dart:async';

import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../../data.dart';
import 'player_service.dart';

const rateValues = [1.0, 1.5, 2.0];

class PlayerModel extends SafeChangeNotifier {
  final PlayerService _service;
  PlayerModel({required PlayerService service}) : _service = service;

  VideoController get controller => _service.controller;

  StreamSubscription<bool>? _queueNameChangedSub;
  StreamSubscription<bool>? _queueChangedSub;
  StreamSubscription<bool>? _mpvMetaDataChangedSub;
  StreamSubscription<bool>? _audioChangedSub;
  StreamSubscription<bool>? _isVideoChangedSub;
  StreamSubscription<bool>? _nextAudioChangedSub;
  StreamSubscription<bool>? _shuffleChangedSub;
  StreamSubscription<bool>? _repeatSingleChangedSub;
  StreamSubscription<bool>? _volumeChangedSub;
  StreamSubscription<bool>? _isPlayingChangedSub;
  StreamSubscription<bool>? _durationChangedSub;
  StreamSubscription<bool>? _positionChangedSub;
  StreamSubscription<bool>? _rateChanged;
  StreamSubscription<bool>? _radioHistoryChangedSub;

  String? get queueName => _service.queue.$1;

  List<Audio> get queue => _service.queue.$2;
  MpvMetaData? get mpvMetaData => _service.mpvMetaData;

  Audio? get audio => _service.audio;

  bool? get isVideo => _service.isVideo;

  Audio? get nextAudio => _service.nextAudio;

  bool get isPlaying => _service.isPlaying;

  Duration? get duration => _service.duration;

  Duration? get position => _service.position;
  void setPosition(Duration? value) => _service.setPosition(value);

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

  bool get repeatSingle => _service.repeatSingle;
  void setRepeatSingle(bool value) => _service.setRepeatSingle(value);

  bool get shuffle => _service.shuffle;
  void setShuffle(bool value) => _service.setShuffle(value);

  double? get volume => _service.volume;
  Future<void> setVolume(double value) async => await _service.setVolume(value);

  double get rate => _service.rate;
  Future<void> setRate(double value) async => await _service.setRate(value);

  Future<void> playOrPause() async => await _service.playOrPause();

  Future<void> pause() async => await _service.pause();

  Future<void> seek() async => await _service.seek();

  Future<void> resume() async => await _service.resume();

  void init() async {
    _queueNameChangedSub ??=
        _service.queueChanged.listen((_) => notifyListeners());
    _queueChangedSub ??= _service.queueChanged.listen((_) => notifyListeners());
    _mpvMetaDataChangedSub ??=
        _service.mpvMetaDataChanged.listen((_) => notifyListeners());
    _audioChangedSub = _service.audioChanged.listen((_) => notifyListeners());
    _isVideoChangedSub ??=
        _service.isVideoChanged.listen((_) => notifyListeners());
    _nextAudioChangedSub ??=
        _service.nextAudioChanged.listen((_) => notifyListeners());
    _shuffleChangedSub ??=
        _service.shuffleChanged.listen((_) => notifyListeners());
    _repeatSingleChangedSub ??=
        _service.repeatSingleChanged.listen((_) => notifyListeners());
    _volumeChangedSub ??=
        _service.volumeChanged.listen((_) => notifyListeners());
    _rateChanged ??= _service.rateChanged.listen((_) => notifyListeners());
    _isPlayingChangedSub ??=
        _service.isPlayingChanged.listen((_) => notifyListeners());
    _durationChangedSub ??=
        _service.durationChanged.listen((_) => notifyListeners());
    _positionChangedSub ??=
        _service.positionChanged.listen((_) => notifyListeners());
    _radioHistoryChangedSub ??=
        _service.radioHistoryChanged.listen((_) => notifyListeners());
  }

  Future<void> playNext() async => await _service.playNext();

  void insertIntoQueue(Audio audio) async => _service.insertIntoQueue(audio);

  void moveAudioInQueue(int oldIndex, int newIndex) async =>
      _service.moveAudioInQueue(oldIndex, newIndex);

  void remove(Audio deleteMe) => _service.remove(deleteMe);

  Future<void> playPrevious() async => await _service.playPrevious();

  Future<void> startPlaylist({
    required Set<Audio> audios,
    required String listName,
    int? index,
  }) async =>
      await _service.startPlaylist(
        audios: audios,
        listName: listName,
        index: index,
      );

  Color? get color => _service.color;

  bool _isUpNextExpanded = false;
  bool get isUpNextExpanded => _isUpNextExpanded;
  void setUpNextExpanded(bool value) {
    if (value == _isUpNextExpanded) return;
    _isUpNextExpanded = value;
    notifyListeners();
  }

  void safeLastPosition() => _service.safeLastPosition();

  Map<String, MpvMetaData> get radioHistory => _service.radioHistory;

  Iterable<MapEntry<String, MpvMetaData>> filteredRadioHistory(
      {required String? filter}) {
    return radioHistory.entries.where(
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
        .toString()
        .replaceAll(', ', '')
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll('(', '')
        .replaceAll(')', '');
  }

  @override
  Future<void> dispose() async {
    await _queueNameChangedSub?.cancel();
    await _queueChangedSub?.cancel();
    await _mpvMetaDataChangedSub?.cancel();
    await _audioChangedSub?.cancel();
    await _isVideoChangedSub?.cancel();
    await _nextAudioChangedSub?.cancel();
    await _shuffleChangedSub?.cancel();
    await _repeatSingleChangedSub?.cancel();
    await _volumeChangedSub?.cancel();
    await _isPlayingChangedSub?.cancel();
    await _durationChangedSub?.cancel();
    await _positionChangedSub?.cancel();
    await _rateChanged?.cancel();
    await _radioHistoryChangedSub?.cancel();
    super.dispose();
  }
}
