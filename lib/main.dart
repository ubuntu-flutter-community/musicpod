import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:flutter/material.dart';
import 'package:gtk/gtk.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import 'app.dart';
import 'external_path.dart';
import 'globals.dart';
import 'library.dart';
import 'local_audio.dart';
import 'notifications.dart';
import 'player.dart';
import 'podcasts.dart';
import 'radio.dart';

Future<void> main(List<String> args) async {
  if (!isMobile) {
    await YaruWindowTitleBar.ensureInitialized();
  }
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  final player = Player(
    configuration: const PlayerConfiguration(title: 'MusicPod'),
  );

  final controller = VideoController(player);

  final libraryService = LibraryService();

  final playerService = PlayerService(
    player: player,
    controller: controller,
    libraryService: libraryService,
  );
  await playerService.init();

  registerService<PlayerService>(
    () => playerService,
  );

  registerService<LibraryService>(
    () => libraryService,
    dispose: (s) async => await s.dispose(),
  );
  registerService<LocalAudioService>(
    LocalAudioService.new,
    dispose: (s) async => await s.dispose(),
  );

  final notificationsService =
      NotificationsService(Platform.isLinux ? NotificationsClient() : null);

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

  registerService<RadioService>(() => RadioService());

  if (Platform.isLinux) {
    runApp(const GtkApplication(child: YaruMusicPodApp()));
  } else {
    runApp(
      const MusicPodApp(),
    );
  }
}
