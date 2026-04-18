import 'dart:async';

import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../player/player_service.dart';

@singleton
class ConnectivityManager {
  ConnectivityManager({
    required PlayerService playerService,
    required InternetConnection internetConnection,
  }) : _playerService = playerService,
       _internetConnection = internetConnection {
    _internetConnectionSubscription ??= _internetConnection.onStatusChange
        .listen((status) {
          if (status == InternetStatus.disconnected &&
              _playerService.audio?.path == null) {
            _playerService.pause();
          }

          connectivityCommand.run((
            isOnline: status == InternetStatus.connected,
            wasOnline:
                _internetConnection.lastTryResults == InternetStatus.connected,
          ));
        });

    connectivityCommand.run((
      isOnline: true,
      wasOnline: _internetConnection.lastTryResults == InternetStatus.connected,
    ));
  }

  final PlayerService _playerService;
  final InternetConnection _internetConnection;
  StreamSubscription<InternetStatus>? _internetConnectionSubscription;

  late final Command<
    ({bool isOnline, bool wasOnline}),
    ({bool isOnline, bool wasOnline})
  >
  connectivityCommand = Command.createSync(
    (param) => (isOnline: param.isOnline, wasOnline: param.wasOnline),
    initialValue: (isOnline: true, wasOnline: true),
  );

  @disposeMethod
  Future<void> dispose() async {
    await _internetConnectionSubscription?.cancel();
  }
}
