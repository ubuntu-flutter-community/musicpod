import 'dart:async';
import 'dart:io';

import 'package:basic_utils/basic_utils.dart';
import 'package:radio_browser_api/radio_browser_api.dart';

import '../../constants.dart';

class RadioService {
  RadioBrowserApi? _radioBrowserApi;

  Future<String?> init() async {
    if (_radioBrowserApi?.host != null) {
      return _radioBrowserApi?.host;
    }

    for (var host in (await _findHost())) {
      try {
        _radioBrowserApi ??= RadioBrowserApi.fromHost(host);
        if (_radioBrowserApi?.host != null) {
          return _radioBrowserApi?.host;
        }
      } on Exception catch (_) {
        return null;
      }
    }

    return null;
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

  Future<List<Station>?> getStations({
    String? country,
    String? name,
    String? state,
    String? tag,
    int limit = 100,
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
      }
    } on Exception catch (e) {
      if (e is SocketException) {
        return [];
      }
    }
    return response?.items ?? [];
  }

  List<Tag>? _tags;
  List<Tag>? get tags => _tags;
  Future<List<Tag>?> loadTags() async {
    if (_radioBrowserApi == null) return null;
    if (_tags?.isNotEmpty == true) return _tags;
    RadioBrowserListResponse<Tag>? response;

    try {
      response = await _radioBrowserApi!.getTags(
        parameters: const InputParameters(
          hidebroken: true,
          limit: 500,
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
    return _tags;
  }
}
