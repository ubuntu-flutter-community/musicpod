import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../data/player_change.dart';
import '../service/player_service.dart';

part 'player_color_manager.g.dart';

@Riverpod(keepAlive: true)
class PlayerColorManager extends _$PlayerColorManager {
  PlayerService get _service => di<PlayerService>();

  StreamSubscription<PlayerChange>? _sub;

  @override
  Color? build() {
    _sub?.cancel();

    _sub = _service.changes.whereType<ColorChange>().listen((change) {
      state = change.color;
    });

    ref.onDispose(() => _sub?.cancel());

    return _service.color;
  }

  Future<void> setRemoteColorFromImageProvider(ImageProvider imageProvider) =>
      _service.setRemoteColorFromImageProvider(imageProvider);
}
