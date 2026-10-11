import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musicpod/common/data/audio.dart';
import 'package:musicpod/common/data/audio_type.dart';
import 'package:musicpod/common/view/audio_filter.dart';
import 'package:musicpod/local_audio/manager/find_album_manager.dart';
import 'package:musicpod/local_audio/manager/find_album_name_manager.dart';
import 'package:musicpod/local_audio/manager/find_artist_of_album_manager.dart';
import 'package:musicpod/local_audio/manager/local_audio_manager.dart';
import 'package:musicpod/local_audio/manager/pinned_album_ids_manager.dart';
import 'package:musicpod/local_audio/service/local_audio_service.dart';
import 'package:musicpod/local_audio/view/album_page.dart';
import 'package:musicpod/radio/manager/online_art_manager.dart';
import 'package:musicpod/radio/service/online_art_service.dart';

class FakeLocalAudioManager extends LocalAudioManager {
  @override
  Future<LocalAudioState> build() async => const LocalAudioState();
}

class FakeLocalAudioService extends Fake implements LocalAudioService {
  List<int> pinnedAlbums = [10, 20];

  @override
  Future<String?> findAlbumName(int albumId) async => 'Album $albumId';

  @override
  Future<String?> findArtistOfAlbum(int albumId) async => 'Artist $albumId';

  @override
  Future<List<Audio>?> findAlbum(
    int albumId, [
    AudioFilter audioFilter = AudioFilter.album,
  ]) async => [
    Audio(title: 'Track 1', albumDbId: albumId, audioType: AudioType.local),
  ];

  @override
  Future<List<int>> findPinnedAlbumIDs() async => List.from(pinnedAlbums);

  @override
  Future<List<int>> togglePinAlbum(int? id) async {
    if (id != null) {
      if (pinnedAlbums.contains(id)) {
        pinnedAlbums.remove(id);
      } else {
        pinnedAlbums.add(id);
      }
    }
    return List.from(pinnedAlbums);
  }
}

class FakeOnlineArtService extends Fake implements OnlineArtService {
  @override
  Future<String?> fetchAlbumArt({required String icyTitle}) async =>
      'https://example.com/$icyTitle.jpg';
}

void main() {
  late FakeLocalAudioManager fakeLocalAudio;

  setUp(() async {
    await GetIt.I.reset();
    fakeLocalAudio = FakeLocalAudioManager();
    GetIt.I.registerSingleton<LocalAudioService>(FakeLocalAudioService());
    GetIt.I.registerSingleton<OnlineArtService>(FakeOnlineArtService());
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  test('FindAlbumNameManager returns album name using arrow syntax', () async {
    final container = ProviderContainer(
      overrides: [
        localAudioManagerProvider.overrideWith(() => fakeLocalAudio),
      ],
    );
    addTearDown(container.dispose);

    final name = await container.read(findAlbumNameManagerProvider(42).future);
    expect(name, 'Album 42');
  });

  test('FindArtistOfAlbumManager returns artist using arrow syntax', () async {
    final container = ProviderContainer(
      overrides: [
        localAudioManagerProvider.overrideWith(() => fakeLocalAudio),
      ],
    );
    addTearDown(container.dispose);

    final artist = await container.read(
      findArtistOfAlbumManagerProvider(42).future,
    );
    expect(artist, 'Artist 42');
  });

  test('FindAlbumManager returns tracks using arrow syntax', () async {
    final container = ProviderContainer(
      overrides: [
        localAudioManagerProvider.overrideWith(() => fakeLocalAudio),
      ],
    );
    addTearDown(container.dispose);

    final tracks = await container.read(findAlbumManagerProvider(42).future);
    expect(tracks, isNotNull);
    expect(tracks!.first.title, 'Track 1');
  });

  test('OnlineArtManager returns art url or null when empty', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final emptyArt = await container.read(onlineArtManagerProvider(null).future);
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
      overrides: [
        localAudioManagerProvider.overrideWith(() => fakeLocalAudio),
      ],
    );
    addTearDown(container.dispose);

    final initial = await container.read(pinnedAlbumIDsManagerProvider.future);
    expect(initial, [10, 20]);

    await container.read(pinnedAlbumIDsManagerProvider.notifier).togglePinAlbum(30);
    expect(container.read(pinnedAlbumIDsManagerProvider).value, [10, 20, 30]);

    await container.read(pinnedAlbumIDsManagerProvider.notifier).togglePinAlbum(10);
    expect(container.read(pinnedAlbumIDsManagerProvider).value, [20, 30]);
  });
}
