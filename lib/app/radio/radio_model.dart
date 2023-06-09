import 'dart:async';

import 'package:collection/collection.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/service/radio_service.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class RadioModel extends SafeChangeNotifier {
  final RadioService _radioService;
  final String? _countryCode;

  RadioModel(this._radioService, this._countryCode);

  StreamSubscription<bool>? _stationsSub;
  StreamSubscription<bool>? _searchSub;

  Set<Audio>? get stations => _radioService.stations?.isEmpty == false
      ? Set.from(
          _radioService.stations!.map(
            (e) => Audio(
              url: e.urlResolved,
              title: e.name,
              artist: e.tags ?? '',
              album: e.bitrate.toString(),
              audioType: AudioType.radio,
              imageUrl: e.favicon,
              website: e.homepage,
            ),
          ),
        )
      : null;

  Future<void> init() async {
    _stationsSub =
        _radioService.stationsChanged.listen((_) => notifyListeners());

    _searchSub =
        _radioService.searchQueryChanged.listen((_) => notifyListeners());

    if (stations == null) {
      await _loadStationsByCountry();
    }
  }

  Future<void> _loadStationsByCountry() {
    return _radioService.loadStations(
      country: Country.values
              .firstWhereOrNull((c) => c.code == _countryCode)
              ?.name ??
          Country.unitedStates.name,
    );
  }

  Future<void> search(String? searchQuery) async {
    if (searchQuery != null) {
      await _radioService.loadStations(name: searchQuery);
    } else {
      await _loadStationsByCountry();
    }
  }

  String? get searchQuery => _radioService.searchQuery;
  void setSearchQuery(String? value) => _radioService.setSearchQuery(value);

  @override
  void dispose() {
    _stationsSub?.cancel();
    _searchSub?.cancel();
    super.dispose();
  }
}
