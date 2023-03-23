import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:mpris_service/mpris_service.dart';
import 'package:musicpod/service/podcast_service.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import 'app/music_app.dart';

Future<void> main() async {
  final mpris = await MPRIS.create(
    busName: 'org.mpris.MediaPlayer2.musicpod',
    identity: 'Musicpod',
    desktopEntry: '/var/lib/snapd/desktop/applications/musicpod',
  );

  registerService<MPRIS>(() => mpris);
  registerService<PodcastService>(PodcastService.new);
  registerService<Connectivity>(Connectivity.new);

  await YaruWindowTitleBar.ensureInitialized();
  runApp(const MusicApp());
}
