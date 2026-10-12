import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dependencies.dart';
import '../data/last_fm_credentials.dart';
import '../service/expose_service.dart';

part 'expose_manager.g.dart';

@Riverpod(keepAlive: true)
class ExposeManager extends _$ExposeManager {
  @override
  bool build() {
    final exposeService = di<ExposeService>();
    final notifier = exposeService.isLastFmAuthorized;
    void listener() => state = notifier.value;
    notifier.addListener(listener);
    ref.onDispose(() => notifier.removeListener(listener));
    return notifier.value;
  }

  bool get isLastFmAuthorized => state;

  Future<void> initListenBrains(String apiKey) =>
      di<ExposeService>().initListenBrains(apiKey);

  Future<void> authorizeLastFm(LastFmCredentials credentials) =>
      di<ExposeService>().authorizeLastFm(
        apiKey: credentials.apiKey,
        apiSecret: credentials.apiSecret,
      );
}
