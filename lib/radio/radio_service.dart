import 'dart:async';

import 'package:basic_utils/basic_utils.dart';
import 'package:radio_browser_api/radio_browser_api.dart';

import '../common/data/audio.dart';
import '../common/data/audio_type.dart';
import '../common/data/mpv_meta_data.dart';
import '../common/logging.dart';
import '../expose/expose_service.dart';
import '../extensions/string_x.dart';
import '../player/observe_property_io.dart';
import '../player/player_service.dart';
import 'online_art_service.dart';

class RadioService {
  RadioService({
    required PlayerService playerService,
    required OnlineArtService onlineArtService,
    required ExposeService exposeService,
  }) : _playerService = playerService,
       _onlineArtService = onlineArtService,
       _exposeService = exposeService;
  final PlayerService _playerService;
  final OnlineArtService _onlineArtService;
  final ExposeService _exposeService;

  static const _kRadioBrowserBaseUrl = 'all.api.radio-browser.info';

  RadioBrowserApi? _radioBrowserApi;
  final _propertiesChangedController = StreamController<bool>.broadcast();
  Stream<bool> get propertiesChanged => _propertiesChangedController.stream;
  String? get connectedHost =>
      _tags == null || _tags!.isEmpty ? null : _radioBrowserApi?.host;

