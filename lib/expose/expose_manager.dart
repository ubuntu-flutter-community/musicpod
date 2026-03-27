import 'package:flutter/foundation.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import 'data/last_fm_credentials.dart';
import 'expose_service.dart';

@lazySingleton
class ExposeManager {
  ExposeManager({required ExposeService exposeService})
    : _exposeService = exposeService;

  final ExposeService _exposeService;

  late final Command<String, void> initListenBrainsCommand =
      Command.createAsyncNoResult(
        (apiKey) => _exposeService.initListenBrains(apiKey),
      );

  ValueNotifier<bool> get isLastFmAuthorized =>
      _exposeService.isLastFmAuthorized;

  late final Command<LastFmCredentials, void> authorizeLastFmCommand =
      Command.createAsyncNoResult(
        (credentials) => _exposeService.authorizeLastFm(
          apiKey: credentials.apiKey,
          apiSecret: credentials.apiSecret,
        ),
      );
}
