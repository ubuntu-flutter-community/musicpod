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
import 'package:local_notifier/local_notifier.dart' as _i527;
import 'package:media_kit_video/media_kit_video.dart' as _i150;
import 'package:package_info_plus/package_info_plus.dart' as _i655;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:window_manager/window_manager.dart' as _i740;

import 'app/app_manager.dart' as _i369;
import 'app/play_anywhere_manager.dart' as _i164;
import 'app/routing_manager.dart' as _i971;
import 'app/window_size_to_settings_listener.dart' as _i517;
import 'common/data/retry_capsule.dart' as _i327;
import 'common/manager/retry_manager.dart' as _i305;
import 'common/persistence/database.dart' as _i115;
import 'custom_content/service/custom_content_service.dart' as _i314;
import 'expose/manager/expose_manager.dart' as _i960;
import 'expose/service/expose_service.dart' as _i313;
import 'expose/service/lastfm_service.dart' as _i61;
import 'expose/service/listenbrainz_service.dart' as _i821;
import 'external_path/manager/secure_bookmark_manager.dart' as _i1069;
import 'external_path/service/external_path_service.dart' as _i415;
import 'external_path/service/secure_bookmark_service.dart' as _i395;
import 'local_audio/persistence/local_audio_dao.dart' as _i688;
import 'local_audio/service/local_audio_service.dart' as _i985;
import 'local_audio/service/local_cover_service.dart' as _i582;
import 'lyrics/lyrics_manager.dart' as _i23;
import 'lyrics/lyrics_service.dart' as _i546;
import 'notifications/notifications_service.dart' as _i57;
import 'player/manager/mpv_metadata_manager.dart' as _i507;
import 'player/manager/player_manager.dart' as _i95;
import 'player/persistence/player_dao.dart' as _i443;
import 'player/service/player_service.dart' as _i456;
import 'podcasts/manager/download_manager.dart' as _i167;
import 'podcasts/manager/episodes_manager.dart' as _i776;
import 'podcasts/manager/podcast_clean_manager.dart' as _i599;
import 'podcasts/manager/podcast_feeds_with_downloads_manager.dart' as _i399;
import 'podcasts/manager/podcast_genre_manager.dart' as _i990;
import 'podcasts/manager/podcast_load_genres_manager.dart' as _i141;
import 'podcasts/manager/podcast_manager.dart' as _i819;
import 'podcasts/manager/podcast_short_info_manager.dart' as _i212;
import 'podcasts/manager/podcast_updated_feeds_manager.dart' as _i605;
import 'podcasts/manager/podcast_updates_manager.dart' as _i851;
import 'podcasts/manager/subscribed_podcasts_manager.dart' as _i1055;
import 'podcasts/persistence/podcast_dao.dart' as _i597;
import 'podcasts/service/download_service.dart' as _i881;
import 'podcasts/service/podcast_service.dart' as _i529;
import 'radio/persistence/radio_dao.dart' as _i414;
import 'radio/service/online_art_service.dart' as _i852;
import 'radio/service/radio_service.dart' as _i506;
import 'search/manager/search_manager.dart' as _i354;
import 'settings/manager/settings_manager.dart' as _i964;
import 'settings/service/settings_service.dart' as _i862;
import 'settings/view/licenses_dialog.dart' as _i1009;
import 'third_party/audio_service_module.dart' as _i739;
import 'third_party/database_module.dart' as _i440;
import 'third_party/dio_module.dart' as _i1039;
import 'third_party/github_module.dart' as _i207;
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
    final localNotifierModule = _$LocalNotifierModule();
    final mediaKitModule = _$MediaKitModule();
    final packageInfoModule = _$PackageInfoModule();
    final sharedPreferencesModule = _$SharedPreferencesModule();
    final windowManagerModule = _$WindowManagerModule();
    final databaseModule = _$DatabaseModule();
    final audioServiceModule = _$AudioServiceModule();
    gh.factory<_i415.ExternalPathService>(
      () => const _i415.ExternalPathService(),
    );
    gh.factory<_i546.LocalLyricsService>(() => _i546.LocalLyricsService());
    gh.factory<_i1009.LicenseStore>(() => _i1009.LicenseStore.create());
    gh.factory<_i361.Dio>(() => dioModule.create());
    gh.factory<_i535.GitHub>(() => githubModule.gitHub);
    await gh.factoryAsync<_i527.LocalNotifier>(
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
    gh.lazySingleton<_i115.Database>(() => databaseModule.database);
    gh.factory<_i852.OnlineArtService>(
      () => _i852.OnlineArtService(dio: gh<_i361.Dio>()),
    );
    gh.factory<_i443.PlayerDao>(
      () => _i443.PlayerDao(db: gh<_i115.Database>()),
    );
    gh.factory<_i597.PodcastDao>(
      () => _i597.PodcastDao(db: gh<_i115.Database>()),
    );
    gh.factory<_i414.RadioDao>(() => _i414.RadioDao(db: gh<_i115.Database>()));
    gh.lazySingleton<_i506.RadioService>(
      () => _i506.RadioService(dao: gh<_i414.RadioDao>()),
    );
    gh.factory<_i688.LocalAudioDao>(
      () => _i688.LocalAudioDao(database: gh<_i115.Database>()),
    );
    gh.lazySingleton<_i862.SettingsService>(
      () => _i862.SettingsService(
        sharedPreferences: gh<_i460.SharedPreferences>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.factoryParam<_i305.RetryManager, _i327.RetryCapsule, dynamic>(
      (capsule, _) => _i305.RetryManager.create(capsule: capsule),
    );
    gh.lazySingleton<_i57.NotificationsService>(
      () => _i57.NotificationsService(localNotifier: gh<_i527.LocalNotifier>()),
    );
    gh.lazySingleton<_i582.LocalCoverService>(
      () => _i582.LocalCoverService(dao: gh<_i688.LocalAudioDao>()),
    );
    gh.factory<_i546.OnlineLyricsService>(
      () => _i546.OnlineLyricsService(
        dio: gh<_i361.Dio>(),
        localAudioDao: gh<_i688.LocalAudioDao>(),
      ),
    );
    gh.factory<_i23.LyricsManager>(
      () => _i23.LyricsManager.create(
        localLyricsService: gh<_i546.LocalLyricsService>(),
        onlineLyricsService: gh<_i546.OnlineLyricsService>(),
      ),
    );
    gh.lazySingleton<_i61.LastfmService>(
      () => _i61.LastfmService(settingsService: gh<_i862.SettingsService>()),
    );
    gh.lazySingleton<_i821.ListenBrainzService>(
      () => _i821.ListenBrainzService(
        settingsService: gh<_i862.SettingsService>(),
      ),
    );
    gh.lazySingleton<_i395.SecureBookmarkService>(
      () => _i395.SecureBookmarkService(
        settingsService: gh<_i862.SettingsService>(),
      ),
    );
    gh.lazySingleton<_i313.ExposeService>(
      () => _i313.ExposeService(
        lastFmService: gh<_i61.LastfmService>(),
        listenBrainzService: gh<_i821.ListenBrainzService>(),
      ),
    );
    gh.lazySingleton<_i529.PodcastService>(
      () => _i529.PodcastService(
        settingsService: gh<_i862.SettingsService>(),
        dao: gh<_i597.PodcastDao>(),
      ),
    );
    await gh.singletonAsync<_i456.PlayerService>(() {
      final i = _i456.PlayerService(
        controller: gh<_i150.VideoController>(),
        exposeService: gh<_i313.ExposeService>(),
        localCoverService: gh<_i582.LocalCoverService>(),
        podcastService: gh<_i529.PodcastService>(),
        dao: gh<_i443.PlayerDao>(),
      );
      return i.init().then((_) => i);
    }, preResolve: true);
    gh.factoryParam<_i990.PodcastGenreManager, String, dynamic>(
      (feedUrl, _) => _i990.PodcastGenreManager.create(
        feedUrl: feedUrl,
        podcastService: gh<_i529.PodcastService>(),
      ),
    );
    gh.factory<_i960.ExposeManager>(
      () =>
          _i960.ExposeManager.create(exposeService: gh<_i313.ExposeService>()),
    );
    gh.lazySingleton<_i985.LocalAudioService>(
      () => _i985.LocalAudioService(
        localCoverService: gh<_i582.LocalCoverService>(),
        settingsService: gh<_i862.SettingsService>(),
        localAudioDao: gh<_i688.LocalAudioDao>(),
      ),
    );
    gh.factory<_i605.PodcastUpdatedFeedsManager>(
      () => _i605.PodcastUpdatedFeedsManager.create(
        podcastService: gh<_i529.PodcastService>(),
      ),
    );
    gh.lazySingleton<_i141.PodcastLoadGenresManager>(
      () => _i141.PodcastLoadGenresManager(
        podcastService: gh<_i529.PodcastService>(),
      ),
    );
    gh.lazySingleton<_i819.PodcastManager>(
      () => _i819.PodcastManager(podcastService: gh<_i529.PodcastService>()),
    );
    await gh.factoryAsync<_i739.AudioServiceHandler>(
      () => audioServiceModule.audioServiceHandler(
        gh<_i456.PlayerService>(),
        gh<_i740.WindowManager>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i881.DownloadService>(
      () => _i881.DownloadService(
        externalPathService: gh<_i415.ExternalPathService>(),
        settingsService: gh<_i862.SettingsService>(),
        dio: gh<_i361.Dio>(),
        secureBookmarkService: gh<_i395.SecureBookmarkService>(),
      ),
    );
    gh.lazySingleton<_i1069.SecureBookmarkManager>(
      () => _i1069.SecureBookmarkManager(
        service: gh<_i395.SecureBookmarkService>(),
      ),
    );
    gh.factoryParam<_i212.PodcastShortInfoManager, String, dynamic>(
      (feedUrl, _) => _i212.PodcastShortInfoManager.create(
        feedUrl: feedUrl,
        podcastManager: gh<_i819.PodcastManager>(),
      ),
    );
    gh.factory<_i599.PodcastCleanManager>(
      () => _i599.PodcastCleanManager.create(gh<_i529.PodcastService>()),
    );
    gh.lazySingleton<_i507.MpvMetadataManager>(
      () => _i507.MpvMetadataManager(
        playerService: gh<_i456.PlayerService>(),
        exposeService: gh<_i313.ExposeService>(),
        settingsService: gh<_i862.SettingsService>(),
      ),
    );
    gh.lazySingleton<_i167.DownloadManager>(
      () => _i167.DownloadManager(
        podcastService: gh<_i529.PodcastService>(),
        downloadService: gh<_i881.DownloadService>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i971.RoutingManager>(
      () => _i971.RoutingManager(
        podcastService: gh<_i529.PodcastService>(),
        localAudioService: gh<_i985.LocalAudioService>(),
        radioService: gh<_i506.RadioService>(),
        settingsService: gh<_i862.SettingsService>(),
      ),
    );
    gh.lazySingleton<_i95.PlayerManager>(
      () => _i95.PlayerManager(service: gh<_i456.PlayerService>()),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i369.AppManager>(
      () => _i369.AppManager(
        packageInfo: gh<_i655.PackageInfo>(),
        settingsService: gh<_i862.SettingsService>(),
        gitHub: gh<_i535.GitHub>(),
        localAudioService: gh<_i985.LocalAudioService>(),
      ),
    );
    gh.lazySingleton<_i964.SettingsManager>(
      () => _i964.SettingsManager(
        service: gh<_i862.SettingsService>(),
        podcastService: gh<_i529.PodcastService>(),
        localAudioService: gh<_i985.LocalAudioService>(),
        radioService: gh<_i506.RadioService>(),
        playerService: gh<_i456.PlayerService>(),
      ),
    );
    gh.factory<_i354.SearchManager>(
      () => _i354.SearchManager.create(
        podcastService: gh<_i529.PodcastService>(),
        localAudioService: gh<_i985.LocalAudioService>(),
        settingsService: gh<_i862.SettingsService>(),
      ),
    );
    await gh.singletonAsync<_i517.WindowSizeToSettingsListener>(() {
      final i = _i517.WindowSizeToSettingsListener(
        sharedPreferences: gh<_i460.SharedPreferences>(),
        playerService: gh<_i456.PlayerService>(),
        windowManager: gh<_i740.WindowManager>(),
      );
      return i.init().then((_) => i);
    }, preResolve: true);
    gh.factory<_i851.PodcastUpdatesManager>(
      () => _i851.PodcastUpdatesManager.create(
        podcastService: gh<_i529.PodcastService>(),
        feedsManager: gh<_i605.PodcastUpdatedFeedsManager>(),
      ),
    );
    gh.lazySingleton<_i1055.SubscribedPodcastsManager>(
      () => _i1055.SubscribedPodcastsManager(
        podcastManager: gh<_i819.PodcastManager>(),
      ),
    );
    gh.factory<_i399.PodcastFeedsWithDownloadsManager>(
      () => _i399.PodcastFeedsWithDownloadsManager.create(
        podcastManager: gh<_i819.PodcastManager>(),
      ),
    );
    gh.factory<_i164.PlayAnywhereManager>(
      () => _i164.PlayAnywhereManager.create(
        playerManager: gh<_i95.PlayerManager>(),
      ),
    );
    gh.factoryParam<_i776.EpisodesManager, String, dynamic>(
      (feedUrl, _) => _i776.EpisodesManager.create(
        feedUrl: feedUrl,
        podcastManager: gh<_i819.PodcastManager>(),
        downloadsManager: gh<_i167.DownloadManager>(),
        playerManager: gh<_i95.PlayerManager>(),
      ),
    );
    gh.lazySingleton<_i314.CustomContentService>(
      () => _i314.CustomContentService(
        externalPathService: gh<_i415.ExternalPathService>(),
        localAudioService: gh<_i985.LocalAudioService>(),
        podcastService: gh<_i1055.SubscribedPodcastsManager>(),
        radioService: gh<_i506.RadioService>(),
      ),
    );
    return this;
  }
}

class _$DioModule extends _i1039.DioModule {}

class _$GithubModule extends _i207.GithubModule {}

class _$LocalNotifierModule extends _i8.LocalNotifierModule {}

class _$MediaKitModule extends _i94.MediaKitModule {}

class _$PackageInfoModule extends _i855.PackageInfoModule {}

class _$SharedPreferencesModule extends _i357.SharedPreferencesModule {}

class _$WindowManagerModule extends _i271.WindowManagerModule {}

class _$DatabaseModule extends _i440.DatabaseModule {}

class _$AudioServiceModule extends _i739.AudioServiceModule {}
