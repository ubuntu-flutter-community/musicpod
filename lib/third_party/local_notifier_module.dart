import 'package:injectable/injectable.dart';
import 'package:local_notifier/local_notifier.dart';

import '../app/app_config.dart';
import '../extensions/taget_platform_x.dart';

@module
abstract class LocalNotifierModule {
  @preResolve
  Future<LocalNotifier> get create async {
    if (isDesktop) {
      await localNotifier.setup(
        appName: AppConfig.appId,
        shortcutPolicy: ShortcutPolicy.requireCreate,
      );
    }
    return localNotifier;
  }
}
