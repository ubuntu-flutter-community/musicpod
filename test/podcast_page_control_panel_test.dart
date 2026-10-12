import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/common/data/audio.dart';
import 'package:musicpod/common/data/audio_type.dart';
import 'package:musicpod/common/util/family.dart';
import 'package:musicpod/common/view/audio_filter.dart';
import 'package:musicpod/common/view/avatar_play_button.dart';
import 'package:musicpod/common/view/confirm.dart';
import 'package:musicpod/l10n/app_localizations.dart';
import 'package:musicpod/player/data/queue.dart';
import 'package:musicpod/player/manager/player_manager.dart';
import 'package:musicpod/podcasts/data/podcast_short_info.dart';
import 'package:musicpod/podcasts/manager/episodes_manager.dart';
import 'package:musicpod/podcasts/service/podcast_service.dart';
import 'package:musicpod/podcasts/view/podcast_page_control_panel.dart';
import 'package:musicpod/settings/service/settings_service.dart';

import 'podcast_page_control_panel_test.mocks.dart';

@GenerateMocks([
  PlayerManager,
  SettingsService,
  PodcastService,
])
class FakeEpisodesManager extends EpisodesManager {
  FakeEpisodesManager(this.episodesState);
  final EpisodesState episodesState;

  @override
  Future<EpisodesState> build(String feedUrl) async => episodesState;
}

