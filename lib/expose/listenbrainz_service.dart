import 'package:listenbrainz_dart/listenbrainz_dart.dart';

import '../common/logging.dart';
import '../settings/settings_service.dart';

class ListenBrainzService {
  ListenBrainzService({required SettingsService settingsService})
      : _settingsService = settingsService;

  final SettingsService _settingsService;
  ListenBrainz? _listenBrainz;

  void init() {
    final apiKey = _settingsService.listenBrainzApiKey;
    if (apiKey != null) {
      _listenBrainz = ListenBrainz(apiKey);
    }
  }

  Future<void> exposeTrackToListenBrainz({
    required String title,
    required String artist,
  }) async {
    try {
      if (_listenBrainz != null &&
          _settingsService.enableListenBrainzScrobbling) {
        await _listenBrainz!.submitSingle(
          Track(title: title, artist: artist),
          DateTime.now(),
        );
      }
    } on Exception catch (e) {
      printMessageInDebugMode(e);
    }
  }
}
