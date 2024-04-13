import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:flutter/material.dart';
import 'package:github/github.dart';
import 'package:gtk/gtk.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';
import 'package:yaru/yaru.dart';

import '../../get.dart';
import 'app.dart';
import 'external_path.dart';
import 'library.dart';
import 'local_audio.dart';
import 'notifications.dart';
import 'player.dart';
import 'podcasts.dart';
import 'radio.dart';
import 'settings.dart';

Future<void> main(List<String> args) async {
  if (!isMobile) {
    await YaruWindowTitleBar.ensureInitialized();
    if (!Platform.isLinux) {
      await windowManager.ensureInitialized();
      WindowManager.instance.setMinimumSize(const Size(500, 700));
      WindowManager.instance.setSize(const Size(950, 820));
    }
  } else {
    WidgetsFlutterBinding.ensureInitialized();
  }

  MediaKit.ensureInitialized();

  if (!Platform.isLinux) {
    SystemTheme.fallbackColor = Colors.greenAccent;
    await SystemTheme.accentColor.load();
  }

  // Register services
  final settingsService = SettingsService();
  await settingsService.init();
  getIt.registerSingleton<SettingsService>(
    settingsService,
    dispose: (s) async => await s.dispose(),
  );

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

  getIt.registerSingleton<PlayerService>(
    playerService,
    dispose: (s) async => await s.dispose(),
  );

  getIt.registerSingleton<LibraryService>(
    libraryService,
    dispose: (s) async => await s.dispose(),
  );
  final localAudioService = LocalAudioService(settingsService: settingsService);
  getIt.registerSingleton<LocalAudioService>(
    localAudioService,
    dispose: (s) async => await s.dispose(),
  );

  final notificationsService =
      NotificationsService(Platform.isLinux ? NotificationsClient() : null);
  getIt.registerSingleton<NotificationsService>(
    notificationsService,
    dispose: (s) async => await s.dispose(),
  );

  getIt.registerSingleton<PodcastService>(
    PodcastService(
      notificationsService: notificationsService,
      settingsService: settingsService,
    ),
    dispose: (s) async => await s.dispose(),
  );

  final connectivity = Connectivity();
  getIt.registerSingleton<Connectivity>(
    connectivity,
  );

  final externalPathService = ExternalPathService(
    gtkNotifier: Platform.isLinux ? GtkApplicationNotifier(args) : null,
    playerService: playerService,
  );
  getIt.registerSingleton<ExternalPathService>(
    externalPathService,
    dispose: (s) => s.dispose(),
  );

  final radioService = RadioService();
  getIt.registerSingleton<RadioService>(radioService);

  final gitHub = GitHub();
  getIt.registerSingleton<GitHub>(gitHub);

  // Register ViewModels
  getIt.registerSingleton<SettingsModel>(
    SettingsModel(
      service: settingsService,
      externalPathService: externalPathService,
      gitHub: gitHub,
    )..init(),
    dispose: (s) => s.dispose(),
  );
  getIt.registerSingleton<PlayerModel>(
    PlayerModel(service: playerService)..init(),
    dispose: (s) => s.dispose(),
  );
  getIt.registerSingleton<AppModel>(
    AppModel(connectivity: connectivity),
    dispose: (s) => s.dispose(),
  );
  getIt.registerSingleton<LibraryModel>(
    LibraryModel(libraryService),
    dispose: (s) => s.dispose(),
  );
  getIt.registerSingleton<LocalAudioModel>(
    LocalAudioModel(localAudioService: localAudioService),
    dispose: (s) => s.dispose(),
  );
  getIt.registerSingleton<PodcastModel>(
    PodcastModel(
      libraryService: libraryService,
      podcastService: getIt.get<PodcastService>(),
    ),
    dispose: (s) => s.dispose(),
  );
  getIt.registerSingleton<RadioModel>(
    RadioModel(radioService: radioService, libraryService: libraryService),
    dispose: (s) => s.dispose(),
  );
  getIt.registerSingleton<DownloadModel>(
    DownloadModel(libraryService),
    dispose: (s) => s.dispose(),
  );

  runApp(
    Platform.isLinux
        ? const GtkApplication(child: YaruMusicPodApp())
        : const MaterialMusicPodApp(),
  );
}
