import 'dart:async';

import 'package:podcast_search/podcast_search.dart';
import 'package:radio_browser_api/radio_browser_api.dart' hide Country;

class RadioService {
  final RadioBrowserApi radioBrowserApi;

  RadioService(this.radioBrowserApi);

  List<Station>? _stations;
  List<Station>? get stations => _stations;
  void setStations(List<Station>? value) {
    _stations = value;
    _stationsChangedController.add(true);
  }

  final _stationsChangedController = StreamController<bool>.broadcast();
  Stream<bool> get stationsChanged => _stationsChangedController.stream;

  Future<void> loadStations({Country country = Country.germany}) async {
    final stations = await radioBrowserApi.getStationsByCountry(
      country: country.name,
      parameters: InputParameters(
        hidebroken: true,
        reverse: true,
        order: 'stationcount',
        limit: 100,
      ),
    );

    setStations(stations.items);
  }

  List<Tag>? _tags;
  List<Tag>? get tags => _tags;
  void setTags(List<Tag>? value) {
    _tags = value;
    _tagsChangedController.add(true);
  }

  final _tagsChangedController = StreamController<bool>.broadcast();
  Stream<bool> get tagsChanged => _tagsChangedController.stream;

  Future<void> loadTags() async {
    final response = await radioBrowserApi.getTags();
    _tags = response.items;
  }
}
