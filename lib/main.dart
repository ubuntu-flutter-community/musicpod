import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:flutter/material.dart';
import 'package:github/github.dart';
import 'package:gtk/gtk.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:system_theme/system_theme.dart';
import 'package:watch_it/watch_it.dart';
import 'package:window_manager/window_manager.dart';
import 'package:yaru/yaru.dart';

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
  // TODO: when the app is in appstore/windowsstore enable/disable this only via args
  final settingsService =
      SettingsService(allowManualUpdates: Platform.isLinux ? false : true);
  await settingsService.init();
  di.registerSingleton<SettingsService>(
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

  di.registerSingleton<PlayerService>(
    playerService,
    dispose: (s) async => await s.dispose(),
  );

  di.registerSingleton<LibraryService>(
    libraryService,
    dispose: (s) async => await s.dispose(),
  );
  final localAudioService = LocalAudioService(settingsService: settingsService);
  di.registerSingleton<LocalAudioService>(
    localAudioService,
    dispose: (s) async => await s.dispose(),
  );

  final notificationsService =
      NotificationsService(Platform.isLinux ? NotificationsClient() : null);
  di.registerSingleton<NotificationsService>(
    notificationsService,
    dispose: (s) async => await s.dispose(),
  );

  di.registerSingleton<PodcastService>(
    PodcastService(
      notificationsService: notificationsService,
      settingsService: settingsService,
    ),
    dispose: (s) async => await s.dispose(),
  );

  final connectivity = Connectivity();
  di.registerSingleton<Connectivity>(
    connectivity,
  );

  // For some reason GtkApplication needs to be instantiated
  // when the service is registered and not before
  di.registerLazySingleton<ExternalPathService>(
    () => ExternalPathService(
      gtkNotifier: Platform.isLinux ? GtkApplicationNotifier(args) : null,
      playerService: playerService,
    ),
    dispose: (s) => s.dispose(),
  );

  final radioService = RadioService();
  di.registerSingleton<RadioService>(radioService);

  final gitHub = GitHub();
  di.registerSingleton<GitHub>(gitHub);

  // Register ViewModels
  di.registerLazySingleton<SettingsModel>(
    () => SettingsModel(
      service: settingsService,
      externalPathService: di<ExternalPathService>(),
      gitHub: gitHub,
    )..init(),
    dispose: (s) => s.dispose(),
  );
  final playerModel = PlayerModel(
    service: playerService,
    connectivity: connectivity,
  );
  await playerModel.init();
  di.registerSingleton<PlayerModel>(
    playerModel,
    dispose: (s) => s.dispose(),
  );
  di.registerSingleton<AppModel>(
    AppModel(connectivity: connectivity),
    dispose: (s) => s.dispose(),
  );
  di.registerSingleton<LibraryModel>(
    LibraryModel(libraryService),
    dispose: (s) => s.dispose(),
  );
  di.registerSingleton<LocalAudioModel>(
    LocalAudioModel(localAudioService: localAudioService),
    dispose: (s) => s.dispose(),
  );
  di.registerSingleton<PodcastModel>(
    PodcastModel(
      libraryService: libraryService,
      podcastService: di.get<PodcastService>(),
    ),
    dispose: (s) => s.dispose(),
  );
  di.registerSingleton<RadioModel>(
    RadioModel(radioService: radioService, libraryService: libraryService),
    dispose: (s) => s.dispose(),
  );
  di.registerSingleton<DownloadModel>(DownloadModel(libraryService));

  runApp(
    Platform.isLinux
        ? const GtkApplication(child: YaruMusicPodApp())
        : const MaterialMusicPodApp(),
  );
}
