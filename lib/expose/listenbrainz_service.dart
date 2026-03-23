import 'package:injectable/injectable.dart';
import 'package:listenbrainz_dart/listenbrainz_dart.dart';

import '../common/logging.dart';
import '../settings/settings_service.dart';
import '../settings/shared_preferences_keys.dart';

@lazySingleton
class ListenBrainzService {
  ListenBrainzService({required SettingsService settingsService})
    : _settingsService = settingsService {
    init();
  }

  final SettingsService _settingsService;
  ListenBrainz? _listenBrainz;

  void init() {
    final apiKey = _settingsService.getString(SPKeys.listenBrainzApiKey);
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
          _settingsService.getBool(SPKeys.enableListenBrainz) == true) {
        final track = Track(title: title, artist: artist);
        await _listenBrainz!.submitSingle(track, DateTime.now());
        await _listenBrainz!.submitPlayingNow(track);
      }
    } on Exception catch (e) {
      printMessageInDebugMode(e);
    }
  }
}
