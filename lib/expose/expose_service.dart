import 'dart:async';

import 'package:flutter/widgets.dart';

import 'lastfm_service.dart';
import 'listenbrainz_service.dart';

class ExposeService {
  ExposeService({
    required LastfmService lastFmService,
    required ListenBrainzService listenBrainzService,
  }) : _lastFmService = lastFmService,
       _listenBrainzService = listenBrainzService;

  final LastfmService _lastFmService;
  final ListenBrainzService _listenBrainzService;

  final _errorController = StreamController<String?>.broadcast();

  Future<void> exposeTitleOnline({
    required String title,
    required String artist,
    required String additionalInfo,
    String? imageUrl,
  }) async {
    await _lastFmService.exposeTitleToLastfm(title: title, artist: artist);

    await _listenBrainzService.exposeTrackToListenBrainz(
      title: title,
      artist: artist,
    );
  }

  void initListenBrains() => _listenBrainzService.init();

  ValueNotifier<bool> get isLastFmAuthorized => _lastFmService.isAuthorized;
  Future<void> authorizeLastFm({
    required String apiKey,
    required String apiSecret,
  }) => _lastFmService.authorize(apiKey: apiKey, apiSecret: apiSecret);

  Future<void> dispose() async {
    await _errorController.close();
  }
}
