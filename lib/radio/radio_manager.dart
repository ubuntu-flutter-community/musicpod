import 'dart:async';

import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../common/data/audio.dart';
import '../l10n/app_localizations.dart';
import 'radio_service.dart';

@singleton
class RadioManager extends SafeChangeNotifier {
  final RadioService _radioService;

  RadioManager({required RadioService radioService})
    : _radioService = radioService {
    connectCommand.run();
    toggleFavRadioTagCommand.run();
    toggleStarStationCommand.run();
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
          () => _getStationByUUID(uuid).timeout(const Duration(seconds: 10)),
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

  late final Command<String?, List<String>> toggleStarStationCommand =
      Command.createAsync((uuid) async {
        if (_radioService.starredStations.isEmpty) {
          await _radioService.loadStarredStations();
        }
        if (uuid != null) {
          if (_radioService.starredStations.contains(uuid)) {
            await _radioService.removeStarredStation(uuid);
          } else {
            await _radioService.addStarredStation(uuid);
          }
        }

        return _radioService.starredStations;
      }, initialValue: _radioService.starredStations);

  late final Command<void, void> wipeCommand =
      Command.createAsyncNoParamNoResult(() async {
        await _radioService.wipeAndBuildRadioLibrary();
        await toggleFavRadioTagCommand.runAsync();
        await toggleStarStationCommand.runAsync();
        _stationCache.clear();
      });

  //
  // Fav radio tags
  //

  late final Command<String?, Set<String>> toggleFavRadioTagCommand =
      Command.createAsync((tag) async {
        if (_radioService.favRadioTags.isEmpty) {
          await _radioService.loadFavRadioTags();
        }
        if (tag != null) {
          if (_radioService.favRadioTags.contains(tag)) {
            await _radioService.removeFavRadioTag(tag);
          } else {
            await _radioService.addFavRadioTag(tag);
          }
        }

        return _radioService.favRadioTags;
      }, initialValue: _radioService.favRadioTags);
}

enum RadioCollectionView {
  stations,
  tags,
  history,
  ignoredIcyTitles;

  String localize(AppLocalizations l10n) => switch (this) {
    stations => l10n.stations,
    tags => l10n.tags,
    history => l10n.history,
    ignoredIcyTitles => l10n.ignoredHearyHistoryTitlesTitle,
  };
}
