import 'dart:async';
import 'dart:io';

import 'package:basic_utils/basic_utils.dart';
import 'package:radio_browser_api/radio_browser_api.dart';

import '../../constants.dart';

class RadioService {
  RadioBrowserApi? radioBrowserApi;

  RadioService();

  Future<bool> init() async {
    if (radioBrowserApi != null) return true;

    final hosts = await _findHost();

    if (hosts.isEmpty) {
      return false;
    }

    for (var host in hosts) {
      try {
        radioBrowserApi ??= RadioBrowserApi.fromHost(host);
        if (radioBrowserApi != null) {
          return true;
        }
      } on Exception catch (_) {}
    }

    return false;
  }

  Future<List<String>> _findHost() async {
    final hosts = <String>[];
    try {
      final records = await DnsUtils.lookupRecord(
        kRadioBrowserBaseUrl,
        RRecordType.A,
      );
      if (records?.isNotEmpty == false) {
        return [];
      }

      for (RRecord record in records ?? <RRecord>[]) {
        final reverse = await DnsUtils.reverseDns(record.data);
        for (RRecord r in reverse ?? <RRecord>[]) {
          hosts.add(r.data.replaceAll('info.', 'info'));
        }
      }
      return hosts;
    } on SocketException {
      return [];
    }
  }

  Future<void> dispose() async {
    _searchController.close();
    _tagsChangedController.close();
    _stationsChangedController.close();
    _statusCodeController.close();
  }

  String? _statusCode;
  String? get statusCode => _statusCode;
  void setStatusCode(String? value) {
    _statusCodeController.add(value != _statusCode);
    _statusCode = value;
  }

  final _statusCodeController = StreamController<bool>.broadcast();
  Stream<bool> get statusCodeChanged => _statusCodeController.stream;

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
    if (radioBrowserApi == null) {
      setStatusCode('503');
      setStations([]);
      return;
    }
    setStatusCode(null);

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
      if (response != null) {
        setStations(response.items);
        setStatusCode(response.statusCode.toString());
      }
    } on Exception catch (e) {
      if (e is SocketException) {
        setStations([]);
      }
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
          limit: 300,
          order: 'stationcount',
          reverse: true,
        ),
      );
      _tags = response.items;
    } on Exception catch (e) {
      if (e is SocketException) {
        _tags = [];
      }
    }
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
