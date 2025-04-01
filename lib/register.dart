import 'dart:io';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:dio/dio.dart';
import 'package:flutter_discord_rpc/flutter_discord_rpc.dart';
import 'package:github/github.dart';
import 'package:gtk/gtk.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watch_it/watch_it.dart';
import 'package:window_manager/window_manager.dart';

import 'app/app_model.dart';
import 'app/connectivity_model.dart';
import 'app/window_size_to_settings_listener.dart';
import 'app_config.dart';
import 'expose/expose_service.dart';
import 'expose/lastfm_service.dart';
import 'expose/listenbrainz_service.dart';
import 'extensions/shared_preferences_x.dart';
import 'external_path/external_path_service.dart';
import 'library/library_model.dart';
import 'library/library_service.dart';
import 'local_audio/local_audio_model.dart';
import 'local_audio/local_audio_service.dart';
import 'local_audio/local_cover_model.dart';
import 'local_audio/local_cover_service.dart';
import 'notifications/notifications_service.dart';
import 'persistence_utils.dart';
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

/// Registers all Services, ViewModels and external dependencies
void registerDependencies({required List<String> args}) async {
  if (AppConfig.allowDiscordRPC) {
    di.registerSingletonAsync<FlutterDiscordRPC>(
      () async {
        await FlutterDiscordRPC.initialize(AppConfig.discordApplicationId);
        return FlutterDiscordRPC.instance;
      },
      dispose: (s) {
        s.disconnect();
        s.dispose();
      },
    );
  }

  // TODO: try to register window manager inside get_it
  di
    ..registerSingletonAsync<SharedPreferences>(() async {
      final prefs = await SharedPreferences.getInstance();
      final wm = WindowManager.instance;
      wm.addListener(
        WindowSizeToSettingsListener(
          onFullscreen: (v) => prefs.setBool(SPKeys.windowFullscreen, v),
          onMaximize: (v) => prefs.setBool(SPKeys.windowMaximized, v),
          onResize: (v) =>
              prefs.setInt(SPKeys.windowHeight, v.height.toInt()).then(
                    (_) => prefs.setInt(SPKeys.windowWidth, v.width.toInt()),
                  ),
        ),
      );

      if (prefs.getBool(SPKeys.windowFullscreen) ?? false) {
        WindowManager.instance.setFullScreen(true);
      } else if (prefs.getBool(SPKeys.windowMaximized) ?? false) {
        WindowManager.instance.maximize();
      } else {
        final height = prefs.getInt(SPKeys.windowHeight) ?? 820;
        final width = prefs.getInt(SPKeys.windowWidth) ?? 950;
        WindowManager.instance.setSize(
          Size(
            width.toDouble(),
            height.toDouble(),
          ),
        );
      }

      return prefs;
    })
    ..registerSingletonAsync<PackageInfo>(PackageInfo.fromPlatform)
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
    ..registerSingletonAsync<SettingsService>(
      () async {
        final downloadsDefaultDir = await getDownloadsDefaultDir();
        return SettingsService(
          sharedPreferences: di<SharedPreferences>(),
          downloadsDefaultDir: downloadsDefaultDir,
        );
      },
      dependsOn: [SharedPreferences],
      dispose: (s) async => s.dispose(),
    )
    ..registerSingletonWithDependencies(
      () => LastfmService(
        settingsService: di<SettingsService>(),
      ),
      dependsOn: [SettingsService],
    )
    ..registerSingletonWithDependencies(
      () => ListenBrainzService(
        settingsService: di<SettingsService>(),
      ),
      dependsOn: [SettingsService],
    )
    ..registerSingletonAsync<ExposeService>(
      () async => ExposeService(
        settingsService: di<SettingsService>(),
        discordRPC: AppConfig.allowDiscordRPC ? di<FlutterDiscordRPC>() : null,
        lastFmService: di<LastfmService>(),
        listenBrainzService: di<ListenBrainzService>(),
      ),
      dependsOn: [
        if (AppConfig.allowDiscordRPC) FlutterDiscordRPC,
        LastfmService,
        SettingsService,
      ],
      dispose: (s) => s.dispose(),
    )
    ..registerLazySingleton(LocalCoverService.new, dispose: (s) => s.dispose())
    ..registerSingletonAsync<PlayerService>(
      () async {
        final playerService = PlayerService(
          onlineArtService: di<OnlineArtService>(),
          controller: VideoController(
            Player(
              configuration:
                  const PlayerConfiguration(title: AppConfig.appTitle),
            ),
          ),
          exposeService: di<ExposeService>(),
          localCoverService: di<LocalCoverService>(),
        );
        await playerService.init();
        return playerService;
      },
      dependsOn: [ExposeService],
      dispose: (s) async => s.dispose(),
    )
    ..registerSingletonAsync<LibraryService>(
      () async {
        final libraryService =
            LibraryService(sharedPreferences: di<SharedPreferences>());
        await libraryService.init();
        return libraryService;
      },
      dependsOn: [SharedPreferences],
      dispose: (s) async => s.dispose(),
    )
    ..registerSingletonWithDependencies<LocalAudioService>(
      () => LocalAudioService(
        settingsService: di<SettingsService>(),
        localCoverService: di<LocalCoverService>(),
      ),
      dependsOn: [SettingsService],
      dispose: (s) async => s.dispose(),
    )
    ..registerLazySingleton<NotificationsService>(
      () =>
          NotificationsService(Platform.isLinux ? NotificationsClient() : null),
      dispose: (s) async => s.dispose(),
    )
    ..registerSingletonWithDependencies<PodcastService>(
      () => PodcastService(
        notificationsService: di<NotificationsService>(),
        settingsService: di<SettingsService>(),
        libraryService: di<LibraryService>(),
      ),
      dependsOn: [SettingsService, LibraryService],
    )
    ..registerLazySingleton<Connectivity>(() => Connectivity())
    ..registerSingletonWithDependencies<ExternalPathService>(
      () => ExternalPathService(
        gtkNotifier: Platform.isLinux ? GtkApplicationNotifier(args) : null,
        playerService: di<PlayerService>(),
      ),
      dependsOn: [PlayerService],
      dispose: (s) => s.dispose(),
    )
    ..registerSingletonAsync<RadioService>(
      () async {
        final s = RadioService();
        await s.init();
        return s;
      },
      dispose: (s) => s.dispose(),
    )
    ..registerLazySingleton<GitHub>(() => GitHub())
    ..registerSingletonAsync<ConnectivityModel>(
      () async {
        final connectivityModel = ConnectivityModel(
          playerService: di<PlayerService>(),
          connectivity: di<Connectivity>(),
        );
        await connectivityModel.init();
        return connectivityModel;
      },
      dependsOn: [PlayerService],
    )
    ..registerSingletonWithDependencies<SettingsModel>(
      () => SettingsModel(
        service: di<SettingsService>(),
        externalPathService: di<ExternalPathService>(),
        gitHub: di<GitHub>(),
      ),
      dependsOn: [SettingsService, ExternalPathService],
      dispose: (s) => s.dispose(),
    )
    ..registerLazySingleton(
      () => LocalCoverModel(localCoverService: di<LocalCoverService>()),
      dispose: (s) => s.dispose(),
    )
    ..registerSingletonWithDependencies<PlayerModel>(
      () => PlayerModel(
        service: di<PlayerService>(),
        onlineArtService: di<OnlineArtService>(),
      ),
      dependsOn: [PlayerService],
      dispose: (s) => s.dispose(),
    )
    ..registerLazySingleton<OnlineArtModel>(
      () => OnlineArtModel(
        onlineArtService: di<OnlineArtService>(),
      ),
      dispose: (s) => s.dispose(),
    )
    ..registerSingletonAsync<AppModel>(
      () async {
        final appModel = AppModel(
          packageInfo: di<PackageInfo>(),
          gitHub: di<GitHub>(),
          settingsService: di<SettingsService>(),
          exposeService: di<ExposeService>(),
          allowManualUpdates: Platform.isLinux ? false : true,
        );
        await appModel.checkForUpdate(
          isOnline: di<ConnectivityModel>().isOnline == true,
        );
        return appModel;
      },
      dependsOn: [SettingsService, ExposeService, ConnectivityModel],
      dispose: (s) => s.dispose(),
    )
    ..registerSingletonWithDependencies<LibraryModel>(
      () => LibraryModel(di<LibraryService>()),
      dispose: (s) => s.dispose(),
      dependsOn: [LibraryService],
    )
    ..registerSingletonWithDependencies<LocalAudioModel>(
      () => LocalAudioModel(
        localAudioService: di<LocalAudioService>(),
        settingsService: di<SettingsService>(),
      ),
      dependsOn: [SettingsService],
      dispose: (s) => s.dispose(),
    )
    ..registerLazySingleton<PodcastModel>(
      () => PodcastModel(podcastService: di.get<PodcastService>()),
      dispose: (s) => s.dispose(),
    )
    ..registerSingletonWithDependencies<RadioModel>(
      () => RadioModel(
        radioService: di<RadioService>(),
      ),
      dependsOn: [RadioService],
      dispose: (s) => s.dispose(),
    )
    ..registerSingletonWithDependencies<DownloadModel>(
      () => DownloadModel(
        settingsService: di<SettingsService>(),
        libraryService: di<LibraryService>(),
        dio: di<Dio>(),
      ),
      dependsOn: [SettingsService, LibraryService],
      dispose: (s) => s.dispose(),
    )
    ..registerLazySingleton<SearchModel>(
      () => SearchModel(
        podcastService: di<PodcastService>(),
        radioService: di<RadioService>(),
        libraryService: di<LibraryService>(),
        localAudioService: di<LocalAudioService>(),
      ),
    );
}