  Future<void> init({bool observePlayer = true}) async {
    if (observePlayer) {
      await observeProperty(
        property: 'metadata',
        player: _playerService.player,
        listener: _onMpvMetadata,
      );
    }

    if (connectedHost != null && _tags?.isNotEmpty == true) {
      _propertiesChangedController.add(true);
      return;
    }

    List<String>? hosts;
    try {
      hosts = await _findHosts().timeout(const Duration(seconds: 5));
    } on TimeoutException catch (_) {
      printMessageInDebugMode('Timeout while trying to find a host.');
      return;
    } on Exception catch (e) {
      printMessageInDebugMode(e);
      return;
    }
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
    } on Exception catch (e) {
      printMessageInDebugMode(e);
    }
    return hosts;
  }

  final Map<String, Station> _cache = {};
  Future<Station?> getStationByUUID(String uuid) async {
    if (_cache.containsKey(uuid)) {
      return _cache[uuid];
    }

    if (_radioBrowserApi == null) {
      await init();
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
      _cache[uuid] = station;
      return station;
    } on Exception catch (e) {
      printMessageInDebugMode(e);
    }

    return null;
  }

  Future<Station?> getStationByUrl(String url) async {
    if (_radioBrowserApi == null) {
      await init();
      if (connectedHost == null) {
        return null;
      }
    }
    try {
      final response = await _radioBrowserApi!.getStationsByUrl(url: url);
      final station = response.items.firstOrNull;
      if (station != null) {
        _cache[station.stationUUID] = station;
      }
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
      await init();
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

  Future<void> clickStation(String uuid) async {
    try {
      await _radioBrowserApi?.clickStation(uuid: uuid);
      printMessageInDebugMode('Station clicked: $uuid');
    } on Exception catch (e) {
      printMessageInDebugMode(e);
    }
  }

  Future<void> dispose() async {
    await _propertiesChangedController.close();

    await observeProperty(property: 'metadata', player: _playerService.player);
  }

  //
  // Everything related to radio stream icy-title information observed from MPV and digested here
  //
  bool _dataSafeMode = false;
  bool get dataSafeMode => _dataSafeMode;
  void setDataSafeMode(bool value) {
    if (value == _dataSafeMode) return;
    _dataSafeMode = value;
    _propertiesChangedController.add(true);
  }

  Future<void> _onMpvMetadata(data) async {
    if (!data.contains('icy-title')) {
      return;
    }
    final newData = MpvMetaData.fromJson(data);
    final parsedIcyTitle = newData.icyTitle.unEscapeHtml;
    if (parsedIcyTitle == null || parsedIcyTitle == _mpvMetaData?.icyTitle) {
      return;
    }

    _setMpvMetaData(newData.copyWith(icyTitle: parsedIcyTitle));
  }

  MpvMetaData? _mpvMetaData;
  MpvMetaData? get mpvMetaData => _mpvMetaData;
  Future<void> _setMpvMetaData(MpvMetaData? value) async {
    _mpvMetaData = value;

    if (_isValidHistoryElement(_mpvMetaData)) {
      _addRadioHistoryElement(
        icyTitle: mpvMetaData!.icyTitle,
        mpvMetaData: mpvMetaData!.copyWith(
          icyName:
              _playerService.audio?.title?.trim() ??
              _mpvMetaData?.icyName ??
              '',
        ),
      );

      await _processParsedIcyTitle(mpvMetaData!.icyTitle);
    }
    _propertiesChangedController.add(true);
  }

  final _blockedIcyTitles = <String>{
    'Unknown',
    'Untitled',
    'No Title',
    'No Artist - No Title',
    ' - ',
    'Verbraucherinformation'
        'Werbung',
    'Advertisement',
  };

  bool _isValidHistoryElement(MpvMetaData? data) {
    final icyTitle = data?.icyTitle;
    if (icyTitle == null || icyTitle.isEmpty) {
      return false;
    }
    if (_blockedIcyTitles.contains(icyTitle)) {
      return false;
    }

    final icyDescription = data?.icyDescription;
    if (icyDescription == null || icyDescription.isEmpty) {
      return true;
    }

    final sanitizedDescription = icyDescription.replaceAll(
      RegExp(r'[^a-zA-Z0-9]'),
      '',
    );

    return !icyTitle.contains(icyDescription) &&
        !icyTitle.contains(sanitizedDescription);
  }

  Future<void> _processParsedIcyTitle(String parsedIcyTitle) async {
    final songInfo = parsedIcyTitle.splitByDash;
    String? albumArt;
    if (!_dataSafeMode) {
      albumArt = await _onlineArtService.fetchAlbumArt(parsedIcyTitle);
    }

    final mergedAudio =
        (_playerService.audio ?? const Audio(audioType: AudioType.radio))
            .copyWith(
              imageUrl: albumArt,
              title: songInfo.songName,
              artist: songInfo.artist,
            );
    await _playerService.setMediaControlsMetaData(audio: mergedAudio);
    _playerService.setRemoteImageUrl(
      albumArt ??
          _playerService.audio?.imageUrl ??
          _playerService.audio?.albumArtUrl,
    );

    await _exposeService.exposeTitleOnline(
      title: songInfo.songName ?? '',
      artist: songInfo.artist ?? '',
      additionalInfo: _playerService.audio?.title ?? 'Internet Radio',
      imageUrl: albumArt,
    );
  }

  final Map<String, MpvMetaData> _radioHistory = {};
  Map<String, MpvMetaData> get radioHistory => _radioHistory;
  void _addRadioHistoryElement({
    required String icyTitle,
    required MpvMetaData mpvMetaData,
  }) {
    _radioHistory.putIfAbsent(icyTitle, () => mpvMetaData);
  }

  int getRadioHistoryLength({String? filter}) =>
      filteredRadioHistory(filter: filter).length;

  String getRadioHistoryList({String? filter}) {
    return filteredRadioHistory(
      filter: filter,
    ).map((e) => '${e.value.icyTitle}\n').toList().reversed.join();
  }

  MpvMetaData? getMetadata(String? icyTitle) =>
      icyTitle == null ? null : radioHistory[icyTitle];

  Iterable<MapEntry<String, MpvMetaData>> filteredRadioHistory({
    required String? filter,
  }) {
    return radioHistory.entries.where(
      (e) => filter == null
          ? true
          : e.value.icyName.contains(filter) ||
                filter.contains(e.value.icyName),
    );
  }
}
