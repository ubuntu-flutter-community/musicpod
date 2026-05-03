import 'dart:async';
import 'dart:math';

import 'package:basic_utils/basic_utils.dart';
import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:radio_browser_api/radio_browser_api.dart';

import '../common/data/audio.dart';
import '../common/logging.dart';
import '../common/persistence/database.dart';

@singleton
class RadioService {
  RadioService({required Database database}) : _db = database;

  final Database _db;

  final _propertiesChangedController = StreamController<bool>.broadcast();
  Stream<bool> get propertiesChanged => _propertiesChangedController.stream;

  void _notify() {
    if (_propertiesChangedController.hasListener) {
      _propertiesChangedController.add(true);
    }
  }

  @PostConstruct(preResolve: true)
  Future<void> initService() async {
    await _loadStarredStations();
    await _loadFavRadioTags();
    _notify();
  }

  @disposeMethod
  Future<void> dispose() => _propertiesChangedController.close();

  static const _kRadioBrowserBaseUrl = 'all.api.radio-browser.info';

  RadioBrowserApi? _radioBrowserApi;
  String? get connectedHost =>
      _tags == null || _tags!.isEmpty ? null : _radioBrowserApi?.host;

  Future<String?> initSearch() async {
    if (_radioBrowserApi?.host != null && _tags?.isNotEmpty == true) {
      return _radioBrowserApi?.host;
    }

    List<String>? hosts;
    try {
      hosts = await _findHosts().timeout(const Duration(seconds: 15));
    } on TimeoutException catch (_) {
      printMessageInDebugMode('Timeout while trying to find a host.');
      return null;
    } on Exception catch (e) {
      printMessageInDebugMode(e);
      return null;
    }
    for (var host in hosts) {
      try {
        _radioBrowserApi = RadioBrowserApi.fromHost(host);
        _tags = await _loadTags();
        if (_radioBrowserApi?.host != null && _tags?.isNotEmpty == true) {
          break;
        }
      } on Exception catch (e) {
        printMessageInDebugMode(e);
      }
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
      rethrow;
    }
    return hosts;
  }

  Future<Station?> getStationByUUID(String uuid) async {
    if (_radioBrowserApi == null) {
      await initSearch();
      if (connectedHost == null) {
        return null;
      }
    }

    try {
      final response = await _radioBrowserApi!.getStationsByUUID(uuids: [uuid]);
      if (response.items.isEmpty) {
        return null;
      }
      final station = response.items.first;
      return station;
    } on Exception catch (e) {
      printMessageInDebugMode(e);
    }

    return null;
  }

  Future<Station?> getStationByUrl(String url) async {
    if (_radioBrowserApi == null) {
      await initSearch();
      if (connectedHost == null) {
        return null;
      }
    }
    try {
      final response = await _radioBrowserApi!.getStationsByUrl(url: url);
      final station = response.items.firstOrNull;

      return station;
    } on Exception catch (e) {
      printMessageInDebugMode(e);
    }

    return null;
  }

