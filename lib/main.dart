import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:flutter/material.dart';
import 'package:github/github.dart';
import 'package:gtk/gtk.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:system_theme/system_theme.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:window_manager/window_manager.dart';
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
import 'src/settings/settings_service.dart';

Future<void> main(List<String> args) async {
  if (!isMobile) {
    await YaruWindowTitleBar.ensureInitialized();
    if (!Platform.isLinux) {
      await windowManager.ensureInitialized();
      WindowManager.instance.setMinimumSize(const Size(500, 700));
    }
  }
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  if (!Platform.isLinux) {
    SystemTheme.fallbackColor = Colors.greenAccent;
    await SystemTheme.accentColor.load();
  }

  final libraryService = LibraryService();

  final playerService = PlayerService(
    controller: VideoController(
      Player(
        configuration: const PlayerConfiguration(title: 'MusicPod'),
      ),
    ),
    libraryService: libraryService,
  );
  await playerService.init();

  registerService<PlayerService>(
    () => playerService,
  );

  final appStateService = AppStateService();
  await appStateService.init();
  registerService<AppStateService>(
    () => appStateService,
    dispose: (s) => appStateService.dispose(),
  );

  registerService<LibraryService>(
    () => libraryService,
    dispose: (s) async => await s.dispose(),
  );

  final settingsService = SettingsService();
  await settingsService.init();
  registerService<SettingsService>(() => settingsService);

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

  registerService(GitHub.new);

  if (Platform.isLinux) {
    runApp(const GtkApplication(child: YaruMusicPodApp()));
  } else {
    runApp(const MaterialMusicPodApp());
  }
}
