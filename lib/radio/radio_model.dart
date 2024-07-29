import 'dart:async';

import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../common/data/audio.dart';
import '../l10n/l10n.dart';
import 'radio_service.dart';

class RadioModel extends SafeChangeNotifier {
  final RadioService _radioService;

  RadioModel({
    required RadioService radioService,
  }) : _radioService = radioService;

  Future<void> clickStation(Audio? station) async {
    if (station?.description != null) {
      return _radioService.clickStation(station!.description!);
    }
  }

  bool showConnectSnackBar = true;
  // The empty string is used so before the first check the UI does not overreact
  String? _connectedHost = '';
  String? get connectedHost => _connectedHost;
  Future<String?> init() async {
    final oldHost = _connectedHost;
    _connectedHost = await _radioService.init();
    if (oldHost == _connectedHost) {
      showConnectSnackBar = false;
    }
    notifyListeners();
    return _connectedHost;
  }

  RadioCollectionView _radioCollectionView = RadioCollectionView.stations;
  RadioCollectionView get radioCollectionView => _radioCollectionView;
  void setRadioCollectionView(RadioCollectionView value) {
    if (value == _radioCollectionView) return;
    _radioCollectionView = value;
    notifyListeners();
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
