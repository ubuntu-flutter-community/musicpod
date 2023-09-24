import 'dart:async';

import 'package:basic_utils/basic_utils.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:musicpod/constants.dart';
import 'package:radio_browser_api/radio_browser_api.dart';

class RadioService {
  RadioBrowserApi? radioBrowserApi;
  final Connectivity connectivity;

  RadioService(this.connectivity);

  Future<bool> init() async {
    final result = await connectivity.checkConnectivity();
    if (result != ConnectivityResult.none) {
      if (radioBrowserApi == null) {
        final hosts = await _findHost();

        for (var host in hosts) {
          try {
            radioBrowserApi = RadioBrowserApi.fromHost(host);
            return true;
            // ignore: unused_catch_clause
          } on Exception catch (e) {
            return false;
          }
        }
      } else {
        return true;
      }
    }
    return false;
  }

  Future<List<String>> _findHost() async {
    final hosts = <String>[];
    final records = await DnsUtils.lookupRecord(
      kRadioBrowserBaseUrl,
      RRecordType.A,
    );

    for (RRecord record in records ?? <RRecord>[]) {
      final reverse = await DnsUtils.reverseDns(record.data);
      for (RRecord r in reverse ?? <RRecord>[]) {
        hosts.add(r.data.replaceAll('info.', 'info'));
      }
    }
    return hosts;
  }

  Future<void> dispose() async {
    _searchController.close();
    _tagsChangedController.close();
    _stationsChangedController.close();
  }

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
    int limit = 100,
  }) async {
    if (radioBrowserApi == null) return;
    RadioBrowserListResponse<Station>? response;
    try {
      if (name?.isEmpty == false) {
        response = await radioBrowserApi!.getStationsByName(
          name: name!,
          parameters: InputParameters(
            hidebroken: true,
            order: 'stationcount',
            limit: limit,
          ),
        );
      } else if (country?.isEmpty == false) {
        response = await radioBrowserApi!.getStationsByCountry(
          country: country!,
          parameters: InputParameters(
            hidebroken: true,
            order: 'stationcount',
            limit: limit,
          ),
        );
      } else if (tag != null) {
        response = await radioBrowserApi!.getStationsByTag(
          tag: tag.name,
          parameters: InputParameters(
            hidebroken: true,
            order: 'stationcount',
            limit: limit,
          ),
        );
      } else if (state?.isEmpty == false) {
        response = await radioBrowserApi!.getStationsByState(
          state: state!,
          parameters: InputParameters(
            hidebroken: true,
            order: 'stationcount',
            limit: limit,
          ),
        );
      }
      // TODO: display error in UI, add reload button for radio
      // if the service can not connect to any server for real
      if (response != null) {
        setStations(response.items);
      } else {
        setStations([]);
      }
    } on FormatException catch (_) {
      setStations([]);
    }
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
    if (radioBrowserApi == null) return;
    try {
      final response = await radioBrowserApi!.getTags(
        parameters: const InputParameters(
          hidebroken: true,
          limit: 100,
          order: 'stationcount',
          reverse: true,
        ),
      );
      _tags = response.items;
    } on FormatException catch (_) {}
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
