import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gtk/gtk.dart';

import '../../common/logging.dart';
import '../../common/view/error_page.dart';
import '../../dependencies.dart';
import '../../extensions/platform_x.dart';
import '../../player/service/player_service.dart';
import 'app.dart';
import 'splash_screen.dart';

final ValueNotifier<UniqueKey> appRestartNotifier = ValueNotifier(UniqueKey());

class MusicPod extends StatefulWidget {
  const MusicPod({super.key});

  @override
  State<MusicPod> createState() => _MusicPodState();
}

class _MusicPodState extends State<MusicPod> {
  late Future<void> _allReady;

  @override
  void initState() {
    super.initState();
    _allReady = configureDependencies();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: appRestartNotifier,
    builder: (context, value, child) {
      return FutureBuilder(
        future: _allReady,
        builder: (context, snapshot) => snapshot.hasError
            ? SplashScreen(
                body: ErrorBody(
                  error: snapshot.error,
                  stackTrace: snapshot.stackTrace,
                  addQuitButton: true,
                ),
              )
            : (snapshot.hasData ||
                  snapshot.connectionState == ConnectionState.done)
            ? ProviderScope(
                observers: const [_MusicPodRiverpodObserver()],
                child: isLinux
                    ? GtkApplication(
                        onCommandLine: (args) =>
                            di<PlayerService>().playPath(args.firstOrNull),
                        child: const YaruMusicPodApp(),
                      )
                    : const MaterialMusicPodApp(),
              )
            : const SplashScreen(),
      );
    },
  );
}

final class _MusicPodRiverpodObserver extends ProviderObserver {
  const _MusicPodRiverpodObserver();

  @override
  void didAddProvider(ProviderObserverContext context, Object? value) {
    Logger.o(
      tag: context.provider.name ?? '${context.provider.runtimeType}',
      created: true,
    );
  }

  @override
  void didDisposeProvider(ProviderObserverContext context) {
    Logger.o(
      tag: context.provider.name ?? '${context.provider.runtimeType}',
      created: false,
    );
  }

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    Logger.e(
      error,
      trace: stackTrace,
      tag: context.provider.name ?? '${context.provider.runtimeType}',
    );
  }
}
