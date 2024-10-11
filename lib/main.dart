import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:github/github.dart';
import 'package:gtk/gtk.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
import 'constants.dart';
import 'library/library_service.dart';
import 'local_audio/local_audio_model.dart';
import 'local_audio/local_audio_service.dart';
import 'notifications/notifications_service.dart';
import 'player/player_model.dart';
import 'player/player_service.dart';
import 'podcasts/download_model.dart';
import 'podcasts/podcast_model.dart';
import 'podcasts/podcast_service.dart';
import 'radio/online_art_model.dart';
import 'radio/online_art_service.dart';
import 'radio/radio_model.dart';
import 'radio/radio_service.dart';
import 'search/search_model.dart';
import 'settings/settings_model.dart';
import 'settings/settings_service.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!isMobile) {
    await YaruWindowTitleBar.ensureInitialized();
    WindowManager.instance
      ..setMinimumSize(const Size(500, 700))
      ..setSize(const Size(950, 820));
    if (!Platform.isLinux) {
      SystemTheme.fallbackColor = const Color(0xFFed3c63);
      await SystemTheme.accentColor.load();
    }
  }

  MediaKit.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();
  final version = (await PackageInfo.fromPlatform()).version;

  registerServicesAndViewModels(
    sharedPreferences: sharedPreferences,
    args: args,
    version: version,
  );

  runApp(
    Platform.isLinux
        ? const GtkApplication(child: YaruMusicPodApp())
        : const MaterialMusicPodApp(),
  );
}

void registerServicesAndViewModels({
  required SharedPreferences sharedPreferences,
  required List<String> args,
  required String version,
}) {
  di
    ..registerLazySingleton<SharedPreferences>(() => sharedPreferences)
    ..registerLazySingleton<Dio>(
      () => Dio(),
      dispose: (s) => s.close(),
    )
    ..registerLazySingleton<OnlineArtService>(
      () => OnlineArtService(
        dio: di<Dio>(),
      ),
      dispose: (s) => s.dispose(),
    )
    ..registerLazySingleton<PlayerService>(
      () => PlayerService(
        onlineArtService: di<OnlineArtService>(),
        controller: VideoController(
          Player(
            configuration: const PlayerConfiguration(title: kAppTitle),
          ),
        ),
      )..init(),
      dispose: (s) async => s.dispose(),
    )
    ..registerLazySingleton<SettingsService>(
      () => SettingsService(sharedPreferences: di<SharedPreferences>()),
      dispose: (s) async => s.dispose(),
    )
    ..registerLazySingleton<LibraryService>(
      () => LibraryService(sharedPreferences: di<SharedPreferences>()),
      dispose: (s) async => s.dispose(),
    )
    ..registerLazySingleton<LocalAudioService>(
      () => LocalAudioService(settingsService: di<SettingsService>()),
      dispose: (s) async => s.dispose(),
    )
    ..registerLazySingleton<NotificationsService>(
      () =>
          NotificationsService(Platform.isLinux ? NotificationsClient() : null),
      dispose: (s) async => s.dispose(),
    )
    ..registerLazySingleton<PodcastService>(
      () => PodcastService(
        notificationsService: di<NotificationsService>(),
        settingsService: di<SettingsService>(),
        libraryService: di<LibraryService>(),
      ),
    )
    ..registerLazySingleton<Connectivity>(() => Connectivity())
    ..registerLazySingleton<ExternalPathService>(
      () => ExternalPathService(
        gtkNotifier: Platform.isLinux ? GtkApplicationNotifier(args) : null,
        playerService: di<PlayerService>(),
      ),
      dispose: (s) => s.dispose(),
    )
    ..registerLazySingleton<RadioService>(() => RadioService())
    ..registerLazySingleton<GitHub>(() => GitHub())
    ..registerLazySingleton<ConnectivityModel>(
      () => ConnectivityModel(
        playerService: di<PlayerService>(),
        connectivity: di<Connectivity>(),
      ),
    )
    ..registerLazySingleton<SettingsModel>(
      () => SettingsModel(
        service: di<SettingsService>(),
        externalPathService: di<ExternalPathService>(),
        gitHub: di<GitHub>(),
      )..init(),
      dispose: (s) => s.dispose(),
    )
    ..registerLazySingleton<PlayerModel>(
      () => PlayerModel(
        service: di<PlayerService>(),
        connectivity: di<Connectivity>(),
      )..init(),
      dispose: (s) => s.dispose(),
    )
    ..registerLazySingleton<AppModel>(
      () => AppModel(
        appVersion: version,
        gitHub: di<GitHub>(),
        settingsService: di<SettingsService>(),
        allowManualUpdates: Platform.isLinux ? false : true,
      ),
      dispose: (s) => s.dispose(),
    )
    ..registerLazySingleton<LibraryModel>(
      () => LibraryModel(di<LibraryService>()),
      dispose: (s) => s.dispose(),
    )
    ..registerLazySingleton<LocalAudioModel>(
      () => LocalAudioModel(localAudioService: di<LocalAudioService>()),
      dispose: (s) => s.dispose(),
    )
    ..registerLazySingleton<PodcastModel>(
      () => PodcastModel(podcastService: di.get<PodcastService>()),
      dispose: (s) => s.dispose(),
    )
    ..registerLazySingleton<RadioModel>(
      () => RadioModel(
        radioService: di<RadioService>(),
        onlineArtService: di<OnlineArtService>(),
      ),
      dispose: (s) => s.dispose(),
    )
    ..registerLazySingleton<DownloadModel>(
      () => DownloadModel(
        libraryService: di<LibraryService>(),
        dio: di<Dio>(),
      ),
    )
    ..registerLazySingleton<SearchModel>(
      () => SearchModel(
        podcastService: di<PodcastService>(),
        radioService: di<RadioService>(),
        libraryService: di<LibraryService>(),
        localAudioService: di<LocalAudioService>(),
      )..init(),
    )
    ..registerLazySingleton<OnlineArtModel>(
      () => OnlineArtModel(
        service: di<OnlineArtService>(),
      ),
      dispose: (m) => m.dispose(),
    );
}
