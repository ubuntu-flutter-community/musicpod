import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:flutter/material.dart';
import 'package:github/github.dart';
import 'package:gtk/gtk.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_theme/system_theme.dart';
import 'package:watch_it/watch_it.dart';
import 'package:window_manager/window_manager.dart';
import 'package:yaru/yaru.dart';

import '../../external_path/external_path_service.dart';
import '../../library/library_model.dart';
import 'app/app_model.dart';
import 'app/connectivity_model.dart';
import 'app/view/app.dart';
import 'library/library_service.dart';
import 'local_audio/local_audio_model.dart';
import 'local_audio/local_audio_service.dart';
import 'notifications/notifications_service.dart';
import 'player/player_model.dart';
import 'player/player_service.dart';
import 'podcasts/download_model.dart';
import 'podcasts/podcast_model.dart';
import 'podcasts/podcast_service.dart';
import 'radio/radio_model.dart';
import 'radio/radio_service.dart';
import 'search/search_model.dart';
import 'settings/settings_model.dart';
import 'settings/settings_service.dart';

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
  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();
  final settingsService = SettingsService(
    sharedPreferences: sharedPreferences,
  );
  di.registerSingleton<SettingsService>(
    settingsService,
    dispose: (s) async => s.dispose(),
  );

  final libraryService = LibraryService(sharedPreferences: sharedPreferences);

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
    dispose: (s) async => s.dispose(),
  );

  di.registerSingleton<LibraryService>(
    libraryService,
    dispose: (s) async => s.dispose(),
  );
  final localAudioService = LocalAudioService(settingsService: settingsService);
  di.registerSingleton<LocalAudioService>(
    localAudioService,
    dispose: (s) async => s.dispose(),
  );

  final notificationsService =
      NotificationsService(Platform.isLinux ? NotificationsClient() : null);
  di.registerSingleton<NotificationsService>(
    notificationsService,
    dispose: (s) async => s.dispose(),
  );

  di.registerSingleton<PodcastService>(
    PodcastService(
      notificationsService: notificationsService,
      settingsService: settingsService,
    ),
  );

  final connectivity = Connectivity();
  di.registerSingleton<Connectivity>(
    connectivity,
  );
  final connectivityModel = ConnectivityModel(
    playerService: playerService,
    connectivity: connectivity,
  );
  di.registerSingleton<ConnectivityModel>(
    connectivityModel,
  );
  await connectivityModel.init();

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

  di.registerSingleton<PlayerModel>(
    PlayerModel(
      service: playerService,
      connectivity: connectivity,
    )..init(),
    dispose: (s) => s.dispose(),
  );

  final appModel = AppModel(
    gitHub: gitHub,
    settingsService: settingsService,
    allowManualUpdates: Platform.isLinux ? false : true,
  );
  await appModel.init();
  di.registerSingleton<AppModel>(
    appModel,
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
    RadioModel(radioService: radioService),
    dispose: (s) => s.dispose(),
  );
  di.registerSingleton<DownloadModel>(DownloadModel(libraryService));
  di.registerLazySingleton<SearchModel>(
    () => SearchModel(
      podcastService: di<PodcastService>(),
      radioService: di<RadioService>(),
      libraryService: di<LibraryService>(),
      localAudioService: di<LocalAudioService>(),
    )..init(),
  );

  runApp(
    Platform.isLinux
        ? const GtkApplication(child: YaruMusicPodApp())
        : const MaterialMusicPodApp(),
  );
}
