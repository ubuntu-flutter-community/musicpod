import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_discord_rpc/flutter_discord_rpc.dart';

import 'lastfm_service.dart';
import 'listenbrainz_service.dart';

class ExposeService {
  ExposeService({
    required FlutterDiscordRPC? discordRPC,
    required LastfmService lastFmService,
    required ListenBrainzService listenBrainzService,
  })  : _discordRPC = discordRPC,
        _lastFmService = lastFmService,
        _listenBrainzService = listenBrainzService;

  final FlutterDiscordRPC? _discordRPC;
  final LastfmService _lastFmService;
  final ListenBrainzService _listenBrainzService;

  final _errorController = StreamController<String?>.broadcast();
  Stream<String?> get discordErrorStream => _errorController.stream;
  Stream<bool> get isDiscordConnectedStream =>
      _discordRPC?.isConnectedStream ?? Stream.value(false);

  Future<void> exposeTitleOnline({
    required String title,
    required String artist,
    required String additionalInfo,
    String? imageUrl,
  }) async {
    await _exposeTitleToDiscord(
      title: title,
      artist: artist,
      additionalInfo: additionalInfo,
      imageUrl: imageUrl,
    );

    await _lastFmService.exposeTitleToLastfm(
      title: title,
      artist: artist,
    );

    await _listenBrainzService.exposeTrackToListenBrainz(
      title: title,
      artist: artist,
    );
  }

  void initListenBrains() => _listenBrainzService.init();

  Future<void> _exposeTitleToDiscord({
    required String title,
    required String artist,
    required String additionalInfo,
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
              largeText: additionalInfo,
              largeImage: imageUrl,
            ),
            details: title,
            state: artist,
            activityType: ActivityType.listening,
          ),
        );
      }
    } on Exception catch (e) {
      _errorController.add(e.toString());
    }
  }

  Future<void> connect() async {
    await connectToDiscord();
  }

  Future<void> connectToDiscord() async {
    try {
      await _discordRPC?.connect();
    } on Exception catch (e) {
      _errorController.add(e.toString());
    }
  }

  ValueNotifier<bool> get isLastFmAuthorized => _lastFmService.isAuthorized;
  Future<void> authorizeLastFm({
    required String apiKey,
    required String apiSecret,
  }) =>
      _lastFmService.authorize(
        apiKey: apiKey,
        apiSecret: apiSecret,
      );

  Future<void> disconnectFromDiscord() async {
    try {
      await _discordRPC?.disconnect();
    } on Exception catch (e) {
      _errorController.add(e.toString());
    }
  }

  Future<void> dispose() async {
    await disconnectFromDiscord();
    await _errorController.close();
  }
}
