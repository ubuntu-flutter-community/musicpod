import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:mpris_service/mpris_service.dart';
import 'package:musicpod/app/common/constants.dart';
import 'package:musicpod/service/library_service.dart';
import 'package:musicpod/service/podcast_service.dart';
import 'package:musicpod/service/radio_service.dart';
import 'package:radio_browser_api/radio_browser_api.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import 'app/musicpod.dart';

Future<void> main() async {
  await YaruWindowTitleBar.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  MetadataGod.initialize();

  final mpris = await MPRIS.create(
    busName: 'org.mpris.MediaPlayer2.musicpod',
    identity: 'Musicpod',
    desktopEntry: '/var/lib/snapd/desktop/applications/musicpod',
  );

  registerService<MPRIS>(() => mpris);
  registerService<LibraryService>(LibraryService.new);
  registerService<PodcastService>(PodcastService.new);
  registerService<Connectivity>(Connectivity.new);
  registerService<NotificationsClient>(NotificationsClient.new);

  registerService<RadioService>(
    () => RadioService(
      const RadioBrowserApi.fromHost(kRadioUrl),
    ),
  );

  runApp(const MusicPod());
}
