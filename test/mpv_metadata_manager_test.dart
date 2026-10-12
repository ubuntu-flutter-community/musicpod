import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_kit/media_kit.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/common/data/audio.dart';
import 'package:musicpod/common/data/audio_type.dart';
import 'package:musicpod/dependencies.dart';
import 'package:musicpod/expose/service/expose_service.dart';
import 'package:musicpod/player/data/mpv_meta_data.dart';
import 'package:musicpod/player/manager/blocked_icy_titles_manager.dart';
import 'package:musicpod/player/manager/mpv_metadata_history_manager.dart';
import 'package:musicpod/player/manager/mpv_metadata_manager.dart';
import 'package:musicpod/player/service/player_service.dart';
import 'package:musicpod/radio/service/online_art_service.dart';
import 'package:musicpod/settings/data/shared_preferences_keys.dart';
import 'package:musicpod/settings/service/settings_service.dart';

import 'mpv_metadata_manager_test.mocks.dart';

MpvMetaData createMeta({
  String icyTitle = '',
  String icyName = '',
  String icyDescription = '',
}) => MpvMetaData(
  icyBr: '128',
  icyGenre: 'Pop',
  icyName: icyName,
  icyUrl: '',
  icyAudioInfo: '',
  icyPub: '',
  icyDescription: icyDescription,
  icyTitle: icyTitle,
);

