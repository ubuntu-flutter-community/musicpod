import 'package:flutter/material.dart';
import 'package:mpris_service/mpris_service.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import 'app/music_app.dart';

Future<void> main() async {
  // TODO: correct to snap desktop entry path after snapping
  final mpris = await MPRIS.create(
    busName: 'org.mpris.MediaPlayer2.music',
    identity: 'Music',
    desktopEntry: '/home/frederik/.local/share/applications/music',
  );

  registerService<MPRIS>(() => mpris);

  await YaruWindowTitleBar.ensureInitialized();
  runApp(const MusicApp());
}
