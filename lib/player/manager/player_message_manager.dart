import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../service/player_service.dart';

part 'player_message_manager.g.dart';

@Riverpod(keepAlive: true)
Stream<String> playerMessage(Ref ref) {
  if (!di.isRegistered<PlayerService>()) {
    return const Stream.empty();
  }
  return di<PlayerService>().messageStream;
}
