import 'package:flutter_it/flutter_it.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/common/persistence/database.dart';
import 'package:musicpod/local_audio/manager/local_audio_manager.dart';
import 'package:musicpod/local_audio/manager/pinned_album_ids_manager.dart';
import 'package:musicpod/local_audio/service/local_audio_service.dart';
import 'package:musicpod/player/manager/player_manager.dart';
import 'package:musicpod/podcasts/data/podcast_toggle_capsule.dart';
import 'package:musicpod/podcasts/manager/subscribed_podcasts_manager.dart';
import 'package:musicpod/podcasts/service/podcast_service.dart';
import 'package:musicpod/radio/manager/radio_fav_tag_manager.dart';
import 'package:musicpod/radio/manager/radio_star_station_manager.dart';
import 'package:musicpod/radio/service/radio_service.dart';
import 'package:musicpod/settings/manager/settings_manager.dart';
import 'package:musicpod/settings/manager/wipe_manager.dart';

import 'wipe_manager_test.mocks.dart';

@GenerateMocks([
  PodcastService,
  RadioService,
  LocalAudioService,
  Database,
  PlayerManager,
  SubscribedPodcastsManager,
  SettingsManager,
])
void main() {
  late MockPodcastService mockPodcastService;
  late MockRadioService mockRadioService;
  late MockLocalAudioService mockLocalAudioService;
  late MockDatabase mockDatabase;
  late MockPlayerManager mockPlayerManager;
  late MockSubscribedPodcastsManager mockSubscribedPodcastsManager;
  late MockSettingsManager mockSettingsManager;

  setUp(() async {
    await GetIt.I.reset();

    mockPodcastService = MockPodcastService();
    mockRadioService = MockRadioService();
    mockLocalAudioService = MockLocalAudioService();
    mockDatabase = MockDatabase();
    mockPlayerManager = MockPlayerManager();
    mockSubscribedPodcastsManager = MockSubscribedPodcastsManager();
    mockSettingsManager = MockSettingsManager();

    // Default stubbing
    when(mockPodcastService.wipeAndBuildPodcastLibrary())
        .thenAnswer((_) async {});
    when(mockRadioService.wipeRadioLibrary()).thenAnswer((_) async {});
    when(
      mockLocalAudioService.init(
        newDirectory: anyNamed('newDirectory'),
        forceInit: anyNamed('forceInit'),
        updateProgress: anyNamed('updateProgress'),
      ),
    ).thenAnswer((_) async => (failedImports: <String>[]));
    when(mockLocalAudioService.findPinnedAlbumIDs())
        .thenAnswer((_) async => const <int>[]);
    when(mockDatabase.reclaimDiskSpace()).thenAnswer((_) async {});
    when(mockPlayerManager.clearAllLastPositions()).thenAnswer((_) async {});
    when(mockPlayerManager.resetPlayerState()).thenAnswer((_) async {});

    final subCmd = Command.createAsync<PodcastToggleCapsule?, Set<String>>(
      (_) async => {},
      initialValue: {},
    );
    when(mockSubscribedPodcastsManager.command).thenReturn(subCmd);

    final settingsCmd = Command.createAsyncNoParamNoResult(() async {});
    when(mockSettingsManager.wipeAllSettingsCommand).thenReturn(settingsCmd);

    GetIt.I.registerSingleton<PodcastService>(mockPodcastService);
    GetIt.I.registerSingleton<RadioService>(mockRadioService);
    GetIt.I.registerSingleton<LocalAudioService>(mockLocalAudioService);
    GetIt.I.registerSingleton<Database>(mockDatabase);
    GetIt.I.registerSingleton<PlayerManager>(mockPlayerManager);
    GetIt.I.registerSingleton<SubscribedPodcastsManager>(
      mockSubscribedPodcastsManager,
    );
    GetIt.I.registerSingleton<SettingsManager>(mockSettingsManager);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  test('wipe({WipeType.localAudio}) initializes localAudioService with empty directory and invalidates providers', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    var localAudioInvalidated = false;
    var pinnedAlbumsInvalidated = false;

    container.listen(localAudioManagerProvider, (_, __) {
      localAudioInvalidated = true;
    });
    container.listen(pinnedAlbumIDsManagerProvider, (_, __) {
      pinnedAlbumsInvalidated = true;
    });

    await container.read(wipeManagerProvider.notifier).wipe({WipeType.localAudio});
    await pumpEventQueue();

    verify(
      mockLocalAudioService.init(
        newDirectory: '',
        forceInit: true,
      ),
    ).called(1);

    verify(mockDatabase.reclaimDiskSpace()).called(1);
    expect(localAudioInvalidated, isTrue);
    expect(pinnedAlbumsInvalidated, isTrue);
  });

  test('wipe({WipeType.radio}) wipes radio library and invalidates star station and fav tag providers', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    var starStationInvalidated = false;
    var favTagInvalidated = false;

    container.listen(radioStarStationManagerProvider, (_, __) {
      starStationInvalidated = true;
    });
    container.listen(radioFavTagManagerProvider, (_, __) {
      favTagInvalidated = true;
    });

    await container.read(wipeManagerProvider.notifier).wipe({WipeType.radio});

    verify(mockRadioService.wipeRadioLibrary()).called(1);
    verify(mockDatabase.reclaimDiskSpace()).called(1);
    expect(starStationInvalidated, isTrue);
    expect(favTagInvalidated, isTrue);
  });

  test('wipe({WipeType.podcasts}) wipes podcast library, clears positions, and runs subscribed command', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(wipeManagerProvider.notifier).wipe({WipeType.podcasts});

    verify(mockPodcastService.wipeAndBuildPodcastLibrary()).called(1);
    verify(mockPlayerManager.clearAllLastPositions()).called(1);
    verify(mockDatabase.reclaimDiskSpace()).called(1);
  });

  test('wipe() with no arguments wipes all types and reclaims disk space', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(wipeManagerProvider.notifier).wipe();

    verify(mockPodcastService.wipeAndBuildPodcastLibrary()).called(1);
    verify(mockRadioService.wipeRadioLibrary()).called(1);
    verify(
      mockLocalAudioService.init(
        newDirectory: '',
        forceInit: true,
      ),
    ).called(1);
    verify(mockPlayerManager.resetPlayerState()).called(1);
    verify(mockSettingsManager.wipeAllSettingsCommand).called(greaterThanOrEqualTo(1));
    verify(mockDatabase.reclaimDiskSpace()).called(1);
  });
}
