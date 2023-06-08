import 'dart:async';

import 'package:musicpod/data/audio.dart';
import 'package:musicpod/service/radio_service.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class RadioModel extends SafeChangeNotifier {
  final RadioService _radioService;

  RadioModel(this._radioService);

  StreamSubscription<bool>? _stationsSub;

  Set<Audio>? get stations => Set.from(
        _radioService.stations?.map(
              (e) => Audio(
                url: e.urlResolved,
                title: e.name,
                artist: e.tags,
                album: e.bitrate.toString(),
                audioType: AudioType.radio,
              ),
            ) ??
            [],
      );

  Future<void> init(String? countryCode) async {
    _stationsSub =
        _radioService.stationsChanged.listen((_) => notifyListeners());

    await _radioService.loadStations(
      country: Country.values.where((c) => c.code == countryCode).firstOrNull ??
          Country.unitedStates,
    );
  }

  @override
  void dispose() {
    _stationsSub?.cancel();
    super.dispose();
  }
}
