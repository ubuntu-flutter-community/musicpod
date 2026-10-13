import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/common/data/audio.dart';
import 'package:musicpod/common/data/audio_type.dart';
import 'package:musicpod/local_audio/data/local_audio_state.dart';
import 'package:musicpod/local_audio/manager/find_album_manager.dart';
import 'package:musicpod/local_audio/manager/find_album_name_manager.dart';
import 'package:musicpod/local_audio/manager/find_artist_of_album_manager.dart';
import 'package:musicpod/local_audio/manager/local_audio_manager.dart';
import 'package:musicpod/local_audio/manager/pinned_album_ids_manager.dart';
import 'package:musicpod/local_audio/service/local_audio_service.dart';
import 'package:musicpod/local_audio/view/album_page.dart';
import 'package:musicpod/radio/manager/online_art_manager.dart';
import 'package:musicpod/radio/service/online_art_service.dart';

import 'standalone_riverpod_managers_test.mocks.dart';

class FakeLocalAudioManager extends LocalAudioManager {
  @override
  Future<LocalAudioState> build() async => const LocalAudioState();
}

@GenerateMocks([LocalAudioService, OnlineArtService])
void main() {
  late FakeLocalAudioManager fakeLocalAudio;
  late MockLocalAudioService mockLocalAudioService;
  late MockOnlineArtService mockOnlineArtService;
  late List<int> pinnedAlbums;

  setUp(() async {
    await GetIt.I.reset();
    fakeLocalAudio = FakeLocalAudioManager();
    mockLocalAudioService = MockLocalAudioService();
    mockOnlineArtService = MockOnlineArtService();
    pinnedAlbums = [10, 20];

    when(
      mockLocalAudioService.findAlbumName(any),
    ).thenAnswer((inv) async => 'Album ${inv.positionalArguments[0]}');
    when(
      mockLocalAudioService.findArtistOfAlbum(any),
    ).thenAnswer((inv) async => 'Artist ${inv.positionalArguments[0]}');
    when(mockLocalAudioService.findAlbum(any, any)).thenAnswer(
      (inv) async => [
        Audio(
          title: 'Track 1',
          albumDbId: inv.positionalArguments[0] as int,
          audioType: AudioType.local,
        ),
      ],
    );
    when(
      mockLocalAudioService.findPinnedAlbumIDs(),
    ).thenAnswer((_) async => List.from(pinnedAlbums));
    when(mockLocalAudioService.togglePinAlbum(any)).thenAnswer((inv) async {
      final id = inv.positionalArguments[0] as int?;
      if (id != null) {
        if (pinnedAlbums.contains(id)) {
          pinnedAlbums.remove(id);
        } else {
          pinnedAlbums.add(id);
        }
      }
      return List.from(pinnedAlbums);
    });

    when(
      mockOnlineArtService.fetchAlbumArt(icyTitle: anyNamed('icyTitle')),
    ).thenAnswer((inv) async {
      final icyTitle = inv.namedArguments[#icyTitle] as String;
      return 'https://example.com/$icyTitle.jpg';
    });

    GetIt.I.registerSingleton<LocalAudioService>(mockLocalAudioService);
    GetIt.I.registerSingleton<OnlineArtService>(mockOnlineArtService);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  test('FindAlbumNameManager returns album name using arrow syntax', () async {
    final container = ProviderContainer(
      overrides: [localAudioManagerProvider.overrideWith(() => fakeLocalAudio)],
    );
    addTearDown(container.dispose);

    final name = await container.read(findAlbumNameManagerProvider(42).future);
    expect(name, 'Album 42');
  });

  test('FindArtistOfAlbumManager returns artist using arrow syntax', () async {
    final container = ProviderContainer(
      overrides: [localAudioManagerProvider.overrideWith(() => fakeLocalAudio)],
    );
    addTearDown(container.dispose);

    final artist = await container.read(
      findArtistOfAlbumManagerProvider(42).future,
    );
    expect(artist, 'Artist 42');
  });

  test('FindAlbumManager returns tracks using arrow syntax', () async {
    final container = ProviderContainer(
      overrides: [localAudioManagerProvider.overrideWith(() => fakeLocalAudio)],
    );
    addTearDown(container.dispose);

    final tracks = await container.read(findAlbumManagerProvider(42).future);
    expect(tracks, isNotNull);
    expect(tracks!.first.title, 'Track 1');
  });

  test('OnlineArtManager returns art url or null when empty', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final emptyArt = await container.read(
      onlineArtManagerProvider(null).future,
    );
    expect(emptyArt, isNull);

    final art = await container.read(
      onlineArtManagerProvider('Artist - Song').future,
    );
    expect(art, 'https://example.com/Artist - Song.jpg');
  });

  testWidgets('AlbumPageSideBar widgets render data from Riverpod providers', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localAudioManagerProvider.overrideWith(() => fakeLocalAudio),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AlbumPageSideBarName(albumId: 7),
                AlbumPageSideBarArtist(albumId: 7),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Album 7'), findsOneWidget);
    expect(find.text('Artist 7'), findsOneWidget);
  });

  test('PinnedAlbumIDsManager reads and toggles pinned albums', () async {
    final container = ProviderContainer(
      overrides: [localAudioManagerProvider.overrideWith(() => fakeLocalAudio)],
    );
    addTearDown(container.dispose);

    final initial = await container.read(pinnedAlbumIDsManagerProvider.future);
    expect(initial, [10, 20]);

    await container
        .read(pinnedAlbumIDsManagerProvider.notifier)
        .togglePinAlbum(30);
    expect(container.read(pinnedAlbumIDsManagerProvider).value, [10, 20, 30]);

    await container
        .read(pinnedAlbumIDsManagerProvider.notifier)
        .togglePinAlbum(10);
    expect(container.read(pinnedAlbumIDsManagerProvider).value, [20, 30]);
  });
}
