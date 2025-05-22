import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:watch_it/watch_it.dart';

import '../common/data/audio_type.dart';
import '../common/view/snackbars.dart';
import '../extensions/connectivity_x.dart';
import '../l10n/l10n.dart';
import '../player/player_model.dart';
import '../player/player_service.dart';
import '../settings/settings_model.dart';

class ConnectivityModel extends SafeChangeNotifier {
  ConnectivityModel({
    required PlayerService playerService,
    required Connectivity connectivity,
  }) : _connectivity = connectivity,
       _playerService = playerService;

  final PlayerService _playerService;
  final Connectivity _connectivity;
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  Future<void> init() async {
    // TODO: fix https://github.com/fluttercommunity/plus_plugins/issues/1451
    final fallback = [ConnectivityResult.wifi];

    _connectivitySubscription ??= _connectivity.onConnectivityChanged.listen(
      _updateConnectivity,
      onError: (e) => _result = fallback,
    );

    return _connectivity
        .checkConnectivity()
        .then(_updateConnectivity)
        .catchError((_) => _updateConnectivity(fallback));
  }

  bool get isOnline => _connectivity.isOnline(_result);

  bool get isMaybeLowBandWidth => _connectivity.isNotWifiNorEthernet(_result);

  List<ConnectivityResult>? get result => _result;
  List<ConnectivityResult>? _result;
  void _updateConnectivity(List<ConnectivityResult> newResult) {
    if (!_connectivity.isOnline(newResult) &&
        _playerService.audio?.audioType == AudioType.radio) {
      _playerService.pause();
    }
    _result = newResult;
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    super.dispose();
  }
}

void onConnectivityChangedHandler(
  BuildContext context,
  AsyncSnapshot<List<ConnectivityResult>?> res,
  void Function() cancel,
) {
  final l10n = context.l10n;
  final dataSafeMode = di<PlayerModel>().dataSafeMode;
  final notifyDataSafeMode = di<SettingsModel>().notifyDataSafeMode;
  if (!res.hasData || !context.mounted || !notifyDataSafeMode) {
    return;
  }

  if (!dataSafeMode && di<Connectivity>().isNotWifiNorEthernet(res.data)) {
    di<PlayerModel>().setDataSafeMode(true);
    showSnackBar(context: context, content: Text(l10n.dataSafeModeEnabled));
  } else if (dataSafeMode &&
      !di<Connectivity>().isNotWifiNorEthernet(res.data)) {
    di<PlayerModel>().setDataSafeMode(false);
    showSnackBar(context: context, content: Text(l10n.dataSafeModeDisabled));
  }
}