void main() {
  const feedUrl = 'https://example.com/podcast.xml';

  late MockPlayerManager mockPlayerManager;
  late MockSettingsService mockSettingsService;
  late MockPodcastService mockPodcastService;
  late List<Audio> allEpisodes;
  late List<Audio> loadedEpisodes;

  EpisodesState createEpisodesState({
    required List<Audio> loadedEpisodes,
    required List<Audio> allEpisodes,
    required bool hasMoreEpisodes,
  }) {
    return EpisodesState(
      allEpisodes: allEpisodes,
      episodes: loadedEpisodes,
      displayedCount: loadedEpisodes.length,
      totalCount: allEpisodes.length,
      hasMore: hasMoreEpisodes,
      order: AudioSortOrder.descending,
    );
  }

  setUp(() async {
    await Family.reset();
    await GetIt.I.reset();

    allEpisodes = List.generate(
      60,
      (i) => Audio(
        audioType: AudioType.podcast,
        url: 'https://example.com/ep$i.mp3',
        feedUrl: feedUrl,
        title: 'Episode ${i + 1}',
      ),
    );
    loadedEpisodes = allEpisodes.take(25).toList();

    mockPlayerManager = MockPlayerManager();
    mockSettingsService = MockSettingsService();
    mockPodcastService = MockPodcastService();

    when(mockPlayerManager.isPlaying).thenReturn(false);
    when(mockPlayerManager.queue).thenReturn(const Queue.empty());
    when(
      mockPlayerManager.play(
        audios: anyNamed('audios'),
        listName: anyNamed('listName'),
        index: anyNamed('index'),
      ),
    ).thenAnswer((_) async {});
    when(mockPlayerManager.playOrPause()).thenAnswer((_) async {});

    when(mockSettingsService.getInt(any)).thenReturn(0);
    when(mockSettingsService.getBool(any)).thenReturn(false);
    when(mockSettingsService.getString(any)).thenReturn(null);

    when(mockPodcastService.getPodcastShortInfo(any)).thenAnswer(
      (_) async => const PodcastShortInfo(
        name: 'Test Podcast',
        artist: 'Test Host',
      ),
    );

    GetIt.I.registerSingleton<SettingsService>(mockSettingsService);
    GetIt.I.registerSingleton<PlayerManager>(mockPlayerManager);
    GetIt.I.registerSingleton<PodcastService>(mockPodcastService);
  });

  tearDown(() async {
    await Family.reset();
    await GetIt.I.reset();
  });

  Widget buildWidget(String url, {EpisodesState? state}) {
    return ProviderScope(
      overrides: [
        if (state != null)
          episodesManagerProvider(url).overrideWith(
            () => FakeEpisodesManager(state),
          ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: PodcastPageControlPanel(feedUrl: url)),
      ),
    );
  }

  testWidgets('plays all directly when all episodes are already loaded', (
    tester,
  ) async {
    final state = createEpisodesState(
      loadedEpisodes: allEpisodes,
      allEpisodes: allEpisodes,
      hasMoreEpisodes: false,
    );

    await tester.pumpWidget(buildWidget(feedUrl, state: state));
    await tester.pump();

    final playAllButton = find.byType(AvatarPlayButton);
    expect(playAllButton, findsOneWidget);

    await tester.tap(playAllButton);
    await tester.pump();

    // No dialog shown
    expect(find.byType(ConfirmationDialog), findsNothing);
    // Player called with all episodes
    verify(
      mockPlayerManager.play(audios: allEpisodes, listName: feedUrl),
    ).called(1);
  });

  testWidgets(
    'shows confirmation dialog when more episodes exist, and allows playing loaded subset',
    (tester) async {
      final state = createEpisodesState(
        loadedEpisodes: loadedEpisodes,
        allEpisodes: allEpisodes,
        hasMoreEpisodes: true,
      );

      await tester.pumpWidget(buildWidget(feedUrl, state: state));
      await tester.pump();

      final playAllButton = find.byType(AvatarPlayButton);
      await tester.tap(playAllButton);
      await tester.pumpAndSettle();

      // Dialog is displayed
      expect(find.byType(ConfirmationDialog), findsOneWidget);
      expect(find.text('Play all?'), findsOneWidget);

      // Choose loaded subset: "Play only 25"
      final playSubsetButton = find.text('Play only 25');
      expect(playSubsetButton, findsOneWidget);
      await tester.tap(playSubsetButton);
      await tester.pumpAndSettle();

      // Dialog dismissed
      expect(find.byType(ConfirmationDialog), findsNothing);

      // Only loaded episodes played
      verify(
        mockPlayerManager.play(audios: loadedEpisodes, listName: feedUrl),
      ).called(1);
    },
  );

  testWidgets(
    'shows confirmation dialog when more episodes exist, and allows playing all episodes',
    (tester) async {
      final state = createEpisodesState(
        loadedEpisodes: loadedEpisodes,
        allEpisodes: allEpisodes,
        hasMoreEpisodes: true,
      );

      await tester.pumpWidget(buildWidget(feedUrl, state: state));
      await tester.pump();

      final playAllButton = find.byType(AvatarPlayButton);
      await tester.tap(playAllButton);
      await tester.pumpAndSettle();

      // Dialog is displayed
      expect(find.byType(ConfirmationDialog), findsOneWidget);

      // Choose all episodes: "Play all 60"
      final playAllOption = find.text('Play all 60');
      expect(playAllOption, findsOneWidget);
      await tester.tap(playAllOption);
      await tester.pumpAndSettle();

      // Dialog dismissed
      expect(find.byType(ConfirmationDialog), findsNothing);

      // All episodes played
      verify(
        mockPlayerManager.play(audios: allEpisodes, listName: feedUrl),
      ).called(1);
    },
  );

  testWidgets(
    'toggles play/pause when page feedUrl is already the active queue',
    (tester) async {
      when(
        mockPlayerManager.queue,
      ).thenReturn(Queue(name: feedUrl, audios: allEpisodes));

      final state = createEpisodesState(
        loadedEpisodes: loadedEpisodes,
        allEpisodes: allEpisodes,
        hasMoreEpisodes: true,
      );

      await tester.pumpWidget(buildWidget(feedUrl, state: state));
      await tester.pump();

      final playAllButton = find.byType(AvatarPlayButton);
      await tester.tap(playAllButton);
      await tester.pump();

      verify(mockPlayerManager.playOrPause()).called(1);
      verifyNever(
        mockPlayerManager.play(
          audios: anyNamed('audios'),
          listName: anyNamed('listName'),
        ),
      );
      expect(find.byType(ConfirmationDialog), findsNothing);
    },
  );
}
