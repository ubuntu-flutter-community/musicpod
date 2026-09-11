import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../../common/util/family.dart';
import '../../extensions/command_x.dart';
import '../data/last_fm_credentials.dart';
import '../service/expose_service.dart';

@injectable
class ExposeManager {
  ExposeManager._({required ExposeService exposeService})
    : _exposeService = exposeService;

  @factoryMethod
  static ExposeManager create({required ExposeService exposeService}) =>
      Family.of(
        '$ExposeManager',
        () => ExposeManager._(exposeService: exposeService),
        shouldDispose: (m) =>
            m.initListenBrainsCommand.safeToDispose &&
            m.authorizeLastFmCommand.safeToDispose,
        onDispose: (m) {
          m.initListenBrainsCommand.dispose();
          m.authorizeLastFmCommand.dispose();
        },
      );

  final ExposeService _exposeService;

  late final Command<String, void> initListenBrainsCommand =
      Command.createAsyncNoResult(
        (apiKey) => _exposeService.initListenBrains(apiKey),
      );

  SafeValueNotifier<bool> get isLastFmAuthorized =>
      _exposeService.isLastFmAuthorized;

  late final Command<LastFmCredentials, void> authorizeLastFmCommand =
      Command.createAsyncNoResult(
        (credentials) => _exposeService.authorizeLastFm(
          apiKey: credentials.apiKey,
          apiSecret: credentials.apiSecret,
        ),
      );
}
