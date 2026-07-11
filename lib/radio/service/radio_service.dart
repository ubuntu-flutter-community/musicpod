import 'dart:async';
import 'dart:math';

import 'package:basic_utils/basic_utils.dart';
import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:radio_browser_api/radio_browser_api.dart';

import '../../common/data/audio.dart';
import '../../common/logging.dart';
import '../persistence/radio_dao.dart';
import '../data/radio_exceptions.dart';

@Injectable(cache: true)
class RadioService {
  RadioService({required RadioDao dao}) : _dao = dao {
    Logger.o(tag: '$RadioService');
  }

  final RadioDao _dao;

  static const _kRadioBrowserBaseUrl = 'all.api.radio-browser.info';

  RadioBrowserApi? _radioBrowserApi;

  Future<String?> connectToServer({List<String>? newHosts}) async {
    if (_radioBrowserApi?.host != null) {
      return _radioBrowserApi?.host;
    }

    final potentialHosts =
        newHosts ??
        await _findHosts().timeout(
          FindRadioBrowserHostsTimeoutException.timeoutDuration,
          onTimeout: () {
            throw FindRadioBrowserHostsTimeoutException();
          },
        );

    for (var host in potentialHosts) {
      try {
        _radioBrowserApi = RadioBrowserApi.fromHost(host);

        if (_radioBrowserApi?.host != null) {
          break;
        }
      } on Exception catch (e) {
        throw RadioBrowserServerUnavailableException(e.toString());
      }
    }

    if (_radioBrowserApi?.host == null) {
      _radioBrowserApi = null;
      throw RadioBrowserServerUnavailableException();
    }

    return _radioBrowserApi?.host;
  }

  Future<List<String>> _findHosts() async {
    final hosts = <String>[];
    try {
      final records = await DnsUtils.lookupRecord(
        _kRadioBrowserBaseUrl,
        RRecordType.A,
      );
      if (records == null || records.isEmpty) {
        return [];
      }

      for (RRecord record in records) {
        final reverse = await DnsUtils.reverseDns(record.data);
        for (RRecord r in reverse ?? <RRecord>[]) {
          hosts.add(r.data.replaceAll('info.', 'info'));
        }
      }
    } on Exception {
      throw LookUpRadioBrowserHostsException();
    }
    return hosts;
  }

  Future<Audio?> getAudioByUUID(
    String uuid, {
    bool tryFromDbFirst = true,
  }) async {
    if (tryFromDbFirst) {
      final station = await _dao.getStationByUuid(uuid);
      if (station != null) {
        Logger.i(
          'Station with uuid $uuid found in local database, returning it.',
          tag: '$RadioService',
        );
        return Audio.fromStation(station);
      }
    }

    if (await connectToServer() == null) {
      throw RadioBrowserApiNotConnectedException();
    }

    final response = await _radioBrowserApi?.getStationsByUUID(uuids: [uuid]);
    if (response?.items.isEmpty != false) {
      return null;
    }
    final station = response!.items.first;
    return Audio.fromStation(station);
  }

  Future<Audio?> getAudioByUrl(String url) async {
    if (await connectToServer() == null) {
      throw RadioBrowserApiNotConnectedException();
    }

    final response = await _radioBrowserApi?.getStationsByUrl(url: url);
    final station = response?.items.firstOrNull;

    if (station != null) {
      final audio = Audio.fromStation(station);
      await _dao.insertStarredStation(audio);
      return audio;
    }
    return null;
  }

  static const radioSearchMaxLimit = 300;

  Future<List<Audio>?> search({
    String? country,
    String? name,
    String? state,
    String? tag,
    String? language,
    required int limit,
  }) async {
    if (await connectToServer() == null) {
      throw RadioBrowserApiNotConnectedException();
    }

    RadioBrowserListResponse<Station>? _response;

    final parameters = InputParameters(
      hidebroken: true,
      order: 'stationcount',
      limit: limit > radioSearchMaxLimit ? radioSearchMaxLimit : limit,
    );

    if (name?.isEmpty == false) {
      _response = await _radioBrowserApi?.getStationsByName(
        name: name!,
        parameters: parameters,
      );
    } else if (country?.isEmpty == false) {
      _response = await _radioBrowserApi?.getStationsByCountry(
        country: country!,
        parameters: parameters,
      );
    } else if (tag?.isEmpty == false) {
      _response = await _radioBrowserApi?.getStationsByTag(
        tag: tag!,
        parameters: parameters,
      );
    } else if (state?.isEmpty == false) {
      _response = await _radioBrowserApi?.getStationsByState(
        state: state!,
        parameters: parameters,
      );
    } else if (language?.isEmpty == false) {
      _response = await _radioBrowserApi?.getStationsByLanguage(
        language: language!,
        parameters: parameters,
      );
    }
    return (_response?.items ?? []).map((e) => Audio.fromStation(e)).toList();
  }

