import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:gtk/gtk.dart';

import '../../common/view/error_page.dart';
import '../../dependencies.dart';
import '../../extensions/taget_platform_x.dart';
import '../../player/player_service.dart';
import 'app.dart';
import 'splash_screen.dart';

final ValueNotifier<UniqueKey> appRestartNotifier = ValueNotifier(UniqueKey());

class MusicPod extends StatefulWidget {
  const MusicPod({super.key});

  @override
  State<MusicPod> createState() => _MusicPodState();
}

class _MusicPodState extends State<MusicPod> {
  late final Future<void> _allReady;

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
                  onRetry: () => setState(() {
                    _allReady = configureDependencies();
                  }),
                  addQuitButton: true,
                ),
              )
            : snapshot.hasData
            ? isLinux
                  ? GtkApplication(
                      onCommandLine: (args) =>
                          di<PlayerService>().playPath(args.firstOrNull),
                      child: const YaruMusicPodApp(),
                    )
                  : const MaterialMusicPodApp()
            : const SplashScreen(),
      );
    },
  );
}
