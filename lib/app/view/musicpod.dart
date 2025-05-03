import 'package:flutter/material.dart';
import 'package:gtk/gtk.dart';
import 'package:watch_it/watch_it.dart';

import '../../extensions/taget_platform_x.dart';
import '../../player/player_service.dart';
import 'app.dart';
import 'splash_screen.dart';

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
    // Note: if this hangs, try
    // timeout: const Duration(seconds: 5),
    // ignorePendingAsyncCreation: true
    // to debug
    _allReady = di.allReady();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: _allReady,
        builder: (context, snapshot) => snapshot.hasData
            ? isLinux
                ? GtkApplication(
                    onCommandLine: (args) =>
                        di<PlayerService>().playPath(args.firstOrNull),
                    child: const YaruMusicPodApp(),
                  )
                : const MaterialMusicPodApp()
            : const SplashScreen(),
      );
}
