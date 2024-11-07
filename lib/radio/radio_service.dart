import 'dart:async';

import 'package:basic_utils/basic_utils.dart';
import 'package:radio_browser_api/radio_browser_api.dart';

import '../common/logging.dart';
import '../constants.dart';

class RadioService {
  RadioBrowserApi? _radioBrowserApi;
  final _propertiesChangedController = StreamController<bool>.broadcast();
  Stream<bool> get propertiesChanged => _propertiesChangedController.stream;
  String? get connectedHost => _radioBrowserApi?.host;

  Future<void> init() async {
    if (connectedHost != null && _tags?.isNotEmpty == true) {
      _propertiesChangedController.add(true);
      return;
    }

    final hosts = await _findHosts();
    for (var host in hosts) {
      try {
        _radioBrowserApi = RadioBrowserApi.fromHost(host);
        _tags = await _loadTags();
        if (connectedHost != null && _tags?.isNotEmpty == true) {
          _propertiesChangedController.add(true);
          return;
        }
      } on Exception catch (e) {
        printMessageInDebugMode(e);
      }
    }
  }

  Future<List<String>> _findHosts() async {
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
    } on Exception catch (e) {
      printMessageInDebugMode(e);
    }
    return hosts;
  }

  Future<List<Station>?> search({
    String? uuid,
    String? country,
    String? name,
    String? state,
    String? tag,
    String? language,
    required int limit,
  }) async {
    if (_radioBrowserApi == null) {
      await init();
      if (connectedHost == null) {
        return [];
      }
    }

    RadioBrowserListResponse<Station>? response;
    final parameters = InputParameters(
      hidebroken: true,
      order: 'stationcount',
      limit: limit,
    );
    try {
      if (uuid != null) {
        response = await _radioBrowserApi!.getStationsByUUID(uuids: [uuid]);
      }
      if (name?.isEmpty == false) {
        response = await _radioBrowserApi!
            .getStationsByName(name: name!, parameters: parameters);
      } else if (country?.isEmpty == false) {
        response = await _radioBrowserApi!
            .getStationsByCountry(country: country!, parameters: parameters);
      } else if (tag?.isEmpty == false) {
        response = await _radioBrowserApi!
            .getStationsByTag(tag: tag!, parameters: parameters);
      } else if (state?.isEmpty == false) {
        response = await _radioBrowserApi!
            .getStationsByState(state: state!, parameters: parameters);
      } else if (language?.isEmpty == false) {
        response = await _radioBrowserApi!
            .getStationsByLanguage(language: language!, parameters: parameters);
      }
    } on Exception catch (e) {
      printMessageInDebugMode(e);
    }
    return response?.items ?? [];
  }

  List<Tag>? _tags;
  List<Tag>? get tags => _tags;
  Future<List<Tag>?> _loadTags({
    String? filter,
    int? limit,
  }) async {
    if (_radioBrowserApi == null) return null;
    if (_tags?.isNotEmpty == true) return _tags;
    RadioBrowserListResponse<Tag>? response;

    try {
      response = await _radioBrowserApi!.getTags(
        filter: filter,
        parameters: InputParameters(
          hidebroken: true,
          limit: limit ?? 5000,
          order: 'stationcount',
          reverse: true,
        ),
      );
      _tags = response.items;
    } on Exception catch (e) {
      printMessageInDebugMode(e);
    }
    return _tags;
  }

  Future<void> clickStation(String uuid) async {
    try {
      await _radioBrowserApi?.clickStation(uuid: uuid);
      printMessageInDebugMode('Station clicked: $uuid');
    } on Exception catch (e) {
      printMessageInDebugMode(e);
    }
  }

  Future<void> dispose() async => _propertiesChangedController.close();
}
