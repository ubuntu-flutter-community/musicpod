import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../data/player_change.dart';
import '../service/player_service.dart';

part 'player_color_manager.g.dart';

@Riverpod(keepAlive: true)
class PlayerColorManager extends _$PlayerColorManager {
  PlayerColorManager({PlayerService? playerService})
      : _playerServiceOverride = playerService;

  final PlayerService? _playerServiceOverride;
  PlayerService? get _playerService {
    if (_playerServiceOverride != null) return _playerServiceOverride;
    if (di.isRegistered<PlayerService>()) return di<PlayerService>();
    return null;
  }

  StreamSubscription<PlayerChange>? _sub;

  @override
  Color? build() {
    _sub?.cancel();
    final service = _playerService;
    if (service == null) return null;

    _sub = service.changes
        .whereType<ColorChange>()
        .listen((change) {
          state = change.color;
        });

    ref.onDispose(() {
      _sub?.cancel();
    });

    return service.color;
  }

  Future<void> setRemoteColorFromImageProvider(
    ImageProvider imageProvider,
  ) async {
    final service = _playerService;
    if (service == null) return;
    await service.setRemoteColorFromImageProvider(imageProvider);
  }
}
