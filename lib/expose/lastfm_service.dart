import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:lastfm/lastfm.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common/logging.dart';
import '../settings/settings_service.dart';

class LastfmService {
  LastfmService({required SettingsService settingsService})
      : _settingsService = settingsService {
    init();
  }

  final SettingsService _settingsService;

  LastFM? _lastFm;
  final isAuthorized = ValueNotifier<bool>(false);
  void _setLastFm(LastFM lastFm) {
    _lastFm = lastFm;
    isAuthorized.value = lastFm is LastFMAuthorized;
  }

  Future<void> exposeTitleToLastfm({
    required String title,
    required String artist,
  }) async {
    if (isAuthorized.value && _settingsService.enableLastFmScrobbling) {
      try {
        await (_lastFm as LastFMAuthorized).scrobble(
          track: title,
          artist: artist,
          startTime: DateTime.now(),
        );
      } on Exception catch (e) {
        printMessageInDebugMode(e);
      }
    }
  }

  void init({LastFMAuthorized? lastFmAuthorized}) {
    if (lastFmAuthorized != null) {
      _setLastFm(lastFmAuthorized);
      _settingsService.setLastFmSessionKey(lastFmAuthorized.sessionKey);
      _settingsService.setLastFmUsername(lastFmAuthorized.username);
    } else {
      final apiKey = _settingsService.lastFmApiKey;
      final apiSecret = _settingsService.lastFmSecret;
      final sessionKey = _settingsService.lastFmSessionKey;
      final username = _settingsService.lastFmUsername;

      if (sessionKey != null &&
          username != null &&
          apiKey != null &&
          apiSecret != null) {
        _setLastFm(
          LastFMAuthorized(
            apiKey,
            secret: apiSecret,
            sessionKey: sessionKey,
            username: username,
          ),
        );
      } else if (apiKey != null) {
        _setLastFm(LastFMUnauthorized(apiKey, apiSecret));
      }
    }
  }

  Future<void> authorize({
    required String apiKey,
    required String apiSecret,
  }) async {
    _settingsService.setLastFmApiKey(apiKey);
    _settingsService.setLastFmSecret(apiSecret);

    final lastfmua = LastFMUnauthorized(apiKey, apiSecret);
    launchUrl(
      Uri.parse(await lastfmua.authorizeDesktop()),
    );

    const maxWaitDuration = Duration(minutes: 2); // Customize as needed
    final startTime = DateTime.now();
    await Future.delayed(const Duration(seconds: 10));
    while (DateTime.now().difference(startTime) < maxWaitDuration) {
      try {
        final lastfm = await lastfmua.finishAuthorizeDesktop();
        init(lastFmAuthorized: lastfm);
      } catch (e) {
        printMessageInDebugMode(e);
        await Future.delayed(const Duration(seconds: 10));
      }

      if (isAuthorized.value) break;
    }
  }
}
