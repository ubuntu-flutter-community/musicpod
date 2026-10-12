import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/common/data/audio.dart';
import 'package:musicpod/common/data/audio_type.dart';
import 'package:musicpod/common/view/languages.dart';
import 'package:musicpod/local_audio/service/local_audio_service.dart';
import 'package:musicpod/podcasts/data/podcast_genre.dart';
import 'package:musicpod/podcasts/service/podcast_service.dart';
import 'package:musicpod/radio/service/radio_service.dart';
import 'package:musicpod/search/data/search_type.dart';
import 'package:musicpod/search/manager/search_manager.dart';
import 'package:musicpod/settings/data/shared_preferences_keys.dart';
import 'package:musicpod/settings/service/settings_service.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:radio_browser_api/radio_browser_api.dart' hide Country;

import 'package:musicpod/l10n/app_localizations.dart';
import 'package:musicpod/search/view/sliver_radio_search_results.dart';

import 'search_manager_test.mocks.dart';

@GenerateMocks([
  RadioService,
  PodcastService,
  LocalAudioService,
  SettingsService,
])
void main() {
  late MockRadioService mockRadioService;
  late MockPodcastService mockPodcastService;
  late MockLocalAudioService mockLocalAudioService;
  late MockSettingsService mockSettingsService;

  setUp(() async {
    await GetIt.I.reset();
    mockRadioService = MockRadioService();
    mockPodcastService = MockPodcastService();
    mockLocalAudioService = MockLocalAudioService();
    mockSettingsService = MockSettingsService();

    when(
      mockSettingsService.getString(SPKeys.lastCountryCode),
    ).thenReturn(null);
    when(
      mockSettingsService.getString(SPKeys.lastLanguageCode),
    ).thenReturn(null);
    when(
      mockSettingsService.getString(SPKeys.selectedSearchAudioType),
    ).thenReturn(null);
    when(mockSettingsService.setValue(any, any)).thenAnswer((_) async => true);

    GetIt.I.registerSingleton<RadioService>(mockRadioService);
    GetIt.I.registerSingleton<PodcastService>(mockPodcastService);
    GetIt.I.registerSingleton<LocalAudioService>(mockLocalAudioService);
    GetIt.I.registerSingleton<SettingsService>(mockSettingsService);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  test('SearchManager initializes with default settings and values', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state = container.read(searchManagerProvider);
    expect(state.audioType, AudioType.podcast);
    expect(state.searchTypes, {SearchType.podcastTitle});
    expect(state.searchType, SearchType.podcastTitle);
    expect(state.podcastLimit, SearchManager.podcastDefaultLimit);
    expect(state.radioLimit, SearchManager.radioDefaultLimit);
    expect(state.isLoading, false);
    expect(state.error, isNull);
  });

  test('SearchManager updates filters and persists audio type in settings', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(searchManagerProvider.notifier);

    notifier.setAudioType(AudioType.radio);
    expect(container.read(searchManagerProvider).audioType, AudioType.radio);
    verify(
      mockSettingsService.setValue(
        SPKeys.selectedSearchAudioType,
        AudioType.radio.name,
      ),
    ).called(1);

    notifier.setPodcastGenre(PodcastGenre.music);
    expect(
      container.read(searchManagerProvider).podcastGenre,
      PodcastGenre.music,
    );

    notifier.setPodcastSearchAttribute(Attribute.title);
    expect(
      container.read(searchManagerProvider).podcastSearchAttribute,
      Attribute.title,
    );

    notifier.incrementPodcastLimit(16);
    expect(
      container.read(searchManagerProvider).podcastLimit,
      SearchManager.podcastDefaultLimit + 16,
    );

    notifier.incrementRadioLimit(16);
    expect(
      container.read(searchManagerProvider).radioLimit,
      SearchManager.radioDefaultLimit + 16,
    );

    notifier.setSearchQuery('classical');
    expect(container.read(searchManagerProvider).searchQuery, 'classical');

    const tag = Tag(name: 'rock', stationCount: 10);
    notifier.setTag(tag);
    expect(container.read(searchManagerProvider).tag, tag);

    notifier.setCountry(Country.germany);
    expect(container.read(searchManagerProvider).country, Country.germany);

    final lang = SimpleLanguage('de', 'German');
    notifier.setLanguage(lang);
    expect(container.read(searchManagerProvider).language, lang);
  });

  test('SearchManager executes radio search and sets results', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    const stationAudio = Audio(
      url: 'http://example.com/s1',
      title: 'Station 1',
      audioType: AudioType.radio,
    );
    when(
      mockRadioService.search(name: 'test', limit: 64),
    ).thenAnswer((_) async => [stationAudio]);

    final notifier = container.read(searchManagerProvider.notifier);
    notifier.setAudioType(AudioType.radio);
    notifier.setSearchQuery('test');
    await notifier.refresh();

    final state = container.read(searchManagerProvider);
    expect(state.isLoading, false);
    expect(state.radioSearchResult, [stationAudio]);
    expect(state.error, isNull);
  });

  test('SearchManager handles podcast search errors gracefully', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    when(
      mockPodcastService.search(
        searchQuery: anyNamed('searchQuery'),
        limit: anyNamed('limit'),
        podcastGenre: anyNamed('podcastGenre'),
        country: anyNamed('country'),
        language: anyNamed('language'),
        attribute: anyNamed('attribute'),
      ),
    ).thenThrow(Exception('Search error'));

    final notifier = container.read(searchManagerProvider.notifier);
    notifier.setAudioType(AudioType.podcast);
    notifier.setSearchQuery('error-query');
    await notifier.refresh();

    final state = container.read(searchManagerProvider);
    expect(state.isLoading, false);
    expect(state.error, isNotNull);
  });

  test('SearchManager autoDisposes when no listeners remain', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final sub = container.listen(searchManagerProvider, (_, __) {});
    final notifier = container.read(searchManagerProvider.notifier);
    notifier.setSearchQuery('query to be disposed');
    expect(
      container.read(searchManagerProvider).searchQuery,
      'query to be disposed',
    );

    // Close subscription: auto-dispose triggers
    sub.close();
    await Future<void>.delayed(Duration.zero);

    // Reading again should instantiate a brand new state (query is null)
    expect(container.read(searchManagerProvider).searchQuery, isNull);
  });

  testWidgets('SliverRadioSearchResults builds without assertion error', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: CustomScrollView(
              slivers: [SliverRadioSearchResults(width: 800)],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(SliverRadioSearchResults), findsOneWidget);
  });
}
