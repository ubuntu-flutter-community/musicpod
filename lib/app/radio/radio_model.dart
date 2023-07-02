import 'dart:async';

import 'package:collection/collection.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/service/radio_service.dart';
import 'package:musicpod/string_x.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:radio_browser_api/radio_browser_api.dart' hide Country;
import 'package:safe_change_notifier/safe_change_notifier.dart';

class RadioModel extends SafeChangeNotifier {
  final RadioService _radioService;

  RadioModel(this._radioService);

  StreamSubscription<bool>? _stationsSub;
  StreamSubscription<bool>? _searchSub;
  StreamSubscription<bool>? _tagsSub;

  Country? _country;
  Country? get country => _country;
  void setCountry(Country value) {
    if (value == _country) return;
    _country = value;
    notifyListeners();
  }

  List<Tag>? get tags => _radioService.tags;
  Tag? _tag;
  Tag? get tag => _tag;
  void setTag(Tag? value) {
    if (value == null || value == _tag) return;
    _tag = value;
    notifyListeners();
  }

  Set<Audio>? get stations {
    if (_radioService.stations != null) {
      if (_radioService.stations!.isEmpty) {
        return <Audio>{};
      }

      return Set.from(
        _radioService.stations!.map(
          (e) => Audio(
            url: e.urlResolved,
            title: e.name,
            artist: e.bitrate == 0 ? ' ' : '${e.bitrate.toString()} kb/s',
            album: e.tags ?? '',
            audioType: AudioType.radio,
            imageUrl: e.favicon,
            website: e.homepage,
          ),
        ),
      );
    } else {
      return null;
    }
  }

  Future<void> init(String? countryCode) async {
    await _radioService.init();

    _stationsSub =
        _radioService.stationsChanged.listen((_) => notifyListeners());

    _searchSub =
        _radioService.searchQueryChanged.listen((_) => notifyListeners());

    _tagsSub = _radioService.tagsChanged.listen((_) => notifyListeners());

    await _radioService.loadTags();

    final c = Country.values.firstWhereOrNull((c) => c.code == countryCode);
    _country = c;

    if (stations == null) {
      await loadStationsByCountry();
    }

    notifyListeners();
  }

  Future<void> loadStationsByCountry() {
    return _radioService.loadStations(
      country: country?.name.camelToSentence(),
    );
  }

  Future<void> loadStationsByTag() async {
    await _radioService.loadStations(tag: tag);
  }

  Future<void> search({String? name, String? tag}) async {
    if (name != null) {
      await _radioService.loadStations(name: name);
    } else if (tag != null) {
      await _radioService.loadStations(tag: Tag(name: tag, stationCount: 1));
    } else {
      await loadStationsByCountry();
    }
  }

  String? get searchQuery => _radioService.searchQuery;
  void setSearchQuery(String? value) => _radioService.setSearchQuery(value);

  bool _searchActive = false;
  bool get searchActive => _searchActive;
  void setSearchActive(bool value) {
    if (value == _searchActive) return;
    _searchActive = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _stationsSub?.cancel();
    _searchSub?.cancel();
    _tagsSub?.cancel();
    super.dispose();
  }
}
