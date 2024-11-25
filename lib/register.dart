import 'package:package_info_plus/package_info_plus.dart';

import 'app/app_model.dart';
import 'app/connectivity_model.dart';
import 'app_config.dart';
import 'constants.dart';
import 'dart:io';
import 'expose/expose_service.dart';
import 'expose/lastfm_service.dart';
import 'expose/listenbrainz_service.dart';
import 'external_path/external_path_service.dart';
import 'library/library_model.dart';
import 'library/library_service.dart';
import 'local_audio/local_audio_model.dart';
import 'local_audio/local_audio_service.dart';
import 'local_audio/local_cover_model.dart';
import 'local_audio/local_cover_service.dart';
import 'notifications/notifications_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:dio/dio.dart';
import 'package:flutter_discord_rpc/flutter_discord_rpc.dart';
import 'package:github/github.dart';
import 'package:gtk/gtk.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watch_it/watch_it.dart';
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
/// Note: we want lazy registration whenever possible, preferable without any async calls above.
/// Sometimes this is not possible and we need to await a Future before we can register.
Future<void> registerDependencies({
  required List<String> args,
  required String? downloadsDefaultDir,
}) async {
  if (allowDiscordRPC) {
    await FlutterDiscordRPC.initialize(kDiscordApplicationId);
    di.registerSingleton<FlutterDiscordRPC>(
      FlutterDiscordRPC.instance,
      dispose: (s) {
        s.disconnect();
        s.dispose();
      },
    );
  }

  final sharedPreferences = await SharedPreferences.getInstance();
  final packageInfo = await PackageInfo.fromPlatform();

  di
    ..registerSingleton<SharedPreferences>(sharedPreferences)
    ..registerSingleton<PackageInfo>(packageInfo)
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
    ..registerLazySingleton<SettingsService>(
      () => SettingsService(
        sharedPreferences: di<SharedPreferences>(),
        downloadsDefaultDir: downloadsDefaultDir,
      ),
      dispose: (s) async => s.dispose(),
    )
    ..registerLazySingleton(
      () => LastfmService(
        settingsService: di<SettingsService>(),
      )..init(),
    )
    ..registerLazySingleton(
      () => ListenBrainzService(
        settingsService: di<SettingsService>(),
      )..init(),
    )
    ..registerLazySingleton<ExposeService>(
      () => ExposeService(
        discordRPC: allowDiscordRPC ? di<FlutterDiscordRPC>() : null,
        lastFmService: di<LastfmService>(),
        listenBrainzService: di<ListenBrainzService>(),
      ),
      dispose: (s) => s.dispose(),
    )
    ..registerLazySingleton(LocalCoverService.new, dispose: (s) => s.dispose())
    ..registerLazySingleton<PlayerService>(
      () => PlayerService(
        onlineArtService: di<OnlineArtService>(),
        controller: VideoController(
          Player(
            configuration: const PlayerConfiguration(title: kAppTitle),
          ),
        ),
        exposeService: di<ExposeService>(),
        localCoverService: di<LocalCoverService>(),
      )..init(),
      dispose: (s) async => s.dispose(),
    )
    ..registerLazySingleton<LibraryService>(
      () => LibraryService(sharedPreferences: di<SharedPreferences>()),
      dispose: (s) async => s.dispose(),
    )
    ..registerLazySingleton<LocalAudioService>(
      () => LocalAudioService(
        settingsService: di<SettingsService>(),
        localCoverService: di<LocalCoverService>(),
      ),
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
    ..registerLazySingleton<RadioService>(
      RadioService.new,
      dispose: (s) => s.dispose(),
    )
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
    ..registerLazySingleton(
      () => LocalCoverModel(localCoverService: di<LocalCoverService>())..init(),
      dispose: (s) => s.dispose(),
    )
    ..registerLazySingleton<PlayerModel>(
      () => PlayerModel(
        service: di<PlayerService>(),
        onlineArtService: di<OnlineArtService>(),
      )..init(),
      dispose: (s) => s.dispose(),
    )
    ..registerLazySingleton<OnlineArtModel>(
      () => OnlineArtModel(
        onlineArtService: di<OnlineArtService>(),
      )..init(),
      dispose: (s) => s.dispose(),
    )
    ..registerLazySingleton<AppModel>(
      () => AppModel(
        packageInfo: di<PackageInfo>(),
        gitHub: di<GitHub>(),
        settingsService: di<SettingsService>(),
        exposeService: di<ExposeService>(),
        allowManualUpdates: Platform.isLinux ? false : true,
      ),
      dispose: (s) => s.dispose(),
    )
    ..registerLazySingleton<LibraryModel>(
      () => LibraryModel(di<LibraryService>()),
      dispose: (s) => s.dispose(),
    )
    ..registerLazySingleton<LocalAudioModel>(
      () => LocalAudioModel(
        localAudioService: di<LocalAudioService>(),
        settingsService: di<SettingsService>(),
      ),
      dispose: (s) => s.dispose(),
    )
    ..registerLazySingleton<PodcastModel>(
      () => PodcastModel(podcastService: di.get<PodcastService>()),
      dispose: (s) => s.dispose(),
    )
    ..registerLazySingleton<RadioModel>(
      () => RadioModel(
        radioService: di<RadioService>(),
      ),
      dispose: (s) => s.dispose(),
    )
    ..registerLazySingleton<DownloadModel>(
      () => DownloadModel(
        settingsService: di<SettingsService>(),
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
    );
}