  Future<List<Tag>> loadTags({String? filter, int? limit}) async {
    RadioBrowserListResponse<Tag> response;

    try {
      response = await _radioBrowserApi!
          .getTags(
            filter: filter,
            parameters: InputParameters(
              hidebroken: true,
              limit: limit ?? 5000,
              order: 'stationcount',
              reverse: true,
            ),
          )
          .timeout(
            LoadTagsTimeoutException.timeoutDuration,
            onTimeout: () {
              throw LoadTagsTimeoutException();
            },
          );
    } on Exception catch (e, s) {
      Logger.e(e, trace: s, tag: '$RadioService');
      throw LoadTagsFailedException(e.toString());
    }

    return response.items;
  }

  Future<void> clickStation(String? uuid) async {
    if (await connectToServer() == null) {
      throw RadioBrowserApiNotConnectedException();
    }
    try {
      if (uuid == null) {
        Logger.i('Cannot click station with null uuid.', tag: '$RadioService');
        return;
      }
      await _radioBrowserApi?.clickStation(uuid: uuid);
      Logger.i('Station clicked: $uuid', tag: '$RadioService');
    } on Exception catch (e, s) {
      Logger.e(e, trace: s, tag: '$RadioService');
    }
  }

  final noNumbers = RegExp(r'^[^0-9]+$');
  Future<Audio?> findSimilarStation(Audio audio) async {
    final searchTags = audio.tags?.where((e) => noNumbers.hasMatch(e));
    if (searchTags == null || searchTags.isEmpty) {
      return null;
    }
    Audio? maybe;
    int tries = audio.tags!.length;
    do {
      maybe =
          (await search(
                limit: 500,
                tag: searchTags.elementAt(Random().nextInt(searchTags.length)),
              ))
              ?.where(
                (e) => _areTagsSimilar(
                  stationTags: searchTags,
                  otherTags: (e.tags ?? []).where((e) => noNumbers.hasMatch(e)),
                ),
              )
              .lastWhereOrNull((e) => e.uuid != audio.uuid);

      tries--;
    } while (tries > 0 && (maybe == null || audio == maybe));

    return maybe;
  }

  bool _areTagsSimilar({
    required Iterable<String> stationTags,
    required Iterable<String> otherTags,
  }) {
    final matches = <String>{};
    for (var tag in stationTags.map((e) => e.toLowerCase().trim()).toList()) {
      if (otherTags.contains(tag.toLowerCase().trim())) {
        matches.add(tag);
      }
    }

    return switch (stationTags.length) {
      1 || 2 || 3 => matches.isNotEmpty,
      4 || 5 || 6 || 7 || 8 || 9 || 10 => matches.length >= 2,
      _ => matches.length >= 3,
    };
  }

  // ── Starred stations ──

  Future<Set<String>> getStarredStations() => _dao.getStarredStations();

  Future<bool> toggleStarredStation(Audio audio) async {
    if (audio.uuid == null) {
      Logger.i(
        'Cannot toggle starred station with null uuid.',
        tag: '$RadioService',
      );
      return false;
    }

    if (await getStarredStations().then(
      (uuids) => uuids.contains(audio.uuid!),
    )) {
      await _dao.deleteStarredStation(audio.uuid!);
      return false;
    } else {
      await _dao.insertStarredStation(audio);
      return true;
    }
  }

  // ── Fav radio tags ──

  Future<Set<String>> getFavRadioTags() => _dao.getFavRadioTags();

  Future<void> toggleFavRadioTag(String name) async {
    final favTags = await getFavRadioTags();
    if (favTags.contains(name)) {
      await _dao.deleteFavoriteRadioTag(name);
    } else {
      await _dao.insertFavoriteRadioTag(name);
    }
  }

  Future<void> wipeRadioLibrary() => _dao.deleteRadioTables();

  Future<bool> isStarredStation(String pageId) => _dao.isStationStarred(pageId);

  Future<void> addStarredStations(List<String> starredStations) =>
      _dao.insertStarredStations(starredStations);
}
