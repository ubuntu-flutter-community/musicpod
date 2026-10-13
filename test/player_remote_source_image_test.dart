import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/common/data/audio.dart';
import 'package:musicpod/common/data/audio_type.dart';
import 'package:musicpod/common/view/icons.dart';
import 'package:musicpod/common/view/progress.dart';
import 'package:musicpod/common/view/safe_network_image.dart';
import 'package:musicpod/l10n/app_localizations.dart';
import 'package:musicpod/player/data/mpv_meta_data.dart';
import 'package:musicpod/player/manager/current_audio_manager.dart';
import 'package:musicpod/player/manager/mpv_metadata_manager.dart';
import 'package:musicpod/player/view/player_remote_source_image.dart';
import 'package:musicpod/radio/service/online_art_service.dart';
import 'package:musicpod/radio/view/radio_history_tile_image.dart';
import 'package:musicpod/settings/data/shared_preferences_keys.dart';
import 'package:musicpod/settings/service/settings_service.dart';

import 'player_remote_source_image_test.mocks.dart';

@GenerateMocks([SettingsService, OnlineArtService])
void main() {
  late MockSettingsService mockSettingsService;
  late MockOnlineArtService mockOnlineArtService;

  setUp(() async {
    await GetIt.I.reset();
    mockSettingsService = MockSettingsService();
    mockOnlineArtService = MockOnlineArtService();

    when(mockSettingsService.getInt(any)).thenReturn(0);
    when(mockSettingsService.getBool(any)).thenReturn(false);
    when(mockSettingsService.getBool(SPKeys.useYaruTheme)).thenReturn(true);
    when(mockSettingsService.getString(any)).thenReturn(null);

    GetIt.I.registerSingleton<SettingsService>(mockSettingsService);
    GetIt.I.registerSingleton<OnlineArtService>(mockOnlineArtService);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  Widget buildPlayerImage() {
    return MaterialApp(
      theme: ThemeData(platform: TargetPlatform.linux),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(
        body: PlayerRemoteSourceImage(
          height: 100,
          width: 100,
          fit: BoxFit.cover,
          fallBackIcon: Icon(Icons.music_note, key: Key('fallback')),
          errorIcon: Icon(Icons.error, key: Key('error')),
        ),
      ),
    );
  }

  Widget buildRadioHistoryImage(String icyTitle) {
    return MaterialApp(
      theme: ThemeData(platform: TargetPlatform.linux),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: RadioHistoryTileImage(icyTitle: icyTitle, height: 40, width: 40),
      ),
    );
  }

  group('PlayerRemoteSourceImage', () {
    testWidgets('shows fallBackIcon when current audio is null', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          currentAudioManagerProvider.overrideWith(
            () => _FakeCurrentAudioManager(null),
          ),
        ],
      );
      try {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: buildPlayerImage(),
          ),
        );

        expect(find.byKey(const Key('fallback')), findsOneWidget);
        expect(find.byType(SafeNetworkImage), findsNothing);
        expect(find.byType(Progress), findsNothing);
      } finally {
        container.dispose();
      }
    });

    testWidgets(
      'shows SafeNetworkImage with audio imageUrl for non-radio audio',
      (tester) async {
        const audio = Audio(
          audioType: AudioType.podcast,
          imageUrl: 'https://example.com/podcast.jpg',
        );
        final container = ProviderContainer(
          overrides: [
            currentAudioManagerProvider.overrideWith(
              () => _FakeCurrentAudioManager(audio),
            ),
          ],
        );
        try {
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: buildPlayerImage(),
            ),
          );

          expect(find.byType(SafeNetworkImage), findsOneWidget);
          final imageWidget = tester.widget<SafeNetworkImage>(
            find.byType(SafeNetworkImage),
          );
          expect(imageWidget.url, 'https://example.com/podcast.jpg');
          expect(find.byType(Progress), findsNothing);
        } finally {
          container.dispose();
        }
      },
    );

    testWidgets(
      'shows Progress overlay when radio metadata is loading, then updates with resolved image',
      (tester) async {
        const stationAudio = Audio(
          audioType: AudioType.radio,
          imageUrl: 'https://example.com/station.jpg',
        );
        final metadataNotifier = _FakeMpvMetadataManager(null);

        final artCompleter = Completer<String?>();
        when(
          mockOnlineArtService.fetchAlbumArt(
            icyTitle: 'Queen - Bohemian Rhapsody',
          ),
        ).thenAnswer((_) => artCompleter.future);

        final container = ProviderContainer(
          overrides: [
            currentAudioManagerProvider.overrideWith(
              () => _FakeCurrentAudioManager(stationAudio),
            ),
            mpvMetadataManagerProvider.overrideWith(() => metadataNotifier),
          ],
        );
        try {
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: buildPlayerImage(),
            ),
          );

          // Initially no MPV metadata -> shows station image, no progress
          expect(find.byType(SafeNetworkImage), findsOneWidget);
          var imageWidget = tester.widget<SafeNetworkImage>(
            find.byType(SafeNetworkImage),
          );
          expect(imageWidget.url, 'https://example.com/station.jpg');
          expect(find.byType(Progress), findsNothing);

          // New ICY title arrives
          metadataNotifier.update(
            MpvMetaData(
              icyBr: '',
              icyGenre: '',
              icyName: 'Radio 1',
              icyUrl: '',
              icyAudioInfo: '',
              icyPub: '',
              icyDescription: '',
              icyTitle: 'Queen - Bohemian Rhapsody',
            ),
          );
          await tester.pump();

          // While onlineArtManagerProvider is loading, Progress is displayed!
          expect(find.byType(Progress), findsOneWidget);
          expect(find.byType(SafeNetworkImage), findsOneWidget);

          // Resolve the online art
          artCompleter.complete('https://example.com/queen.jpg');
          await tester.pump();
          await tester.pump();

          // Loading is done: Progress is gone, and url is the new album art!
          expect(find.byType(Progress), findsNothing);
          expect(find.byType(SafeNetworkImage), findsOneWidget);
          imageWidget = tester.widget<SafeNetworkImage>(
            find.byType(SafeNetworkImage),
          );
          expect(imageWidget.url, 'https://example.com/queen.jpg');
        } finally {
          container.dispose();
        }
      },
    );
  });

  group('RadioHistoryTileImage', () {
    testWidgets(
      'displays Progress while loading, then SafeNetworkImage on success',
      (tester) async {
        final artCompleter = Completer<String?>();
        when(
          mockOnlineArtService.fetchAlbumArt(icyTitle: 'Beatles - Help'),
        ).thenAnswer((_) => artCompleter.future);

        final container = ProviderContainer();
        try {
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: buildRadioHistoryImage('Beatles - Help'),
            ),
          );

          // Loading state: Progress spinner shown
          expect(find.byType(Progress), findsOneWidget);
          expect(find.byType(SafeNetworkImage), findsNothing);

          // Complete with URL
          artCompleter.complete('https://example.com/beatles.jpg');
          await tester.pump();
          await tester.pump();

          expect(find.byType(Progress), findsNothing);
          expect(find.byType(SafeNetworkImage), findsOneWidget);
          final img = tester.widget<SafeNetworkImage>(
            find.byType(SafeNetworkImage),
          );
          expect(img.url, 'https://example.com/beatles.jpg');
        } finally {
          container.dispose();
        }
      },
    );

    testWidgets('displays radio icon when online art resolves to null', (
      tester,
    ) async {
      final artCompleter = Completer<String?>();
      when(
        mockOnlineArtService.fetchAlbumArt(icyTitle: 'Unknown - Track'),
      ).thenAnswer((_) => artCompleter.future);

      final container = ProviderContainer();
      try {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: buildRadioHistoryImage('Unknown - Track'),
          ),
        );

        expect(find.byType(Progress), findsOneWidget);

        artCompleter.complete(null);
        await tester.pump();
        await tester.pump();

        expect(find.byType(Progress), findsNothing);
        expect(find.byType(SafeNetworkImage), findsNothing);
        expect(find.byIcon(Iconz.radio), findsOneWidget);
      } finally {
        container.dispose();
      }
    });
  });
}

class _FakeCurrentAudioManager extends CurrentAudioManager {
  _FakeCurrentAudioManager(this._initial);
  final Audio? _initial;

  @override
  Audio? build() => _initial;
}

class _FakeMpvMetadataManager extends MpvMetadataManager {
  _FakeMpvMetadataManager(this._initial);
  final MpvMetaData? _initial;

  @override
  MpvMetaData? build() => _initial;

  void update(MpvMetaData? data) {
    state = data;
  }
}
