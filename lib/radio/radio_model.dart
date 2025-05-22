import 'dart:async';

import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../common/data/audio.dart';
import '../l10n/app_localizations.dart';
import 'radio_service.dart';

class RadioModel extends SafeChangeNotifier {
  final RadioService _radioService;
  StreamSubscription<bool>? _propertiesChangedSub;

  RadioModel({required RadioService radioService})
    : _radioService = radioService {
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
