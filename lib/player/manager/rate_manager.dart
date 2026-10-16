import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../data/player_change.dart';
import '../service/player_service.dart';

part 'rate_manager.g.dart';

@Riverpod(keepAlive: true)
class RateManager extends _$RateManager {
  static const rateValues = [.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  PlayerService get _service => di<PlayerService>();

  StreamSubscription<PlayerChange>? _sub;

  @override
  double build() {
    _sub?.cancel();

    _sub = _service.changes.whereType<RateChange>().listen((change) {
      state = change.rate;
    });

    ref.onDispose(() => _sub?.cancel());

    return _service.rate;
  }

  Future<void> setRate(double value) => _service.setRate(value);
}
