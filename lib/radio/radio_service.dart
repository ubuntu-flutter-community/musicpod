import 'dart:async';

import 'package:basic_utils/basic_utils.dart';
import 'package:radio_browser_api/radio_browser_api.dart';

import '../constants.dart';

class RadioService {
  RadioBrowserApi? _radioBrowserApi;

  Future<String?> init() async {
    if (_radioBrowserApi?.host != null && _tags?.isNotEmpty == true) {
      return _radioBrowserApi?.host;
    }

    final hosts = await _findHosts();
    for (var host in hosts) {
      try {
        _radioBrowserApi = RadioBrowserApi.fromHost(host);
        _tags = await _loadTags();
        if (_radioBrowserApi?.host != null && _tags?.isNotEmpty == true) {
          return _radioBrowserApi?.host;
        }
      } on Exception catch (_) {}
    }

    return null;
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
    } on Exception catch (_) {}
    return hosts;
  }

  Future<List<Station>?> search({
    String? country,
    String? name,
    String? state,
    String? tag,
    String? language,
    required int limit,
  }) async {
    if (_radioBrowserApi == null) {
      return [];
    }

    RadioBrowserListResponse<Station>? response;
    final parameters = InputParameters(
      hidebroken: true,
      order: 'stationcount',
      limit: limit,
    );
    try {
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
    } on Exception catch (_) {}
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
    } on Exception catch (_) {}
    return _tags;
  }

  Future<void> clickStation(String uuid) async {
    try {
      await _radioBrowserApi?.clickStation(uuid: uuid);
    } on Exception catch (_) {}
  }
}
