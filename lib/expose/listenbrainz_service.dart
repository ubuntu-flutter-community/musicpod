import 'package:injectable/injectable.dart';
import 'package:listenbrainz_dart/listenbrainz_dart.dart';

import '../common/logging.dart';
import '../settings/settings_service.dart';
import '../settings/shared_preferences_keys.dart';

@lazySingleton
class ListenBrainzService {
  ListenBrainzService({required SettingsService settingsService})
    : _settingsService = settingsService;

  final SettingsService _settingsService;
  ListenBrainz? _listenBrainz;
  bool get isInitialized => _listenBrainz != null;

  Future<void> init({String? newKey, bool rethrowError = false}) async {
    try {
      if (newKey != null) {
        await _settingsService.setValue(SPKeys.listenBrainzApiKey, newKey);
      }
      final apiKey = _settingsService.getString(SPKeys.listenBrainzApiKey);
      if (apiKey != null) {
        _listenBrainz = ListenBrainz(apiKey);
      }
    } on Exception catch (e, st) {
      printMessageInDebugMode(e, trace: st);
      if (rethrowError) {
        rethrow;
      }
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
