import 'dart:async';

import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../common/data/audio.dart';
import '../l10n/app_localizations.dart';
import 'radio_service.dart';

@lazySingleton
class RadioManager {
  final RadioService _radioService;

  RadioManager({required RadioService radioService})
    : _radioService = radioService {
    connectCommand.run();
  }

  final _stationCache = <String, Audio>{};
  late final Command<void, String?> connectCommand = Command.createAsyncNoParam(
    () => _radioService.init(),
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
