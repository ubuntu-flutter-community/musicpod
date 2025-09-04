import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:dio/dio.dart';
import 'package:flutter_discord_rpc/flutter_discord_rpc.dart';
import 'package:github/github.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smtc_windows/smtc_windows.dart';
import 'package:watch_it/watch_it.dart';
import 'package:window_manager/window_manager.dart';

import 'app/app_model.dart';
import 'app/connectivity_model.dart';
import 'app/view/routing_manager.dart';
import 'app_config.dart';
import 'custom_content/custom_content_model.dart';
import 'expose/expose_service.dart';
import 'expose/lastfm_service.dart';
import 'expose/listenbrainz_service.dart';
import 'extensions/taget_platform_x.dart';
import 'external_path/external_path_service.dart';
import 'library/library_model.dart';
import 'library/library_service.dart';
import 'local_audio/local_audio_model.dart';
import 'local_audio/local_audio_service.dart';
import 'local_audio/local_cover_model.dart';
import 'local_audio/local_cover_service.dart';
import 'notifications/notifications_service.dart';
import 'persistence_utils.dart';
import 'player/register_audio_service_handler.dart';
import 'player/player_model.dart';
import 'player/player_service.dart';
import 'player/register_smtc_windows.dart';
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
import 'settings/view/licenses_dialog.dart';

