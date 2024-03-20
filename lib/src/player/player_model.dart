import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import '../../data.dart';
import 'player_service.dart';

const rateValues = [1.0, 1.5, 2.0];

class PlayerModel extends SafeChangeNotifier {
  final PlayerService service;
  PlayerModel({required this.service});

  VideoController get controller => service.controller;

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

  String? get queueName => service.queue.$1;

  List<Audio> get queue => service.queue.$2;
  MpvMetaData? get mpvMetaData => service.mpvMetaData;

  Audio? get audio => service.audio;

  bool? get isVideo => service.isVideo;

  Audio? get nextAudio => service.nextAudio;

  bool get isPlaying => service.isPlaying;

  Duration? get duration => service.duration;

  Duration? get position => service.position;
  void setPosition(Duration? value) => service.setPosition(value);

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

  bool get repeatSingle => service.repeatSingle;
  void setRepeatSingle(bool value) => service.setRepeatSingle(value);

  bool get shuffle => service.shuffle;
  void setShuffle(bool value) => service.setShuffle(value);

  double get volume => service.volume;
  Future<void> setVolume(double value) async => await service.setVolume(value);

  double get rate => service.rate;
  Future<void> setRate(double value) async => await service.setRate(value);

  Future<void> play({Duration? newPosition, Audio? newAudio}) async =>
      await service.play(newAudio: newAudio, newPosition: newPosition);

  Future<void> playOrPause() async => await service.playOrPause();

  Future<void> pause() async => await service.pause();

  Future<void> seek() async => await service.seek();

  Future<void> resume() async => await service.resume();

  Future<void> init() async {
    _queueNameChangedSub =
        service.queueChanged.listen((_) => notifyListeners());
    _queueChangedSub = service.queueChanged.listen((_) => notifyListeners());
    _mpvMetaDataChangedSub =
        service.mpvMetaDataChanged.listen((_) => notifyListeners());

    _audioChangedSub = service.audioChanged.listen((_) => notifyListeners());
    _isVideoChangedSub =
        service.isVideoChanged.listen((_) => notifyListeners());
    _nextAudioChangedSub =
        service.nextAudioChanged.listen((_) => notifyListeners());
    _shuffleChangedSub =
        service.shuffleChanged.listen((_) => notifyListeners());
    _repeatSingleChangedSub =
        service.repeatSingleChanged.listen((_) => notifyListeners());
    _volumeChangedSub = service.volumeChanged.listen((_) => notifyListeners());
    _rateChanged = service.rateChanged.listen((_) => notifyListeners());

    _isPlayingChangedSub =
        service.isPlayingChanged.listen((_) => notifyListeners());
    _durationChangedSub =
        service.durationChanged.listen((_) => notifyListeners());
    _positionChangedSub =
        service.positionChanged.listen((_) => notifyListeners());
  }

  Future<void> playNext() async => await service.playNext();

  void insertIntoQueue(Audio audio) async => service.insertIntoQueue(audio);

  void moveAudioInQueue(int oldIndex, int newIndex) async =>
      service.moveAudioInQueue(oldIndex, newIndex);

  void remove(Audio deleteMe) => service.remove(deleteMe);

  Future<void> playPrevious() async => await service.playPrevious();

  Future<void> startPlaylist({
    required Set<Audio> audios,
    required String listName,
    int? index,
  }) async =>
      await service.startPlaylist(
        audios: audios,
        listName: listName,
        index: index,
      );

  Color? get color => service.color;

  bool _isUpNextExpanded = false;
  bool get isUpNextExpanded => _isUpNextExpanded;
  void setUpNextExpanded(bool value) {
    if (value == _isUpNextExpanded) return;
    _isUpNextExpanded = value;
    notifyListeners();
  }

  void safeLastPosition() => service.safeLastPosition();

  Future<void> loadColor({String? url}) async => service.loadColor(url: url);

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
    super.dispose();
  }
}

final playerModelProvider = ChangeNotifierProvider<PlayerModel>((ref) {
  return PlayerModel(service: getService<PlayerService>());
});
