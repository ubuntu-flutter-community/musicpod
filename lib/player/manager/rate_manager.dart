import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../data/player_change.dart';
import '../service/player_service.dart';

part 'rate_manager.g.dart';

@Riverpod(keepAlive: true)
class RateManager extends _$RateManager {
  RateManager({PlayerService? playerService})
    : _playerServiceOverride = playerService;

  static const rateValues = [.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  final PlayerService? _playerServiceOverride;
  PlayerService? get _playerService {
    if (_playerServiceOverride != null) return _playerServiceOverride;
    if (di.isRegistered<PlayerService>()) return di<PlayerService>();
    return null;
  }

  StreamSubscription<PlayerChange>? _sub;

  @override
  double build() {
    _sub?.cancel();
    final service = _playerService;
    if (service == null) return 1.0;

    _sub = service.changes.whereType<RateChange>().listen((change) {
      state = change.rate;
    });

    ref.onDispose(() {
      _sub?.cancel();
    });

    return service.rate;
  }

  Future<void> setRate(double value) async {
    final service = _playerService;
    if (service == null) return;
    await service.setRate(value);
  }
}
