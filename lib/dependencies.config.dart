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

import 'app/window_size_to_settings_listener.dart' as _i517;
import 'common/persistence/database.dart' as _i115;
import 'custom_content/service/custom_content_service.dart' as _i314;
import 'expose/service/expose_service.dart' as _i313;
import 'expose/service/lastfm_service.dart' as _i61;
import 'expose/service/listenbrainz_service.dart' as _i821;
import 'external_path/service/external_path_service.dart' as _i415;
import 'external_path/service/secure_bookmark_service.dart' as _i395;
import 'local_audio/persistence/local_audio_dao.dart' as _i688;
import 'local_audio/service/local_audio_service.dart' as _i985;
import 'local_audio/service/local_cover_service.dart' as _i582;
import 'lyrics/lyrics_service.dart' as _i546;
import 'notifications/notifications_service.dart' as _i57;
import 'player/persistence/player_dao.dart' as _i443;
import 'player/service/player_service.dart' as _i456;
import 'podcasts/persistence/podcast_dao.dart' as _i597;
import 'podcasts/service/download_service.dart' as _i881;
import 'podcasts/service/podcast_service.dart' as _i529;
import 'radio/persistence/radio_dao.dart' as _i414;
import 'radio/service/online_art_service.dart' as _i852;
import 'radio/service/radio_service.dart' as _i506;
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
    gh.lazySingleton<_i1009.LicenseStore>(() => _i1009.LicenseStore());
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
    gh.lazySingleton<_i985.LocalAudioService>(
      () => _i985.LocalAudioService(
        localCoverService: gh<_i582.LocalCoverService>(),
        settingsService: gh<_i862.SettingsService>(),
        localAudioDao: gh<_i688.LocalAudioDao>(),
      ),
    );
    gh.lazySingleton<_i314.CustomContentService>(
      () => _i314.CustomContentService(
        externalPathService: gh<_i415.ExternalPathService>(),
        localAudioService: gh<_i985.LocalAudioService>(),
        podcastService: gh<_i529.PodcastService>(),
        radioService: gh<_i506.RadioService>(),
      ),
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
    await gh.singletonAsync<_i517.WindowSizeToSettingsListener>(() {
      final i = _i517.WindowSizeToSettingsListener(
        sharedPreferences: gh<_i460.SharedPreferences>(),
        playerService: gh<_i456.PlayerService>(),
        windowManager: gh<_i740.WindowManager>(),
      );
      return i.init().then((_) => i);
    }, preResolve: true);
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
