import 'dart:async';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../player/player_service.dart';

class ConnectivityModel extends SafeChangeNotifier {
  ConnectivityModel({
    required PlayerService playerService,
    required InternetConnection internetConnection,
  }) : _playerService = playerService,
       _internetConnection = internetConnection;

  final PlayerService _playerService;
  final InternetConnection _internetConnection;
  StreamSubscription<InternetStatus>? _internetConnectionSubscription;

  InternetStatus? _internetStatus;
  bool get isOnline => _internetStatus == InternetStatus.connected;

  Future<void> init() async {
    _internetConnectionSubscription ??= _internetConnection.onStatusChange
        .listen((status) {
          if (status == InternetStatus.disconnected &&
              _playerService.audio!.path == null) {
            _playerService.pause();
          }
          _internetStatus = status;
          notifyListeners();
        });

    return _internetConnection.internetStatus.then((status) {
      _internetStatus = status;
      notifyListeners();
    });
  }

  @override
  Future<void> dispose() async {
    await _internetConnectionSubscription?.cancel();
    super.dispose();
  }
}