@GenerateMocks([
  PlayerService,
  ExposeService,
  OnlineArtService,
  SettingsService,
  Player,
  PlayerStream,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late MockPlayerService mockPlayerService;
  late MockExposeService mockExposeService;
  late MockOnlineArtService mockOnlineArtService;
  late MockSettingsService mockSettingsService;
  late MockPlayer mockPlayer;
  late MockPlayerStream mockPlayerStream;

  late StreamController<bool> playingController;
  late StreamController<Audio?> newAudioController;

  setUp(() async {
    await GetIt.I.reset();
    mockPlayerService = MockPlayerService();
    mockExposeService = MockExposeService();
    mockOnlineArtService = MockOnlineArtService();
    mockSettingsService = MockSettingsService();
    mockPlayer = MockPlayer();
    mockPlayerStream = MockPlayerStream();

    playingController = StreamController<bool>.broadcast();
    newAudioController = StreamController<Audio?>.broadcast();

    when(mockPlayerStream.playing).thenAnswer((_) => playingController.stream);
    when(mockPlayer.stream).thenReturn(mockPlayerStream);
    when(mockPlayer.state).thenReturn(const PlayerState());
    when(mockPlayer.platform).thenReturn(null);
    when(mockPlayerService.player).thenReturn(mockPlayer);
    when(
      mockPlayerService.newAudioStream,
    ).thenAnswer((_) => newAudioController.stream);

    when(
      mockSettingsService.getStringList(SPKeys.blockedIcyTitles),
    ).thenReturn(null);
    when(mockSettingsService.setValue(any, any)).thenAnswer((_) async => true);
    when(mockSettingsService.getBool(SPKeys.dataSafeMode)).thenReturn(false);

    di.registerSingleton<SettingsService>(mockSettingsService);
    di.registerSingleton<PlayerService>(mockPlayerService);
    di.registerSingleton<ExposeService>(mockExposeService);
    di.registerSingleton<OnlineArtService>(mockOnlineArtService);

    container = ProviderContainer();
  });

  tearDown(() {
    playingController.close();
    newAudioController.close();
    container.dispose();
  });

  group('BlockedIcyTitlesManager', () {
    test('initializes with default blocked titles when empty', () {
      final titles = container.read(blockedIcyTitlesManagerProvider);
      expect(titles, contains('.westlotto.de'));
      expect(titles, contains('Werbung'));
    });

    test('add and remove modify state and save to settings', () async {
      final manager = container.read(blockedIcyTitlesManagerProvider.notifier);
      await manager.add('TestAd');
      expect(
        container.read(blockedIcyTitlesManagerProvider),
        contains('TestAd'),
      );

      await manager.remove('TestAd');
      expect(
        container.read(blockedIcyTitlesManagerProvider),
        isNot(contains('TestAd')),
      );
    });
  });

  group('MpvMetadataHistoryManager', () {
    test('adds, filters, and retrieves metadata history', () {
      final historyNotifier = container.read(
        mpvMetadataHistoryManagerProvider.notifier,
      );
      expect(container.read(mpvMetadataHistoryManagerProvider), isEmpty);

      final meta1 = createMeta(
        icyTitle: 'Artist - Song 1',
        icyName: 'Radio Station',
      );
      final meta2 = createMeta(
        icyTitle: 'Artist - Song 2',
        icyName: 'Another Station',
      );

      historyNotifier.add(icyTitle: meta1.icyTitle, mpvMetaData: meta1);
      historyNotifier.add(icyTitle: meta2.icyTitle, mpvMetaData: meta2);

      final state = container.read(mpvMetadataHistoryManagerProvider);
      expect(state.length, 2);
      expect(historyNotifier.getMetadata('Artist - Song 1'), equals(meta1));

      final filtered = historyNotifier.filteredHistory(filter: 'Radio Station');
      expect(filtered.length, 1);
      expect(filtered.first.value.icyTitle, 'Artist - Song 1');

      historyNotifier.remove('Artist - Song 1');
      expect(container.read(mpvMetadataHistoryManagerProvider).length, 1);
    });
  });

  group('MpvMetadataManager', () {
    test('isValidHistoryElement rejects blocked titles and descriptions', () {
      final manager = container.read(mpvMetadataManagerProvider.notifier);

      expect(
        manager.isValidHistoryElement(
          createMeta(icyTitle: 'Visit .westlotto.de for info'),
        ),
        isFalse,
      );

      expect(
        manager.isValidHistoryElement(
          createMeta(
            icyTitle: 'Radio Station Jingle',
            icyDescription: 'Radio Station',
          ),
        ),
        isFalse,
      );

      expect(
        manager.isValidHistoryElement(
          createMeta(icyTitle: 'Queen - Bohemian Rhapsody'),
        ),
        isTrue,
      );
    });

    test(
      'digestMpvMetaData updates state, history, and triggers artwork and expose',
      () async {
        when(
          mockPlayerService.audio,
        ).thenReturn(const Audio(audioType: AudioType.radio, title: 'Rock FM'));
        when(
          mockOnlineArtService.fetchAlbumArt(icyTitle: anyNamed('icyTitle')),
        ).thenAnswer((_) async => 'https://example.com/art.jpg');
        when(
          mockPlayerService.setMediaControlsMetaData(audio: anyNamed('audio')),
        ).thenAnswer((_) async {});
        when(
          mockExposeService.exposeTitleOnline(
            title: anyNamed('title'),
            artist: anyNamed('artist'),
            additionalInfo: anyNamed('additionalInfo'),
            imageUrl: anyNamed('imageUrl'),
          ),
        ).thenAnswer((_) async {});

        final manager = container.read(mpvMetadataManagerProvider.notifier);
        final meta = createMeta(
          icyTitle: 'Queen - Bohemian Rhapsody',
          icyName: 'Rock FM',
        );

        await manager.digestMpvMetaData(meta);

        final state = container.read(mpvMetadataManagerProvider);
        expect(state, isNotNull);
        expect(state?.icyTitle, 'Queen - Bohemian Rhapsody');
        expect(state?.icyName, 'Rock FM');

        // History should be updated
        final history = container.read(mpvMetadataHistoryManagerProvider);
        expect(history.containsKey('Queen - Bohemian Rhapsody'), isTrue);

        // Verify side effects
        verify(
          mockOnlineArtService.fetchAlbumArt(
            icyTitle: 'Queen - Bohemian Rhapsody',
          ),
        ).called(1);
        verify(
          mockExposeService.exposeTitleOnline(
            title: 'Bohemian Rhapsody',
            artist: 'Queen',
            additionalInfo: 'Rock FM',
            imageUrl: 'https://example.com/art.jpg',
          ),
        ).called(1);
      },
    );

    test('honors dataSafeMode by skipping fetchAlbumArt', () async {
      when(mockSettingsService.getBool(SPKeys.dataSafeMode)).thenReturn(true);
      when(
        mockPlayerService.audio,
      ).thenReturn(const Audio(audioType: AudioType.radio, title: 'Rock FM'));
      when(
        mockPlayerService.setMediaControlsMetaData(audio: anyNamed('audio')),
      ).thenAnswer((_) async {});
      when(
        mockExposeService.exposeTitleOnline(
          title: anyNamed('title'),
          artist: anyNamed('artist'),
          additionalInfo: anyNamed('additionalInfo'),
          imageUrl: anyNamed('imageUrl'),
        ),
      ).thenAnswer((_) async {});

      final manager = container.read(mpvMetadataManagerProvider.notifier);
      final meta = createMeta(
        icyTitle: 'Queen - Under Pressure',
        icyName: 'Rock FM',
      );

      await manager.digestMpvMetaData(meta);

      verifyNever(
        mockOnlineArtService.fetchAlbumArt(icyTitle: anyNamed('icyTitle')),
      );
      verify(
        mockExposeService.exposeTitleOnline(
          title: 'Under Pressure',
          artist: 'Queen',
          additionalInfo: 'Rock FM',
          imageUrl: null,
        ),
      ).called(1);
    });
  });
}
