import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gtk/gtk.dart';

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
  late final ProviderContainer _container = ProviderContainer();

  @override
  void initState() {
    super.initState();
    _allReady = configureDependencies().then((_) {
      if (!di.isRegistered<ProviderContainer>()) {
        di.registerSingleton<ProviderContainer>(_container);
      }
    });
  }

  @override
  void dispose() {
    _container.dispose();
    super.dispose();
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
            ? UncontrolledProviderScope(
                container: _container,
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
