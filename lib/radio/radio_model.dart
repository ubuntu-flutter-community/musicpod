import 'dart:async';

import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../common/data/audio.dart';
import '../l10n/app_localizations.dart';
import 'radio_service.dart';

@lazySingleton
class RadioManager extends SafeChangeNotifier {
  final RadioService _radioService;
  StreamSubscription<bool>? _propertiesChangedSub;

  RadioManager({required RadioService radioService})
    : _radioService = radioService {
    _propertiesChangedSub = _radioService.propertiesChanged.listen(
      (_) => notifyListeners(),
    );
    connectCommand.run();
  }

  @disposeMethod
  @override
  Future<void> dispose() async {
    await _propertiesChangedSub?.cancel();
    super.dispose();
  }

  final _stationCache = <String, Audio>{};
  late final Command<void, String?> connectCommand = Command.createAsyncNoParam(
    () => _radioService.initSearch(),
    initialValue: null,
  );

  final _getStationByUUIDCommands = <String, Command<void, Audio?>>{};
  Command<void, Audio?> getStationByUUIDCommand(String uuid) =>
      _getStationByUUIDCommands.putIfAbsent(
        uuid,
        () => Command.createAsyncNoParam(
          () => _getStationByUUID(uuid),
          initialValue: null,
        ),
      );

  Future<Audio?> _getStationByUUID(String pageId) async {
    if (_stationCache.containsKey(pageId)) {
      return _stationCache[pageId];
    }

    if (connectCommand.value == null) {
      await connectCommand.runAsync();
    }

    final stationByUUID = await _radioService.getStationByUUID(pageId);

    if (stationByUUID == null) {
      return null;
    }

    final audio = Audio.fromStation(stationByUUID);
    _stationCache[pageId] = audio;
    return audio;
  }

  Future<Audio?> getStationByUrl(String url) async {
    if (_stationCache.containsKey(url)) {
      return _stationCache[url];
    }
    final stationByUrl = await _radioService.getStationByUrl(url);
    if (stationByUrl == null) {
      return null;
    }
    final audio = Audio.fromStation(stationByUrl);
    _stationCache[url] = audio;
    return audio;
  }

  Future<void> clickStation(Audio? station) =>
      _radioService.clickStation(station?.uuid);

  final radioCollectionView = SafeValueNotifier<RadioCollectionView>(
    RadioCollectionView.stations,
  );
  void setRadioCollectionView(RadioCollectionView value) {
    if (value == radioCollectionView.value) return;
    radioCollectionView.value = value;
  }

  //
  // Starred stations
  //

  List<String> get starredStations => _radioService.starredStations;
  int get starredStationsLength => _radioService.starredStationsLength;
  void addStarredStation(String uuid) => _radioService.addStarredStation(uuid);
  void unStarStation(String uuid) => _radioService.removeStarredStation(uuid);
  void unStarAllStations() => _radioService.unStarAllStations();

  bool isStarredStation(String? uuid) =>
      uuid?.isNotEmpty == false ? false : _radioService.isStarredStation(uuid);

  //
  // Fav radio tags
  //

  void addFavRadioTag(String value) => _radioService.addFavRadioTag(value);
  void removeRadioFavTag(String value) =>
      _radioService.removeFavRadioTag(value);
  Set<String> get favRadioTags => _radioService.favRadioTags;
  int get favRadioTagsLength => _radioService.favRadioTags.length;
}

enum RadioCollectionView {
  stations,
  tags,
  history;

  String localize(AppLocalizations l10n) {
    return switch (this) {
      stations => l10n.stations,
      tags => l10n.tags,
      history => l10n.history,
    };
  }
}