/// Registers all Services, ViewModels and external dependencies
void registerDependencies() {
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

  if (AppConfig.windowManagerImplemented) {
    di.registerSingletonAsync<WindowManager>(() async {
      final wm = WindowManager.instance;
      await wm.ensureInitialized();
      return wm;
    });
  }

  di
    ..registerSingletonAsync<SharedPreferences>(SharedPreferences.getInstance)
    ..registerSingletonAsync<PackageInfo>(PackageInfo.fromPlatform)
    ..registerLazySingleton<Dio>(() => Dio(), dispose: (s) => s.close())
    ..registerLazySingleton<OnlineArtService>(
      () => OnlineArtService(dio: di<Dio>()),
      dispose: (s) => s.dispose(),
    )
    ..registerSingletonAsync<SettingsService>(
      () async {
        final downloadsDefaultDir = await getDownloadsDefaultDir();
        const forcedUpdateThreshold = String.fromEnvironment(
          'FORCED_UPDATE_THRESHOLD',
          defaultValue: '2.11.0',
        );
        return SettingsService(
          windowManager: AppConfig.windowManagerImplemented
              ? di<WindowManager>()
              : null,
          forcedUpdateThreshold: forcedUpdateThreshold,
          sharedPreferences: di<SharedPreferences>(),
          downloadsDefaultDir: downloadsDefaultDir,
        );
      },
      dependsOn: [
        SharedPreferences,
        if (AppConfig.windowManagerImplemented) WindowManager,
      ],
      dispose: (s) async => s.dispose(),
    )
    ..registerSingletonWithDependencies(
      () => LastfmService(settingsService: di<SettingsService>()),
      dependsOn: [SettingsService],
    )
    ..registerSingletonWithDependencies(
      () => ListenBrainzService(settingsService: di<SettingsService>()),
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
    ..registerLazySingleton<VideoController>(() {
      MediaKit.ensureInitialized();
      return VideoController(
        Player(
          configuration: const PlayerConfiguration(title: AppConfig.appTitle),
        ),
      );
    }, dispose: (s) => s.player.dispose())
    ..registerSingletonAsync<PlayerService>(
      () async {
        final playerService = PlayerService(
          controller: di<VideoController>(),
          exposeService: di<ExposeService>(),
          localCoverService: di<LocalCoverService>(),
        );
        await playerService.init();
        return playerService;
      },
      dependsOn: [ExposeService],
      dispose: (s) async => s.dispose(),
    );
  if (isWindows) {
    di.registerSingletonAsync<SMTCWindows>(
      registerSMTCWindows,
      dependsOn: [PlayerService],
      dispose: (s) async {
        smtcSubscription?.cancel();
        await s.dispose();
      },
    );
  } else {
    di.registerSingletonAsync<AudioServiceHandler>(
      registerAudioServiceHandler,
      dependsOn: [PlayerService],
      dispose: (s) async => s.stop(),
    );
  }

  di
    ..registerSingleton<ExternalPathService>(const ExternalPathService())
    ..registerSingletonAsync<LibraryService>(
      () async {
        final libraryService = LibraryService(
          sharedPreferences: di<SharedPreferences>(),
        );
        await libraryService.init();
        return libraryService;
      },
      dependsOn: [SharedPreferences],
      dispose: (s) async => s.dispose(),
    )
    ..registerSingletonAsync<LocalAudioService>(
      () async {
        final localAudioService = LocalAudioService(
          settingsService: di<SettingsService>(),
          localCoverService: di<LocalCoverService>(),
        );

        return localAudioService;
      },
      dependsOn: [SettingsService, LibraryService],
      dispose: (s) async => s.dispose(),
    )
    ..registerLazySingleton<NotificationsService>(
      () => NotificationsService(isLinux ? NotificationsClient() : null),
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
    ..registerSingletonAsync<RadioService>(
      () async {
        final s = RadioService(
          playerService: di<PlayerService>(),
          onlineArtService: di<OnlineArtService>(),
          exposeService: di<ExposeService>(),
        );
        await s.init();
        return s;
      },
      dispose: (s) => s.dispose(),
      dependsOn: [PlayerService, ExposeService],
    )
    ..registerLazySingleton<GitHub>(() => GitHub())
    ..registerSingletonAsync<ConnectivityModel>(() async {
      final connectivityModel = ConnectivityModel(
        playerService: di<PlayerService>(),
        connectivity: di<Connectivity>(),
      );
      await connectivityModel.init();
      return connectivityModel;
    }, dependsOn: [PlayerService])
    ..registerSingletonWithDependencies<SettingsModel>(
      () => SettingsModel(
        service: di<SettingsService>(),
        externalPathService: di<ExternalPathService>(),
        gitHub: di<GitHub>(),
      ),
      dependsOn: [SettingsService],
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
      () => OnlineArtModel(onlineArtService: di<OnlineArtService>()),
      dispose: (s) => s.dispose(),
    )
    ..registerSingletonAsync<AppModel>(
      () async {
        final appModel = AppModel(
          packageInfo: di<PackageInfo>(),
          gitHub: di<GitHub>(),
          settingsService: di<SettingsService>(),
          exposeService: di<ExposeService>(),
          allowManualUpdates: isLinux ? false : true,
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
      () => LibraryModel(libraryService: di<LibraryService>()),
      dispose: (s) => s.dispose(),
      dependsOn: [LibraryService],
    )
    ..registerSingletonWithDependencies<RoutingManager>(
      () => RoutingManager(libraryService: di<LibraryService>()),
      dependsOn: [LibraryService],
    )
    ..registerSingletonWithDependencies<LocalAudioModel>(
      () => LocalAudioModel(
        localAudioService: di<LocalAudioService>(),
        settingsService: di<SettingsService>(),
        libraryService: di<LibraryService>(),
      ),
      dependsOn: [SettingsService, LocalAudioService, LibraryService],
      dispose: (s) => s.dispose(),
    )
    ..registerLazySingleton<PodcastModel>(
      () => PodcastModel(podcastService: di<PodcastService>()),
      dispose: (s) => s.dispose(),
    )
    ..registerSingletonWithDependencies<RadioModel>(
      () => RadioModel(
        radioService: di<RadioService>(),
        playerService: di<PlayerService>(),
      ),
      dependsOn: [RadioService, PlayerService],
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
    ..registerSingletonWithDependencies<SearchModel>(
      () => SearchModel(
        podcastService: di<PodcastService>(),
        radioService: di<RadioService>(),
        libraryService: di<LibraryService>(),
        localAudioService: di<LocalAudioService>(),
      ),
      dependsOn: [RadioService, LibraryService, LocalAudioService],
    )
    ..registerSingletonWithDependencies<CustomContentModel>(
      () => CustomContentModel(
        externalPathService: di<ExternalPathService>(),
        libraryService: di<LibraryService>(),
        podcastService: di<PodcastService>(),
        localAudioService: di<LocalAudioService>(),
      ),
      dependsOn: [
        LibraryService,
        PodcastService,
        RadioService,
        LocalAudioService,
      ],
      dispose: (s) => s.dispose(),
    )
    ..registerLazySingleton(() => LicenseStore());
}
