import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

import 'lastfm_service.dart';
import 'listenbrainz_service.dart';

@lazySingleton
class ExposeService {
  ExposeService({
    required LastfmService lastFmService,
    required ListenBrainzService listenBrainzService,
  }) : _lastFmService = lastFmService,
       _listenBrainzService = listenBrainzService;

  final LastfmService _lastFmService;
  final ListenBrainzService _listenBrainzService;

  Future<void> exposeTitleOnline({
    required String title,
    required String artist,
    required String additionalInfo,
    String? imageUrl,
  }) async {
    if (!_listenBrainzService.isInitialized) {
      await _listenBrainzService.init();
    }
    if (!_lastFmService.isAuthorized.value) {
      await _lastFmService.init();
    }

    await _lastFmService.exposeTitleToLastfm(title: title, artist: artist);

    await _listenBrainzService.exposeTrackToListenBrainz(
      title: title,
      artist: artist,
    );
  }

  Future<void> initListenBrains(String apiKey) =>
      _listenBrainzService.init(newKey: apiKey, rethrowError: true);

  ValueNotifier<bool> get isLastFmAuthorized => _lastFmService.isAuthorized;
  Future<void> authorizeLastFm({
    required String apiKey,
    required String apiSecret,
  }) => _lastFmService.authorize(apiKey: apiKey, apiSecret: apiSecret);
}
