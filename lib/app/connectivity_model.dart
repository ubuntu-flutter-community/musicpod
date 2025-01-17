import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../common/data/audio_type.dart';
import '../player/player_service.dart';

class ConnectivityModel extends SafeChangeNotifier {
  ConnectivityModel({
    required PlayerService playerService,
    required Connectivity connectivity,
  })  : _connectivity = connectivity,
        _playerService = playerService;

  final PlayerService _playerService;
  final Connectivity _connectivity;
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

extension _ConnectivityX on Connectivity {
  bool isOnline(List<ConnectivityResult>? res) =>
      res?.contains(ConnectivityResult.ethernet) == true ||
      res?.contains(ConnectivityResult.bluetooth) == true ||
      res?.contains(ConnectivityResult.mobile) == true ||
      res?.contains(ConnectivityResult.vpn) == true ||
      res?.contains(ConnectivityResult.wifi) == true;
}
