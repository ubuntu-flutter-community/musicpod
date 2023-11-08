// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:flutter/material.dart';
import 'package:gtk/gtk.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:mpris_service/mpris_service.dart';
import 'package:smtc_windows/smtc_windows.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import 'app.dart';
import 'constants.dart';
import 'external_path.dart';
import 'library.dart';
import 'local_audio.dart';
import 'media_control.dart';
import 'notifications.dart';
import 'podcasts.dart';
import 'radio.dart';

Future<void> main(List<String> args) async {
  if (!(Platform.isAndroid || Platform.isIOS || Platform.isFuchsia)) {
    await YaruWindowTitleBar.ensureInitialized();
  }
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  final libraryService = LibraryService();
  await libraryService.init();

  final player = Player(
    configuration: const PlayerConfiguration(title: 'MusicPod'),
  );
  registerService<Player>(
    () => player,
    dispose: (p) => p.dispose(),
  );

  registerService<VideoController>(() => VideoController(player));

  NotificationsClient? notificationsClient;

  // Media control
  SMTCWindows? smtc;
  MPRIS? mpris;
  if (Platform.isLinux) {
    notificationsClient = NotificationsClient();

    mpris = await MPRIS.create(
      busName: kBusName,
      identity: kAppName,
      desktopEntry: kDesktopEntry,
    );
  } else if (Platform.isWindows) {
    smtc = SMTCWindows(
      config: const SMTCConfig(
        fastForwardEnabled: false,
        nextEnabled: true,
        pauseEnabled: true,
        playEnabled: true,
        rewindEnabled: false,
        prevEnabled: true,
        stopEnabled: false,
      ),
    );
  }
  registerService<MediaControlService>(
    () => MediaControlService(
      mpris: mpris,
      smtc: smtc,
      initAudioHandler:
          Platform.isAndroid, // TODO: || Platform.isIOS || Platform.isMacOS
    ),
    dispose: (s) => s.dispose(),
  );

  registerService<LibraryService>(
    () => libraryService,
    dispose: (s) async => await s.dispose(),
  );
  registerService<LocalAudioService>(
    LocalAudioService.new,
    dispose: (s) async => await s.dispose(),
  );

  final notificationsService = NotificationsService(notificationsClient);
  registerService<NotificationsService>(
    () => notificationsService,
    dispose: (s) async => await s.dispose(),
  );
  registerService<PodcastService>(
    () => PodcastService(notificationsService),
    dispose: (s) async => await s.dispose(),
  );
  final connectivity = Connectivity();
  registerService<Connectivity>(
    () => connectivity,
  );

  registerService<ExternalPathService>(
    () => ExternalPathService(
      Platform.isLinux ? GtkApplicationNotifier(args) : null,
    ),
    dispose: (s) => s.dispose(),
  );

  registerService<RadioService>(() => RadioService(connectivity));

  runApp(
    MusicPod(
      yaruApp: Platform.isLinux,
    ),
  );
}
