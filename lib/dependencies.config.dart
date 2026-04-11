// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:github/github.dart' as _i535;
import 'package:injectable/injectable.dart' as _i526;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart'
    as _i161;
import 'package:local_notifier/local_notifier.dart' as _i526;
import 'package:media_kit_video/media_kit_video.dart' as _i150;
import 'package:package_info_plus/package_info_plus.dart' as _i655;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:window_manager/window_manager.dart' as _i740;

import 'app/app_manager.dart' as _i369;
import 'app/connectivity_manager.dart' as _i1035;
import 'app/routing_manager.dart' as _i971;
import 'app/sidebar_audios_manager.dart' as _i190;
import 'app/window_size_to_settings_listener.dart' as _i517;
import 'common/persistence/database.dart' as _i115;
import 'custom_content/custom_content_model.dart' as _i55;
import 'expose/expose_manager.dart' as _i987;
import 'expose/expose_service.dart' as _i820;
import 'expose/lastfm_service.dart' as _i820;
import 'expose/listenbrainz_service.dart' as _i348;
import 'external_path/external_path_service.dart' as _i551;
import 'library/library_model.dart' as _i1032;
import 'library/library_service.dart' as _i595;
import 'local_audio/local_audio_manager.dart' as _i688;
import 'local_audio/local_audio_service.dart' as _i438;
import 'local_audio/local_cover_manager.dart' as _i439;
import 'local_audio/local_cover_service.dart' as _i57;
import 'lyrics/lyrics_service.dart' as _i546;
import 'notifications/notifications_service.dart' as _i57;
import 'player/mpv_metadata_manager.dart' as _i112;
import 'player/player_model.dart' as _i1025;
import 'player/player_service.dart' as _i38;
import 'podcasts/download_manager.dart' as _i388;
import 'podcasts/podcast_manager.dart' as _i351;
import 'podcasts/podcast_service.dart' as _i721;
import 'radio/online_art_model.dart' as _i620;
import 'radio/online_art_service.dart' as _i328;
import 'radio/radio_model.dart' as _i798;
import 'radio/radio_service.dart' as _i811;
import 'search/search_model.dart' as _i544;
import 'settings/settings_model.dart' as _i338;
import 'settings/settings_service.dart' as _i763;
import 'settings/view/licenses_dialog.dart' as _i1009;
import 'third_party/audio_service_module.dart' as _i739;
import 'third_party/database_module.dart' as _i440;
import 'third_party/dio_module.dart' as _i1039;
import 'third_party/github_module.dart' as _i207;
import 'third_party/internet_connection_module.dart' as _i132;
import 'third_party/local_notifier_module.dart' as _i8;
import 'third_party/media_kit_module.dart' as _i94;
import 'third_party/package_info_module.dart' as _i855;
import 'third_party/shared_preferences_module.dart' as _i357;
import 'third_party/window_manager_module.dart' as _i271;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final dioModule = _$DioModule();
    final githubModule = _$GithubModule();
    final internetConnectionModule = _$InternetConnectionModule();
    final localNotifierModule = _$LocalNotifierModule();
    final mediaKitModule = _$MediaKitModule();
    final packageInfoModule = _$PackageInfoModule();
    final sharedPreferencesModule = _$SharedPreferencesModule();
    final windowManagerModule = _$WindowManagerModule();
    final databaseModule = _$DatabaseModule();
    final audioServiceModule = _$AudioServiceModule();
    gh.factory<_i361.Dio>(() => dioModule.create());
    gh.factory<_i535.GitHub>(() => githubModule.gitHub);
    gh.factory<_i161.InternetConnection>(
      () => internetConnectionModule.internetConnection,
    );
    await gh.factoryAsync<_i526.LocalNotifier>(
      () => localNotifierModule.create,
      preResolve: true,
    );
    gh.factory<_i150.VideoController>(() => mediaKitModule.mediaKit);
    await gh.factoryAsync<_i655.PackageInfo>(
      () => packageInfoModule.packageInfo,
      preResolve: true,
    );
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => sharedPreferencesModule.sharedPreferences,
      preResolve: true,
    );
    await gh.factoryAsync<_i740.WindowManager>(
      () => windowManagerModule.create(),
      preResolve: true,
    );
    gh.lazySingleton<_i551.ExternalPathService>(
      () => const _i551.ExternalPathService(),
    );
    gh.lazySingleton<_i546.LocalLyricsService>(
      () => _i546.LocalLyricsService(),
    );
    gh.lazySingleton<_i811.RadioService>(() => _i811.RadioService());
    gh.lazySingleton<_i1009.LicenseStore>(() => _i1009.LicenseStore());
    gh.lazySingleton<_i115.Database>(() => databaseModule.database);
    gh.lazySingleton<_i328.OnlineArtService>(
      () => _i328.OnlineArtService(dio: gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i798.RadioManager>(
      () => _i798.RadioManager(radioService: gh<_i811.RadioService>()),
    );
    gh.lazySingleton<_i620.OnlineArtModel>(
      () =>
          _i620.OnlineArtModel(onlineArtService: gh<_i328.OnlineArtService>()),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i57.LocalCoverService>(
      () => _i57.LocalCoverService(database: gh<_i115.Database>()),
    );
    gh.lazySingleton<_i763.SettingsService>(
      () => _i763.SettingsService(
        sharedPreferences: gh<_i460.SharedPreferences>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i439.LocalCoverManager>(
      () => _i439.LocalCoverManager(
        localCoverService: gh<_i57.LocalCoverService>(),
      ),
    );
    gh.lazySingleton<_i338.SettingsModel>(
      () => _i338.SettingsModel(service: gh<_i763.SettingsService>()),
    );
    gh.lazySingleton<_i57.NotificationsService>(
      () => _i57.NotificationsService(localNotifier: gh<_i526.LocalNotifier>()),
    );
    gh.lazySingleton<_i820.LastfmService>(
      () => _i820.LastfmService(settingsService: gh<_i763.SettingsService>()),
    );
    gh.lazySingleton<_i348.ListenBrainzService>(
      () => _i348.ListenBrainzService(
        settingsService: gh<_i763.SettingsService>(),
      ),
    );
    gh.lazySingleton<_i546.OnlineLyricsService>(
      () => _i546.OnlineLyricsService(
        localLyricsService: gh<_i546.LocalLyricsService>(),
        settingsService: gh<_i763.SettingsService>(),
      ),
    );
    gh.lazySingleton<_i438.LocalAudioService>(
      () => _i438.LocalAudioService(
        localCoverService: gh<_i57.LocalCoverService>(),
        settingsService: gh<_i763.SettingsService>(),
        database: gh<_i115.Database>(),
      ),
    );
    gh.lazySingleton<_i820.ExposeService>(
      () => _i820.ExposeService(
        lastFmService: gh<_i820.LastfmService>(),
        listenBrainzService: gh<_i348.ListenBrainzService>(),
      ),
    );
    gh.lazySingleton<_i987.ExposeManager>(
      () => _i987.ExposeManager(exposeService: gh<_i820.ExposeService>()),
    );
    await gh.singletonAsync<_i595.LibraryService>(
      () {
        final i = _i595.LibraryService(
          database: gh<_i115.Database>(),
          localAudioService: gh<_i438.LocalAudioService>(),
        );
        return i.init().then((_) => i);
      },
      preResolve: true,
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i688.LocalAudioManager>(
      () => _i688.LocalAudioManager(
        localAudioService: gh<_i438.LocalAudioService>(),
        libraryService: gh<_i595.LibraryService>(),
      ),
    );
    gh.lazySingleton<_i971.RoutingManager>(
      () => _i971.RoutingManager(
        libraryService: gh<_i595.LibraryService>(),
        settingsService: gh<_i763.SettingsService>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i388.DownloadManager>(
      () => _i388.DownloadManager(
        libraryService: gh<_i595.LibraryService>(),
        settingsService: gh<_i763.SettingsService>(),
        dio: gh<_i361.Dio>(),
        externalPathService: gh<_i551.ExternalPathService>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i369.AppManager>(
      () => _i369.AppManager(
        packageInfo: gh<_i655.PackageInfo>(),
        settingsService: gh<_i763.SettingsService>(),
        gitHub: gh<_i535.GitHub>(),
        localAudioService: gh<_i438.LocalAudioService>(),
        libraryService: gh<_i595.LibraryService>(),
        internetConnection: gh<_i161.InternetConnection>(),
      ),
    );
    gh.lazySingleton<_i721.PodcastService>(
      () => _i721.PodcastService(
        notificationsService: gh<_i57.NotificationsService>(),
        settingsService: gh<_i763.SettingsService>(),
        libraryService: gh<_i595.LibraryService>(),
        database: gh<_i115.Database>(),
      ),
    );
    gh.lazySingleton<_i55.CustomContentModel>(
      () => _i55.CustomContentModel(
        externalPathService: gh<_i551.ExternalPathService>(),
        libraryService: gh<_i595.LibraryService>(),
        localAudioService: gh<_i438.LocalAudioService>(),
        podcastService: gh<_i721.PodcastService>(),
      ),
    );
    gh.lazySingleton<_i1032.LibraryModel>(
      () => _i1032.LibraryModel(libraryService: gh<_i595.LibraryService>()),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i544.SearchModel>(
      () => _i544.SearchModel(
        radioService: gh<_i811.RadioService>(),
        podcastService: gh<_i721.PodcastService>(),
        libraryService: gh<_i595.LibraryService>(),
        localAudioService: gh<_i438.LocalAudioService>(),
        settingsService: gh<_i763.SettingsService>(),
      ),
    );
    await gh.singletonAsync<_i38.PlayerService>(
      () {
        final i = _i38.PlayerService(
          controller: gh<_i150.VideoController>(),
          exposeService: gh<_i820.ExposeService>(),
          localCoverService: gh<_i57.LocalCoverService>(),
          libraryService: gh<_i595.LibraryService>(),
          database: gh<_i115.Database>(),
        );
        return i.init().then((_) => i);
      },
      preResolve: true,
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i1025.PlayerModel>(
      () => _i1025.PlayerModel(
        service: gh<_i38.PlayerService>(),
        onlineArtService: gh<_i328.OnlineArtService>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i351.PodcastManager>(
      () => _i351.PodcastManager(podcastService: gh<_i721.PodcastService>()),
    );
    await gh.singletonAsync<_i517.WindowSizeToSettingsListener>(() {
      final i = _i517.WindowSizeToSettingsListener(
        sharedPreferences: gh<_i460.SharedPreferences>(),
        playerService: gh<_i38.PlayerService>(),
        windowManager: gh<_i740.WindowManager>(),
      );
      return i.init().then((_) => i);
    }, preResolve: true);
    gh.singleton<_i1035.ConnectivityManager>(
      () => _i1035.ConnectivityManager(
        playerService: gh<_i38.PlayerService>(),
        internetConnection: gh<_i161.InternetConnection>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i190.SidebarAudiosManager>(
      () => _i190.SidebarAudiosManager(
        libraryModel: gh<_i1032.LibraryModel>(),
        localAudioManager: gh<_i688.LocalAudioManager>(),
        podcastManager: gh<_i351.PodcastManager>(),
        radioManager: gh<_i798.RadioManager>(),
        playerModel: gh<_i1025.PlayerModel>(),
      ),
    );
    await gh.singletonAsync<_i112.MpvMetadataManager>(
      () {
        final i = _i112.MpvMetadataManager(
          playerService: gh<_i38.PlayerService>(),
          onlineArtService: gh<_i328.OnlineArtService>(),
          exposeService: gh<_i820.ExposeService>(),
        );
        return i.init().then((_) => i);
      },
      preResolve: true,
      dispose: (i) => i.dispose(),
    );
    await gh.factoryAsync<_i739.AudioServiceHandler>(
      () => audioServiceModule.audioServiceHandler(gh<_i38.PlayerService>()),
      preResolve: true,
    );
    return this;
  }
}

class _$DioModule extends _i1039.DioModule {}

class _$GithubModule extends _i207.GithubModule {}

class _$InternetConnectionModule extends _i132.InternetConnectionModule {}

class _$LocalNotifierModule extends _i8.LocalNotifierModule {}

class _$MediaKitModule extends _i94.MediaKitModule {}

class _$PackageInfoModule extends _i855.PackageInfoModule {}

class _$SharedPreferencesModule extends _i357.SharedPreferencesModule {}

class _$WindowManagerModule extends _i271.WindowManagerModule {}

class _$DatabaseModule extends _i440.DatabaseModule {}

class _$AudioServiceModule extends _i739.AudioServiceModule {}
