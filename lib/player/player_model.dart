import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../common/data/audio.dart';
import '../common/data/mpv_meta_data.dart';
import 'player_service.dart';

const rateValues = [.75, 1.0, 1.25, 1.5, 1.75, 2.0];

class PlayerModel extends SafeChangeNotifier {
  final PlayerService _service;
  PlayerModel({
    required PlayerService service,
    required Connectivity connectivity,
  }) : _service = service;

  VideoController get controller => _service.controller;

  StreamSubscription<bool>? _propertiesChangedSub;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  String? get queueName => _service.queue.name;

  List<Audio> get queue => _service.queue.audios;
  MpvMetaData? get mpvMetaData => _service.mpvMetaData;

  Audio? get audio => _service.audio;

  bool? get isVideo => _service.isVideo;

  Audio? get nextAudio => _service.nextAudio;

  bool get isPlaying => _service.isPlaying;

  Duration? get duration => _service.duration;

  Duration? get position => _service.position;
  void setPosition(Duration? value) => _service.setPosition(value);

  Duration? get buffer => _service.buffer;

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
  Future<void> setVolume(double value) async => _service.setVolume(value);

  double get rate => _service.rate;
  Future<void> setRate(double value) async => _service.setRate(value);

  Future<void> playOrPause() async => _service.playOrPause();

  Future<void> pause() async => _service.pause();

  Future<void> seek() async => _service.seek();

  Future<void> resume() async => _service.resume();

  void init() => _propertiesChangedSub ??=
      _service.propertiesChanged.listen((_) => notifyListeners());

  Future<void> playNext() async => _service.playNext();

  void insertIntoQueue(Audio audio) async => _service.insertIntoQueue(audio);

  void moveAudioInQueue(int oldIndex, int newIndex) async =>
      _service.moveAudioInQueue(oldIndex, newIndex);

  void remove(Audio deleteMe) => _service.remove(deleteMe);

  Future<void> playPrevious() async => _service.playPrevious();

  Future<void> startPlaylist({
    required List<Audio> audios,
    required String listName,
    int? index,
  }) async =>
      _service.startPlaylist(
        audios: audios,
        listName: listName,
        index: index,
      );

  Color? get color => _service.color;
  String? get remoteImageUrl => _service.remoteImageUrl;

  bool _isUpNextExpanded = false;
  bool get isUpNextExpanded => _isUpNextExpanded;
  void setUpNextExpanded(bool value) {
    if (value == _isUpNextExpanded) return;
    _isUpNextExpanded = value;
    notifyListeners();
  }

  Map<String, Duration>? get lastPositions => _service.lastPositions;
  Duration? getLastPosition(String? url) => _service.getLastPosition(url);
  Future<void> safeLastPosition() => _service.safeLastPosition();
  Future<void> removeLastPosition(String key) =>
      _service.removeLastPosition(key);
  Future<void> removeLastPositions(List<Audio> audios) =>
      _service.removeLastPositions(audios);

  int getRadioHistoryLength({String? filter}) =>
      filteredRadioHistory(filter: filter).length;
  Iterable<MapEntry<String, MpvMetaData>> filteredRadioHistory({
    required String? filter,
  }) {
    return _service.radioHistory.entries.where(
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

  void setTimer(Duration duration) => _service.setTimer(duration);

  @override
  Future<void> dispose() async {
    await _propertiesChangedSub?.cancel();
    await _connectivitySubscription?.cancel();
    super.dispose();
  }
}
