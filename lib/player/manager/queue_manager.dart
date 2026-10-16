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
  PlayerService get _service => di<PlayerService>();

  StreamSubscription<PlayerChange>? _sub;

  @override
  Queue build() {
    _sub?.cancel();

    _sub = _service.changes.whereType<QueueChange>().listen((change) {
      state = change.queue;
    });

    ref.onDispose(() => _sub?.cancel());

    return _service.queue;
  }

  void clearQueue() => _service.clearQueue();

  Future<void> insertIntoQueue(List<Audio> newAudios) =>
      _service.insertIntoQueue(newAudios);

  Future<void> moveAudioInQueue(int oldIndex, int newIndex) =>
      _service.moveAudioInQueue(oldIndex, newIndex);

  Future<void> remove(Audio deleteMe) => _service.remove(deleteMe);

  Future<void> playNext() => _service.playNext();

  Future<void> playPrevious() => _service.playPrevious();
}
