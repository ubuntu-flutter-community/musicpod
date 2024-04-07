import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

class AppModel extends SafeChangeNotifier {
  AppModel({required Connectivity connectivity})
      : _connectivity = connectivity,
        _countryCode = WidgetsBinding
            .instance.platformDispatcher.locale.countryCode
            ?.toLowerCase();

  final String? _countryCode;
  String? get countryCode => _countryCode;

  final Connectivity _connectivity;
  StreamSubscription? _subscription;
  ConnectivityResult? _result;

  bool get isOnline =>
      _result == ConnectivityResult.wifi ||
      _result == ConnectivityResult.ethernet ||
      _result == ConnectivityResult.vpn ||
      _result == ConnectivityResult.bluetooth ||
      _result == ConnectivityResult.mobile;

  Future<void> init() async {
    _subscription ??=
        _connectivity.onConnectivityChanged.listen(_updateConnectivity);
    return _connectivity.checkConnectivity().then(_updateConnectivity);
  }

  @override
  Future<void> dispose() async {
    await _subscription?.cancel();
    super.dispose();
  }

  void _updateConnectivity(List<ConnectivityResult> result) {
    if (_result == result.firstOrNull) return;
    _result = result.firstOrNull;
    notifyListeners();
  }

  bool _showWindowControls = true;
  bool get showWindowControls => _showWindowControls;
  void setShowWindowControls(bool value) {
    _showWindowControls = value;
    notifyListeners();
  }

  bool? _fullScreen;
  bool? get fullScreen => _fullScreen;
  void setFullScreen(bool? value) {
    if (value == null || value == _fullScreen) return;
    _fullScreen = value;
    notifyListeners();
  }

  bool _lockSpace = false;
  bool get lockSpace => _lockSpace;
  void setLockSpace(bool value) {
    _lockSpace = value;
    notifyListeners();
  }
}

final appModelProvider = ChangeNotifierProvider(
  (ref) => AppModel(connectivity: getService<Connectivity>()),
);
