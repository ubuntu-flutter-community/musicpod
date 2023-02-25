import 'package:flutter/material.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import 'app/music_app.dart';

Future<void> main() async {
  await YaruWindowTitleBar.ensureInitialized();
  runApp(const MusicApp());
}
