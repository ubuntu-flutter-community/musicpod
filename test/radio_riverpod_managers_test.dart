import 'package:flutter_it/flutter_it.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/common/data/audio.dart';
import 'package:musicpod/common/data/audio_type.dart';
import 'package:musicpod/radio/data/radio_collection_view.dart';
import 'package:musicpod/radio/manager/click_station_manager.dart';
import 'package:musicpod/radio/manager/radio_collection_view_manager.dart';
import 'package:musicpod/radio/manager/radio_fav_tag_manager.dart';
import 'package:musicpod/radio/manager/radio_load_tags_manager.dart';
import 'package:musicpod/radio/manager/radio_manager.dart';
import 'package:musicpod/radio/manager/radio_star_station_manager.dart';
import 'package:musicpod/radio/manager/station_manager.dart';
import 'package:musicpod/radio/service/radio_service.dart';
import 'package:radio_browser_api/radio_browser_api.dart';

import 'radio_riverpod_managers_test.mocks.dart';

@GenerateMocks([RadioService])
void main() {
  late MockRadioService mockRadioService;

  setUp(() async {
    await GetIt.I.reset();
    mockRadioService = MockRadioService();
    GetIt.I.registerSingleton<RadioService>(mockRadioService);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  test('RadioCollectionViewManager defaults to stations and updates correctly', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(radioCollectionViewManagerProvider),
      RadioCollectionView.stations,
    );

    container
        .read(radioCollectionViewManagerProvider.notifier)
        .setRadioCollectionView(RadioCollectionView.tags);

    expect(
      container.read(radioCollectionViewManagerProvider),
      RadioCollectionView.tags,
    );
  });

  test('RadioStarStationManager gets and toggles starred stations', () async {
    when(mockRadioService.getStarredStations())
        .thenAnswer((_) async => {'uuid-1'});
    when(mockRadioService.toggleStarredStation(any))
        .thenAnswer((_) async => true);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final initial =
        await container.read(radioStarStationManagerProvider.future);
    expect(initial, {'uuid-1'});

    when(mockRadioService.getStarredStations())
        .thenAnswer((_) async => {'uuid-1', 'uuid-2'});

    const station = Audio(uuid: 'uuid-2', audioType: AudioType.radio);
    await container
        .read(radioStarStationManagerProvider.notifier)
        .toggleStarredStation(station);

    verify(mockRadioService.toggleStarredStation(station)).called(1);
    expect(
      container.read(radioStarStationManagerProvider).value,
      {'uuid-1', 'uuid-2'},
    );
  });

  test('RadioFavTagManager gets and toggles favorite tags', () async {
    when(mockRadioService.getFavRadioTags())
        .thenAnswer((_) async => {'rock'});
    when(mockRadioService.toggleFavRadioTag(any))
        .thenAnswer((_) async {});

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final initial = await container.read(radioFavTagManagerProvider.future);
    expect(initial, {'rock'});

    when(mockRadioService.getFavRadioTags())
        .thenAnswer((_) async => {'rock', 'jazz'});

    await container
        .read(radioFavTagManagerProvider.notifier)
        .toggleFavRadioTag('jazz');

    verify(mockRadioService.toggleFavRadioTag('jazz')).called(1);
    expect(container.read(radioFavTagManagerProvider).value, {'rock', 'jazz'});
  });

  test('ClickStationManager calls clickStation on RadioService', () async {
    when(mockRadioService.clickStation('uuid-123')).thenAnswer((_) async {});

    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container
        .read(clickStationManagerProvider.notifier)
        .clickStation('uuid-123');

    verify(mockRadioService.clickStation('uuid-123')).called(1);
  });

  test('RadioManager awaits connection build before search and getAudioByUUID', () async {
    when(mockRadioService.connectToServer())
        .thenAnswer((_) async => 'de1.api.radio-browser.info');
    when(mockRadioService.getAudioByUUID('remote-uuid', fromDBOnly: true))
        .thenAnswer((_) async => null);
    when(mockRadioService.getAudioByUUID('remote-uuid', fromDBOnly: false))
        .thenAnswer(
          (_) async =>
              const Audio(uuid: 'remote-uuid', audioType: AudioType.radio),
        );
    when(
      mockRadioService.search(
        country: anyNamed('country'),
        name: 'jazz',
        state: anyNamed('state'),
        tag: anyNamed('tag'),
        language: anyNamed('language'),
        limit: 10,
      ),
    ).thenAnswer(
      (_) async => [
        const Audio(uuid: 'jazz-1', title: 'Jazz Radio', audioType: AudioType.radio),
      ],
    );

    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Call search on RadioManager notifier: it must await future (connectToServer)
    final results = await container
        .read(radioManagerProvider.notifier)
        .search(name: 'jazz', limit: 10);

    verify(mockRadioService.connectToServer()).called(1);
    expect(results?.length, 1);
    expect(results?.first.title, 'Jazz Radio');

    // Call getAudioByUUID: if not in DB, awaits connection future and fetches from remote
    final station = await container
        .read(radioManagerProvider.notifier)
        .getAudioByUUID('remote-uuid');

    expect(station?.uuid, 'remote-uuid');
    verify(mockRadioService.getAudioByUUID('remote-uuid', fromDBOnly: true))
        .called(1);
    verify(mockRadioService.getAudioByUUID('remote-uuid', fromDBOnly: false))
        .called(1);
  });

  test('StationManager awaits radioManagerProvider.future if not in DB', () async {
    when(mockRadioService.connectToServer())
        .thenAnswer((_) async => 'de1.api.radio-browser.info');
    when(mockRadioService.getAudioByUUID('station-1', fromDBOnly: true))
        .thenAnswer((_) async => null);
    when(mockRadioService.getAudioByUUID('station-1', fromDBOnly: false))
        .thenAnswer(
          (_) async =>
              const Audio(uuid: 'station-1', title: 'Station 1', audioType: AudioType.radio),
        );

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final station =
        await container.read(stationManagerProvider('station-1').future);

    expect(station?.title, 'Station 1');
    verify(mockRadioService.connectToServer()).called(1);
    verify(mockRadioService.getAudioByUUID('station-1', fromDBOnly: false))
        .called(1);
  });

  test('RadioLoadTagsManager awaits radioManagerProvider.future and returns tags', () async {
    when(mockRadioService.connectToServer())
        .thenAnswer((_) async => 'de1.api.radio-browser.info');
    when(mockRadioService.loadTags()).thenAnswer(
      (_) async => [
        const Tag(name: 'chill', stationCount: 42),
      ],
    );

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final tags = await container.read(radioLoadTagsManagerProvider.future);

    expect(tags.length, 1);
    expect(tags.first.name, 'chill');
    verify(mockRadioService.connectToServer()).called(1);
    verify(mockRadioService.loadTags()).called(1);
  });
}
