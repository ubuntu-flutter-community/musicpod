import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:flutter_test/flutter_test.dart';
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
import 'package:musicpod/podcasts/data/podcast_toggle_capsule.dart';
import 'package:musicpod/podcasts/manager/episodes_manager.dart';
import 'package:musicpod/podcasts/manager/podcast_short_info_manager.dart';
import 'package:musicpod/podcasts/manager/subscribed_podcasts_manager.dart';
import 'package:musicpod/podcasts/view/podcast_page_control_panel.dart';
import 'package:musicpod/settings/manager/settings_manager.dart';
import 'package:musicpod/settings/service/settings_service.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class FakePlayerManagerForControlPanel extends SafeChangeNotifier
    implements PlayerManager {
  @override
  Future<void> dispose() async {
    super.dispose();
  }

  @override
  bool isPlaying = false;

  @override
  Queue queue = const Queue.empty();

  List<Audio>? lastPlayedAudios;
  String? lastPlayedListName;

  @override
  Future<void> play({
    required List<Audio> audios,
    String? listName,
    int? index,
  }) async {
    lastPlayedAudios = audios;
    lastPlayedListName = listName;
  }

  bool playOrPauseCalled = false;
  @override
  Future<void> playOrPause() async {
    playOrPauseCalled = true;
  }

  @override
  late final Command<
    ({List<Audio> audios, bool markComplete})?,
    Map<String, Duration>?
  >
  toggleAudiosProgressCommand = Command.createAsync(
    (_) async => {},
    initialValue: null,
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeEpisodesManagerForControlPanel extends SafeChangeNotifier
    implements EpisodesManager {
  FakeEpisodesManagerForControlPanel({
    required this.loadedEpisodes,
    required this.allEpisodes,
    required this.hasMoreEpisodes,
  }) {
    command =
        Command.createSync<
          ({AudioSortOrder? order})?,
          ({List<Audio>? episodes, AudioSortOrder? order})?
        >(
          (_) => (episodes: loadedEpisodes, order: AudioSortOrder.descending),
          initialValue: (
            episodes: loadedEpisodes,
            order: AudioSortOrder.descending,
          ),
        );
  }

  final List<Audio> loadedEpisodes;
  final List<Audio> allEpisodes;
  final bool hasMoreEpisodes;

  @override
  late final Command<
    ({AudioSortOrder? order})?,
    ({List<Audio>? episodes, AudioSortOrder? order})?
  >
  command;

  @override
  bool get hasMore => hasMoreEpisodes;

  @override
  int get totalCount => allEpisodes.length;

  @override
  List<Audio> get allFilteredEpisodes => allEpisodes;

  @override
  final showSearch = SafeValueNotifier(false);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSubscribedPodcastsManagerForControlPanel extends SafeChangeNotifier
    implements SubscribedPodcastsManager {
  @override
  late final Command<PodcastToggleCapsule?, Set<String>> command =
      Command.createAsync((_) async => <String>{}, initialValue: <String>{});

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakePodcastShortInfoManagerForControlPanel extends SafeChangeNotifier
    implements PodcastShortInfoManager {
  @override
  late final Command<void, PodcastShortInfo?> command =
      Command.createSyncNoParam(
        () => const PodcastShortInfo(name: 'Test Podcast', artist: 'Test Host'),
        initialValue: const PodcastShortInfo(
          name: 'Test Podcast',
          artist: 'Test Host',
        ),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSettingsManagerForControlPanel extends SafeChangeNotifier
    implements SettingsManager {
  @override
  Future<void> dispose() async {
    super.dispose();
  }

  @override
  bool useYaruTheme = false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSettingsService implements SettingsService {
  @override
  int? getInt(String key) => 0;

  @override
  bool? getBool(String key) => false;

  @override
  String? getString(String key) => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const feedUrl = 'https://example.com/podcast.xml';

  late FakePlayerManagerForControlPanel playerManager;
  late FakeSettingsManagerForControlPanel settingsManager;
  late FakeSubscribedPodcastsManagerForControlPanel subscribedManager;
  late List<Audio> allEpisodes;
  late List<Audio> loadedEpisodes;

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

    playerManager = FakePlayerManagerForControlPanel();
    settingsManager = FakeSettingsManagerForControlPanel();
    subscribedManager = FakeSubscribedPodcastsManagerForControlPanel();

    GetIt.I.registerSingleton<SettingsService>(FakeSettingsService());
    GetIt.I.registerSingleton<PlayerManager>(playerManager);
    GetIt.I.registerSingleton<SettingsManager>(settingsManager);
    GetIt.I.registerSingleton<SubscribedPodcastsManager>(subscribedManager);
    GetIt.I.registerFactoryParam<PodcastShortInfoManager, String, void>(
      (url, _) => FakePodcastShortInfoManagerForControlPanel(),
    );
  });

  tearDown(() async {
    await Family.reset();
    await GetIt.I.reset();
  });

  Widget buildWidget(String url) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: PodcastPageControlPanel(feedUrl: url)),
    );
  }

  testWidgets('plays all directly when all episodes are already loaded', (
    tester,
  ) async {
    GetIt.I.registerFactoryParam<EpisodesManager, String, void>(
      (url, _) => FakeEpisodesManagerForControlPanel(
        loadedEpisodes: allEpisodes,
        allEpisodes: allEpisodes,
        hasMoreEpisodes: false,
      ),
    );

    await tester.pumpWidget(buildWidget(feedUrl));
    await tester.pump();

    final playAllButton = find.byType(AvatarPlayButton);
    expect(playAllButton, findsOneWidget);

    await tester.tap(playAllButton);
    await tester.pump();

    // No dialog shown
    expect(find.byType(ConfirmationDialog), findsNothing);
    // Player called with all episodes
    expect(playerManager.lastPlayedAudios?.length, equals(60));
    expect(playerManager.lastPlayedListName, equals(feedUrl));
  });

  testWidgets(
    'shows confirmation dialog when more episodes exist, and allows playing loaded subset',
    (tester) async {
      GetIt.I.registerFactoryParam<EpisodesManager, String, void>(
        (url, _) => FakeEpisodesManagerForControlPanel(
          loadedEpisodes: loadedEpisodes,
          allEpisodes: allEpisodes,
          hasMoreEpisodes: true,
        ),
      );

      await tester.pumpWidget(buildWidget(feedUrl));
      await tester.pump();

      final playAllButton = find.byType(AvatarPlayButton);
      await tester.tap(playAllButton);
      await tester.pumpAndSettle();

      // Dialog is displayed
      expect(find.byType(ConfirmationDialog), findsOneWidget);
      expect(
        find.textContaining('Play only the 25 loaded episodes or all 60'),
        findsOneWidget,
      );

      // Choose loaded subset: "Play (25)"
      final playSubsetButton = find.textContaining('(25)');
      expect(playSubsetButton, findsOneWidget);
      await tester.tap(playSubsetButton);
      await tester.pumpAndSettle();

      // Dialog dismissed
      expect(find.byType(ConfirmationDialog), findsNothing);

      // Only loaded episodes played
      expect(playerManager.lastPlayedAudios?.length, equals(25));
      expect(playerManager.lastPlayedListName, equals(feedUrl));
    },
  );

  testWidgets(
    'shows confirmation dialog when more episodes exist, and allows playing all episodes',
    (tester) async {
      GetIt.I.registerFactoryParam<EpisodesManager, String, void>(
        (url, _) => FakeEpisodesManagerForControlPanel(
          loadedEpisodes: loadedEpisodes,
          allEpisodes: allEpisodes,
          hasMoreEpisodes: true,
        ),
      );

      await tester.pumpWidget(buildWidget(feedUrl));
      await tester.pump();

      final playAllButton = find.byType(AvatarPlayButton);
      await tester.tap(playAllButton);
      await tester.pumpAndSettle();

      // Choose all episodes: "Play all (60)"
      final playAllOption = find.textContaining('(60)');
      expect(playAllOption, findsOneWidget);
      await tester.tap(playAllOption);
      await tester.pumpAndSettle();

      // Dialog dismissed
      expect(find.byType(ConfirmationDialog), findsNothing);

      // All episodes played
      expect(playerManager.lastPlayedAudios?.length, equals(60));
      expect(playerManager.lastPlayedListName, equals(feedUrl));
    },
  );

  testWidgets(
    'toggles play/pause when page feedUrl is already the active queue',
    (tester) async {
      playerManager.queue = Queue(name: feedUrl, audios: allEpisodes);

      GetIt.I.registerFactoryParam<EpisodesManager, String, void>(
        (url, _) => FakeEpisodesManagerForControlPanel(
          loadedEpisodes: loadedEpisodes,
          allEpisodes: allEpisodes,
          hasMoreEpisodes: true,
        ),
      );

      await tester.pumpWidget(buildWidget(feedUrl));
      await tester.pump();

      final playAllButton = find.byType(AvatarPlayButton);
      await tester.tap(playAllButton);
      await tester.pump();

      expect(playerManager.playOrPauseCalled, isTrue);
      expect(playerManager.lastPlayedAudios, isNull);
      expect(find.byType(ConfirmationDialog), findsNothing);
    },
  );
}