  RadioBrowserListResponse<Station>? _response;
  String? _country;
  String? _name;
  String? _state;
  String? _tag;
  String? _language;
  int? _limit;
  Future<List<Station>?> search({
    String? country,
    String? name,
    String? state,
    String? tag,
    String? language,
    required int limit,
  }) async {
    if (_radioBrowserApi == null) {
      await initSearch();
      if (connectedHost == null) {
        return [];
      }
    }

    if (_response?.items != null &&
        _country == country &&
        _name == name &&
        _state == state &&
        _tag == tag &&
        _language == language &&
        _limit == limit) {
      return _response?.items;
    }

    final parameters = InputParameters(
      hidebroken: true,
      order: 'stationcount',
      limit: limit > 300 ? 300 : limit,
    );
    try {
      if (name?.isEmpty == false) {
        _response = await _radioBrowserApi!.getStationsByName(
          name: name!,
          parameters: parameters,
        );
      } else if (country?.isEmpty == false) {
        _response = await _radioBrowserApi!.getStationsByCountry(
          country: country!,
          parameters: parameters,
        );
      } else if (tag?.isEmpty == false) {
        _response = await _radioBrowserApi!.getStationsByTag(
          tag: tag!,
          parameters: parameters,
        );
      } else if (state?.isEmpty == false) {
        _response = await _radioBrowserApi!.getStationsByState(
          state: state!,
          parameters: parameters,
        );
      } else if (language?.isEmpty == false) {
        _response = await _radioBrowserApi!.getStationsByLanguage(
          language: language!,
          parameters: parameters,
        );
      }
    } on Exception catch (e) {
      printMessageInDebugMode(e);
    }

    _country = country;
    _name = name;
    _state = state;
    _tag = tag;
    _language = language;
    _limit = limit;

    return _response?.items ?? [];
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
          .timeout(const Duration(seconds: 3));
      _tags = response.items;
    } on TimeoutException catch (_) {
      printMessageInDebugMode(
        'Timeout while trying to load tags from ${_radioBrowserApi?.host}.',
      );
      return null;
    } on Exception catch (e) {
      printMessageInDebugMode(e);
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
      printMessageInDebugMode(e);
    }
  }

  Future<Audio?> findSimilarStation(Audio station) async {
    final Station? maybe = await _findSimilarStation(station);
    if (maybe != null) {
      return Audio.fromStation(maybe);
    }

    return null;
  }

  final noNumbers = RegExp(r'^[^0-9]+$');
  Future<Station?> _findSimilarStation(Audio audio) async {
    final searchTags = audio.tags?.where((e) => noNumbers.hasMatch(e));
    if (searchTags == null || searchTags.isEmpty) {
      return null;
    }
    Station? maybe;
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
                  otherTags: (Audio.fromStation(e).tags ?? []).where(
                    (e) => noNumbers.hasMatch(e),
                  ),
                ),
              )
              .lastWhereOrNull((e) => e.stationUUID != audio.uuid);

      tries--;
    } while (tries > 0 && (maybe == null || audio == Audio.fromStation(maybe)));

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

  Future<void> _loadStarredStations() async {
    final rows = await _db.select(_db.starredStationTable).get();
    _starredStations = rows.map((r) => r.uuid).toList();
  }

  void addStarredStation(String uuid) {
    if (_starredStations.contains(uuid)) return;
    _starredStations.add(uuid);
    _db
        .into(_db.starredStationTable)
        .insert(
          StarredStationTableCompanion.insert(uuid: uuid),
          mode: InsertMode.insertOrIgnore,
        )
        .then((_) => _notify());
  }

  void addStarredStations(List<String?> uuids) {
    if (uuids.isEmpty) return;
    final newUuids = uuids
        .whereType<String>()
        .where((uuid) => uuid.isNotEmpty && !_starredStations.contains(uuid))
        .toList();
    if (newUuids.isEmpty) return;
    _starredStations.addAll(newUuids);
    _db
        .batch((batch) {
          for (final uuid in newUuids) {
            batch.insert(
              _db.starredStationTable,
              StarredStationTableCompanion.insert(uuid: uuid),
              mode: InsertMode.insertOrIgnore,
            );
          }
        })
        .then((_) => _notify());
  }

  void removeStarredStation(String uuid) {
    if (!_starredStations.contains(uuid)) return;
    _starredStations.remove(uuid);
    (_db.delete(
      _db.starredStationTable,
    )..where((t) => t.uuid.equals(uuid))).go().then((_) => _notify());
  }

  void unStarAllStations() {
    if (_starredStations.isEmpty) return;
    _starredStations.clear();
    _db.delete(_db.starredStationTable).go().then((_) => _notify());
  }

  bool isStarredStation(String? uuid) => _starredStations.contains(uuid);

  // ── Fav radio tags ──

  Set<String> _favRadioTags = {};
  Set<String> get favRadioTags => _favRadioTags;
  bool isFavTag(String value) => _favRadioTags.contains(value);

  Future<void> _loadFavRadioTags() async {
    final rows = await _db.select(_db.favoriteRadioTagTable).get();
    _favRadioTags = rows.map((r) => r.name).toSet();
  }

  void addFavRadioTag(String name) {
    if (_favRadioTags.contains(name)) return;
    _favRadioTags.add(name);
    _db
        .into(_db.favoriteRadioTagTable)
        .insert(
          FavoriteRadioTagTableCompanion.insert(name: name),
          mode: InsertMode.insertOrIgnore,
        )
        .then((_) => _notify());
  }

  void removeFavRadioTag(String name) {
    if (!_favRadioTags.contains(name)) return;
    _favRadioTags.remove(name);
    (_db.delete(
      _db.favoriteRadioTagTable,
    )..where((t) => t.name.equals(name))).go().then((_) => _notify());
  }

  Future<void> wipeAndBuildRadioLibrary() async {
    await _wipeRadioLibrary();
    await initService();
  }

  Future<void> _wipeRadioLibrary() async {
    _favRadioTags.clear();
    _starredStations.clear();
    await Future.wait([
      _db.delete(_db.starredStationTable).go(),
      _db.delete(_db.favoriteRadioTagTable).go(),
    ]);
    _notify();
  }
}
