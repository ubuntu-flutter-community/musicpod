import 'dart:async';

import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../common/data/audio.dart';
import '../common/data/mpv_meta_data.dart';
import '../l10n/app_localizations.dart';
import '../player/player_service.dart';
import 'radio_service.dart';

class RadioModel extends SafeChangeNotifier {
  final RadioService _radioService;
  final PlayerService _playerService;
  StreamSubscription<bool>? _propertiesChangedSub;

  RadioModel({
    required RadioService radioService,
    required PlayerService playerService,
  }) : _radioService = radioService,
       _playerService = playerService {
    _propertiesChangedSub ??= _radioService.propertiesChanged.listen(
      (_) => notifyListeners(),
    );
  }

  Future<void> clickStation(Audio? station) async {
    if (station?.uuid != null) {
      return _radioService.clickStation(station!.uuid!);
    }
  }

  String? get connectedHost => _radioService.connectedHost;

  Future<void> reconnect() async => _radioService.init();

  RadioCollectionView _radioCollectionView = RadioCollectionView.stations;
  RadioCollectionView get radioCollectionView => _radioCollectionView;
  void setRadioCollectionView(RadioCollectionView value) {
    if (value == _radioCollectionView) return;
    _radioCollectionView = value;
    notifyListeners();
  }

  MpvMetaData? get mpvMetaData => _radioService.mpvMetaData;

  void setDataSafeMode(bool value) => _radioService.setDataSafeMode(value);
  bool get dataSafeMode => _radioService.dataSafeMode;

  int getRadioHistoryLength({String? filter}) =>
      filteredRadioHistory(filter: filter).length;
  MpvMetaData? getMetadata(String? icyTitle) =>
      icyTitle == null ? null : _radioService.radioHistory[icyTitle];

  Iterable<MapEntry<String, MpvMetaData>> filteredRadioHistory({
    required String? filter,
  }) => _radioService.filteredRadioHistory(filter: filter);

  String getRadioHistoryList({String? filter}) =>
      _radioService.getRadioHistoryList(filter: filter);

  void setTimer(Duration duration) => _playerService.setPauseTimer(duration);

  @override
  Future<void> dispose() async {
    await _propertiesChangedSub?.cancel();
    super.dispose();
  }

  Future<Audio?> getStationByUUID(String pageId) async {
    final stationByUUID = await _radioService.getStationByUUID(pageId);

    if (stationByUUID == null) {
      return null;
    }

    return Audio.fromStation(stationByUUID);
  }

  Future<Audio?> getStationByUrl(String url) async {
    final stationByUrl = await _radioService.getStationByUrl(url);
    return stationByUrl != null ? Audio.fromStation(stationByUrl) : null;
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
