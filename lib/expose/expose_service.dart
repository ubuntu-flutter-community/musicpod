import 'dart:async';

import 'package:flutter_discord_rpc/flutter_discord_rpc.dart';

class ExposeService {
  ExposeService({required FlutterDiscordRPC? discordRPC})
      : _discordRPC = discordRPC;

  final FlutterDiscordRPC? _discordRPC;
  final _errorController = StreamController<String?>.broadcast();
  Stream<String?> get discordErrorStream => _errorController.stream;
  Stream<bool> get isDiscordConnectedStream =>
      _discordRPC?.isConnectedStream ?? Stream.value(false);

  Future<void> exposeTitleOnline({
    required String line1,
    required String line2,
    required String line3,
    String? imageUrl,
  }) async {
    try {
      if (_discordRPC?.isConnected == false) {
        await _discordRPC?.connect();
      }
      if (_discordRPC?.isConnected == true) {
        await _discordRPC?.setActivity(
          activity: RPCActivity(
            assets: RPCAssets(
              largeText: line3,
              largeImage: imageUrl,
            ),
            details: line1,
            state: line2,
            activityType: ActivityType.listening,
          ),
        );
      }
    } on Exception catch (e) {
      _errorController.add(e.toString());
    }
  }

  Future<void> connect() async {
    try {
      await _discordRPC?.connect();
    } on Exception catch (e) {
      _errorController.add(e.toString());
    }
  }

  Future<void> connectToDiscord() async {
    try {
      await _discordRPC?.connect();
    } on Exception catch (e) {
      _errorController.add(e.toString());
    }
  }

  Future<void> disconnectFromDiscord() async {
    try {
      await _discordRPC?.disconnect();
    } on Exception catch (e) {
      _errorController.add(e.toString());
    }
  }

  Future<void> dispose() async {
    await _discordRPC?.disconnect();
    await _errorController.close();
  }
}