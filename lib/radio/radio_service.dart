import 'dart:async';
import 'dart:math';

import 'package:basic_utils/basic_utils.dart';
import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:radio_browser_api/radio_browser_api.dart';

import '../common/data/audio.dart';
import '../common/logging.dart';
import 'persistence/radio_dao.dart';

@singleton
class RadioService {
  RadioService({required RadioDao dao}) : _dao = dao;

  final RadioDao _dao;

  static const _kRadioBrowserBaseUrl = 'all.api.radio-browser.info';

  RadioBrowserApi? _radioBrowserApi;

  Future<String?> connectToServer({List<String>? newHosts}) async {
    if (_radioBrowserApi?.host != null && _tags?.isNotEmpty == true) {
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
        // Having the API set up is not enough
        // we need to make an actual request to check if the server is responsive
        // so since we need the tags anyways from this point on
        // we can just try to load them and if it works, we know the server is responsive and has the data we need
        _tags = await _loadTags();
        if (_radioBrowserApi?.host != null && _tags?.isNotEmpty == true) {
          break;
        }
      } on Exception catch (e) {
        throw RadioBrowserServerUnavailableException(e.toString());
      }
    }

    if (_radioBrowserApi?.host == null || _tags?.isEmpty != false) {
      _radioBrowserApi = null;
      _tags = null;
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
    // TODO: implement storing stations offline
    bool tryFromDbFirst = true,
  }) async {
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

    return station != null ? Audio.fromStation(station) : null;
  }

  static const radioSearchMaxLimit = 300;
  RadioBrowserListResponse<Station>? _response;
  String? _country;
  String? _name;
  String? _state;
  String? _tag;
  String? _language;
  int? _limit;
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

    if (_response?.items != null &&
        _country == country &&
        _name == name &&
        _state == state &&
        _tag == tag &&
        _language == language &&
        _limit == limit) {
      return _response?.items.map((e) => Audio.fromStation(e)).toList();
    }

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

    _country = country;
    _name = name;
    _state = state;
    _tag = tag;
    _language = language;
    _limit = limit;

    return (_response?.items ?? []).map((e) => Audio.fromStation(e)).toList();
  }

  List<Tag>? _tags;
  List<Tag>? get tags => _tags;
  Future<List<Tag>?>? _loadTags({String? filter, int? limit}) async {
    if (_radioBrowserApi == null) return null;
    if (_tags?.isNotEmpty == true) return _tags;
    RadioBrowserListResponse<Tag>? response;

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
      _tags = response.items;
    } on Exception catch (e) {
      throw LoadTagsFailedException(e.toString());
    }

    return _tags;
  }

  Future<void> clickStation(String? uuid) async {
    try {
      if (uuid == null) {
        printMessageInDebugMode('Cannot click station with null uuid.');
        return;
      }
      await _radioBrowserApi?.clickStation(uuid: uuid);
      printMessageInDebugMode('Station clicked: $uuid');
    } on Exception catch (e) {
      printMessageInDebugMode(e.toString());
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

  List<String> _starredStations = [];
  List<String> get starredStations => _starredStations;
  int get starredStationsLength => _starredStations.length;

  Future<void> loadStarredStations() async {
    _starredStations = await _dao.getStarredStations();
  }

  Future<void> addStarredStation(Audio audio) async {
    final uuid = audio.uuid;
    if (uuid == null || _starredStations.contains(uuid)) return;

    await _dao.insertStarredStation(uuid);
    _starredStations.add(uuid);
  }

  Future<void> addStarredStations(List<String?> uuids) async {
    if (uuids.isEmpty) return;
    final newUuids = uuids
        .whereType<String>()
        .where((uuid) => uuid.isNotEmpty && !_starredStations.contains(uuid))
        .toList();
    if (newUuids.isEmpty) return;
    _starredStations.addAll(newUuids);
    await _dao.insertStarredStations(newUuids);
  }

  Future<void> removeStarredStation(String uuid) async {
    if (!_starredStations.contains(uuid)) return;

    await _dao.deleteStarredStation(uuid);
    _starredStations.remove(uuid);
  }

  bool isStarredStation(String? uuid) => _starredStations.contains(uuid);

  // ── Fav radio tags ──

  Set<String> _favRadioTags = {};
  Set<String> get favRadioTags => _favRadioTags;
  bool isFavTag(String value) => _favRadioTags.contains(value);

  Future<void> loadFavRadioTags() async {
    _favRadioTags = await _dao.getFavRadioTags();
  }

  Future<void> addFavRadioTag(String name) async {
    if (_favRadioTags.contains(name)) return;
    _favRadioTags.add(name);
    await _dao.insertFavoriteRadioTag(name);
  }

  Future<void> removeFavRadioTag(String name) async {
    if (!_favRadioTags.contains(name)) return;
    _favRadioTags.remove(name);
    await _dao.deleteFavoriteRadioTag(name);
  }

  Future<void> wipeAndBuildRadioLibrary() async {
    await _wipeRadioLibrary();
    await loadStarredStations();
    await loadFavRadioTags();
  }

  Future<void> _wipeRadioLibrary() async {
    await _dao.deleteRadioTables();
    _favRadioTags.clear();
    _starredStations.clear();
  }
}

class FindRadioBrowserHostsTimeoutException implements Exception {
  static const Duration timeoutDuration = Duration(seconds: 15);

  FindRadioBrowserHostsTimeoutException();

  @override
  String toString() =>
      'Finding Radio Browser hosts takes longer than usual. Are you connected to the internet? If yes, this might be a server issue.';
}

class LookUpRadioBrowserHostsException implements Exception {
  LookUpRadioBrowserHostsException();

  @override
  String toString() =>
      'Can not lookup any Radio Browser hosts, are you connected to the internet?';
}

class RadioBrowserApiNotConnectedException implements Exception {
  final String? message;

  RadioBrowserApiNotConnectedException({this.message});

  @override
  String toString() => message ?? '$RadioBrowserApi not connected';
}

class RadioBrowserServerUnavailableException implements Exception {
  final String? message;

  RadioBrowserServerUnavailableException([this.message]);

  @override
  String toString() => message ?? 'RadioBrowser server is unavailable';
}

class FindStationTimeoutException implements Exception {
  FindStationTimeoutException();

  @override
  String toString() =>
      'Finding (this) station(s) takes longer than usual. Are you connected to the internet? If yes, this might be a server issue.';
}

class LoadTagsTimeoutException implements Exception {
  LoadTagsTimeoutException();

  static const Duration timeoutDuration = Duration(seconds: 15);

  @override
  String toString() =>
      'Loading radio tags takes longer than usual. Are you connected to the internet? If yes, this might be a server issue.';
}

class LoadTagsFailedException implements Exception {
  final String message;

  LoadTagsFailedException(this.message);

  @override
  String toString() =>
      'An error occurred while loading radio tags, the server might be unavailable: $message';
}
