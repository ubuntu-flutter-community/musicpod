import 'dart:async';

import 'package:radio_browser_api/radio_browser_api.dart';

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

  Future<void> loadStations({
    String? country,
    String? name,
    String? state,
    Tag? tag,
  }) async {
    RadioBrowserListResponse<Station>? response;

    if (name?.isEmpty == false) {
      response = await radioBrowserApi.getStationsByName(
        name: name!,
        parameters: const InputParameters(
          hidebroken: true,
          order: 'stationcount',
          limit: 100,
        ),
      );
    } else if (country?.isEmpty == false) {
      response = await radioBrowserApi.getStationsByCountry(
        country: country!,
        parameters: const InputParameters(
          hidebroken: true,
          order: 'stationcount',
          limit: 100,
        ),
      );
    } else if (tag != null) {
      response = await radioBrowserApi.getStationsByTag(
        tag: tag.name,
        parameters: const InputParameters(
          hidebroken: true,
          order: 'stationcount',
          limit: 100,
        ),
      );
    } else if (state?.isEmpty == false) {
      response = await radioBrowserApi.getStationsByState(
        state: country!,
        parameters: const InputParameters(
          hidebroken: true,
          order: 'stationcount',
          limit: 100,
        ),
      );
    }

    setStations(response?.items);
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
    final response = await radioBrowserApi.getTags(
      parameters: const InputParameters(
        hidebroken: true,
        limit: 100,
        order: 'stationcount',
        reverse: true,
      ),
    );
    _tags = response.items;
  }

  String? _searchQuery;
  String? get searchQuery => _searchQuery;
  final _searchController = StreamController<bool>.broadcast();
  Stream<bool> get searchQueryChanged => _searchController.stream;
  void setSearchQuery(String? value) {
    if (value == _searchQuery) return;
    _searchQuery = value;
    _searchController.add(true);
  }
}
