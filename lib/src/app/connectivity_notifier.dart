import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class ConnectivityNotifier extends SafeChangeNotifier {
  ConnectivityNotifier(this._connectivity);

  final Connectivity _connectivity;
  StreamSubscription? _subscription;
  ConnectivityResult? _result;

  bool get isOnline => _result != ConnectivityResult.none;

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

  void _updateConnectivity(ConnectivityResult result) {
    if (_result == result) return;
    _result = result;
    notifyListeners();
  }
}
