import 'dart:async';

import 'package:flutter_discord_rpc/flutter_discord_rpc.dart';
import 'package:lastfm/lastfm.dart';
import 'package:url_launcher/url_launcher.dart';

class ExposeService {
  ExposeService({
    required FlutterDiscordRPC? discordRPC,
    required LastFMAuthorized? lastFm,
  })  : _discordRPC = discordRPC,
        _lastFm = lastFm;

  final FlutterDiscordRPC? _discordRPC;
  final LastFMAuthorized? _lastFm;
  final _errorController = StreamController<String?>.broadcast();
  final _lastFmAuthController = StreamController<bool>.broadcast();
  Stream<String?> get discordErrorStream => _errorController.stream;
  Stream<bool> get isDiscordConnectedStream =>
      _discordRPC?.isConnectedStream ?? Stream.value(false);
  Stream<bool> get isLastFmAuthenticatedStream => _lastFmAuthController.stream;

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
    if (_lastFm != null) {
      await _exposeTitleToLastfm(
        title: title,
        artist: artist,
      );
    }
  }

  Future<Map<String, String>?> setLastFmAuth() async {
    final lastfmua = _lastFm as LastFMUnauthorized;
    launchUrl(
      Uri.parse(await lastfmua.authorizeDesktop()),
    );

    const maxWaitDuration = Duration(minutes: 2); // Customize as needed
    final startTime = DateTime.now();
    await Future.delayed(const Duration(seconds: 10));
    while (DateTime.now().difference(startTime) < maxWaitDuration) {
      try {
        final lastfm = await lastfmua.finishAuthorizeDesktop();
        final sessionKey = lastfm.sessionKey;
        final username = lastfm.username;
        _updateLastFmAuthStatus(true);
        return {
          'sessionKey': sessionKey,
          'username': username,
        };
      } catch (e) {
        await Future.delayed(const Duration(seconds: 10));
      }
    }
    _updateLastFmAuthStatus(false);
    return null;
  }

  void _updateLastFmAuthStatus(bool status) {
    _lastFmAuthController.add(status);
  }

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

  Future<void> _exposeTitleToLastfm({
    required String title,
    required String artist,
  }) async {
    try {
      await _lastFm?.scrobble(
        track: title,
        artist: artist,
        startTime: DateTime.now(),
      );
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
    await _lastFmAuthController.close();
  }
}
