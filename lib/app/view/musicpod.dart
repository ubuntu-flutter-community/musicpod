import 'package:flutter/material.dart';
import 'package:gtk/gtk.dart';
import 'package:watch_it/watch_it.dart';

import '../../app_config.dart';
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
    _allReady = di.allReady();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: _allReady,
        builder: (context, snapshot) => snapshot.hasData
            ? AppConfig.isGtkApp
                ? const GtkApplication(child: YaruMusicPodApp())
                : const MaterialMusicPodApp()
            : const SplashScreen(),
      );
}
