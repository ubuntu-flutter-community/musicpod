import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/data/audio.dart';
import '../../dependencies.dart';
import '../data/player_change.dart';
import '../data/queue.dart';
import '../service/player_service.dart';

part 'queue_manager.g.dart';

@Riverpod(keepAlive: true)
class QueueManager extends _$QueueManager {
  QueueManager({PlayerService? playerService})
      : _playerServiceOverride = playerService;

  final PlayerService? _playerServiceOverride;
  PlayerService? get _playerService {
    if (_playerServiceOverride != null) return _playerServiceOverride;
    if (di.isRegistered<PlayerService>()) return di<PlayerService>();
    return null;
  }

  StreamSubscription<PlayerChange>? _sub;

  @override
  Queue build() {
    _sub?.cancel();
    final service = _playerService;
    if (service == null) return const Queue.empty();

    _sub = service.changes
        .whereType<QueueChange>()
        .listen((change) {
          state = change.queue;
        });

    ref.onDispose(() {
      _sub?.cancel();
    });

    return service.queue;
  }

  void clearQueue() {
    final service = _playerService;
    if (service == null) return;
    service.clearQueue();
  }

  Future<void> insertIntoQueue(List<Audio> newAudios) async {
    final service = _playerService;
    if (service == null) return;
    await service.insertIntoQueue(newAudios);
  }

  Future<void> moveAudioInQueue(int oldIndex, int newIndex) async {
    final service = _playerService;
    if (service == null) return;
    await service.moveAudioInQueue(oldIndex, newIndex);
  }

  Future<void> remove(Audio deleteMe) async {
    final service = _playerService;
    if (service == null) return;
    await service.remove(deleteMe);
  }

  Future<void> playNext() async {
    final service = _playerService;
    if (service == null) return;
    await service.playNext();
  }

  Future<void> playPrevious() async {
    final service = _playerService;
    if (service == null) return;
    await service.playPrevious();
  }
}
