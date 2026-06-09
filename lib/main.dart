import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:system_theme/system_theme.dart';
import 'package:yaru/yaru.dart' show YaruWindowTitleBar;

import 'app/view/musicpod.dart';
import 'common/logging.dart';
import 'extensions/taget_platform_x.dart';

Future<void> main(List<String> args) async {
  if (isMobile) {
    WidgetsFlutterBinding.ensureInitialized();
  } else {
    await YaruWindowTitleBar.ensureInitialized();
  }

  FlutterError.onError = printFlutterErrorInDebugMode;

  Command.globalExceptionHandler =
      (CommandError<dynamic> error, StackTrace stackTrace) {
        printErrorInDebugMode(
          error.error,
          trace: stackTrace,
          tag: 'CommandError',
        );
      };

  if (isWindows) {
    await SystemTheme.accentColor.load();
  }

  runApp(const MusicPod());
}
