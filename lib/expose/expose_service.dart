import 'dart:async';

import 'package:flutter_discord_rpc/flutter_discord_rpc.dart';

import '../constants.dart';

class ExposeService {
  ExposeService({required FlutterDiscordRPC? discordRPC})
      : _discordRPC = discordRPC;

  final FlutterDiscordRPC? _discordRPC;
  final _errorController = StreamController<String?>.broadcast();
  Stream<String?> get discordErrorStream => _errorController.stream;
  Stream<bool> get isDiscordConnectedStream =>
      _discordRPC?.isConnectedStream ?? Stream.value(false);

  Future<void>? exposeTitleOnline({
    required String songDetails,
    required String state,
  }) async {
    try {
      if (_discordRPC?.isConnected == false) {
        await _discordRPC?.connect(autoRetry: true);
      }
      if (_discordRPC?.isConnected == true) {
        await _discordRPC?.setActivity(
          activity: RPCActivity(
            assets: RPCAssets(
              largeText: songDetails,
              smallText: kAppTitle,
            ),
            details: songDetails,
            state: state,
          ),
        );
      }
    } on Exception catch (_) {}
  }

  Future<void> connectToDiscord() async =>
      _discordRPC?.connect(autoRetry: true);

  Future<void> disconnectFromDiscord() async => _discordRPC?.disconnect();

  Future<void> dispose() async {
    await _discordRPC?.disconnect();
    await _errorController.close();
  }
}
