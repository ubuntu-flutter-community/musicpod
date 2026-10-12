import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../data/player_change.dart';
import '../service/player_service.dart';

part 'volume_manager.g.dart';

@Riverpod(keepAlive: true)
class VolumeManager extends _$VolumeManager {
  VolumeManager({PlayerService? playerService})
      : _playerServiceOverride = playerService;

  final PlayerService? _playerServiceOverride;
  PlayerService? get _playerService {
    if (_playerServiceOverride != null) return _playerServiceOverride;
    if (di.isRegistered<PlayerService>()) return di<PlayerService>();
    return null;
  }

  StreamSubscription<PlayerChange>? _sub;

  @override
  double? build() {
    _sub?.cancel();
    final service = _playerService;
    if (service == null) return null;

    _sub = service.changes
        .whereType<VolumeChange>()
        .listen((change) {
          state = change.volume;
        });

    ref.onDispose(() {
      _sub?.cancel();
    });

    return service.volume;
  }

  Future<void> setVolume(double value) async {
    final service = _playerService;
    if (service == null) return;
    await service.setVolume(value);
  }
}
