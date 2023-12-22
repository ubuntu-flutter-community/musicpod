import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:radio_browser_api/radio_browser_api.dart' hide State;
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../app.dart';
import '../../build_context_x.dart';
import '../../data.dart';
import '../../library.dart';
import '../../local_audio.dart';
import '../../patch_notes.dart';
import '../../player.dart';
import '../../podcasts.dart';
import '../../radio.dart';
import '../external_path/external_path_service.dart';
import 'connectivity_notifier.dart';
import 'master_detail_page.dart';
import 'master_items.dart';

class App extends StatefulWidget {
  const App({super.key});

  static Widget create() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => RadioModel(getService<RadioService>()),
        ),
        ChangeNotifierProvider(
          create: (_) => PlayerModel(
            service: getService<PlayerService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => LocalAudioModel(
            localAudioService: getService<LocalAudioService>(),
            libraryService: getService<LibraryService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => LibraryModel(getService<LibraryService>()),
        ),
        ChangeNotifierProvider(
          create: (_) => PodcastModel(
            getService<PodcastService>(),
            getService<LibraryService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ConnectivityNotifier(
            getService<Connectivity>(),
          ),
        ),
      ],
      child: const App(),
    );
  }

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  String? _countryCode;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _countryCode = WidgetsBinding.instance.platformDispatcher.locale.countryCode
        ?.toLowerCase();

    final libraryModel = context.read<LibraryModel>();
    final playerModel = context.read<PlayerModel>();
    final connectivityNotifier = context.read<ConnectivityNotifier>();

    final extPathService = getService<ExternalPathService>();

    if (!Platform.isAndroid && !Platform.isIOS) {
      YaruWindow.of(context).onClose(
        () async {
          await resetAllServices();
          return true;
        },
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      connectivityNotifier.init().then(
        (_) {
          libraryModel.init().then(
            (_) {
              playerModel.init().then((_) {
                if (libraryModel.recentPatchNotesDisposed == false) {
                  showPatchNotes(context, libraryModel.disposePatchNotes);
                }
                extPathService.init(playerModel.play);
              });
            },
          );
        },
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      await context.read<LibraryModel>().safeStates();
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerToTheRight = context.m.size.width > 1500;

    // Connectivity
    final isOnline = context.select((ConnectivityNotifier c) => c.isOnline);

    // Local Audio
    final localAudioModel = context.read<LocalAudioModel>();

    // Podcasts
    final podcastModel = context.read<PodcastModel>();

    // Radio
    final radioModel = context.read<RadioModel>();

    // Player
    final play = context.read<PlayerModel>().play;

    final isFullScreen = context.select((PlayerModel m) => m.fullScreen);

    // Library
    // Watching values
    final libraryModel = context.read<LibraryModel>();
    final index = context.select((LibraryModel m) => m.index);
    final likedLocalAudios = context.select(
      (LibraryModel m) => Set<Audio>.from(
        m.likedAudios.where((e) => e.audioType == AudioType.local),
      ),
    );

    final subbedPodcasts = context.select((LibraryModel m) => m.podcasts);
    final playlists = context.select((LibraryModel m) => m.playlists);
    final starredStations =
        context.select((LibraryModel m) => m.starredStations);
    final pinnedAlbums = context.select((LibraryModel m) => m.pinnedAlbums);

    context.select((LibraryModel m) => m.podcasts.length);
    context.select((LibraryModel m) => m.pinnedAlbums.length);
    context.select((LibraryModel m) => m.starredStations.length);
    context.select((LibraryModel m) => m.playlists.length);
    context.select((LibraryModel m) => m.playlists.keys);

    void onTextTap({
      required String text,
      required AudioType audioType,
    }) {
      switch (audioType) {
        case AudioType.local:
          libraryModel.setIndex(0);
          localAudioModel.setSearchActive(true);
          localAudioModel.setSearchQuery(text);
          localAudioModel.search();
          break;
        case AudioType.radio:
          libraryModel.setIndex(1);
          libraryModel.setRadioIndex(1);
          radioModel
              .init(countryCode: _countryCode, isOnline: isOnline)
              .then((_) {
            radioModel.search(tag: text);
            radioModel.setTag(Tag(name: text, stationCount: 1));
          });

          break;
        case AudioType.podcast:
          libraryModel.setIndex(2);
          libraryModel.setPodcastIndex(1);
          podcastModel.setSearchActive(true);
          podcastModel.setSearchQuery(text);
          podcastModel.search(searchQuery: text);
          break;
      }
    }

    final masterItems = createMasterItems(
      isOnline: isOnline,
      onTextTap: onTextTap,
      likedLocalAudios: likedLocalAudios,
      subbedPodcasts: subbedPodcasts,
      addPodcast: libraryModel.addPodcast,
      removePodcast: libraryModel.removePodcast,
      playlists: playlists,
      removePlaylist: libraryModel.removePlaylist,
      updatePlaylistName: libraryModel.updatePlaylistName,
      pinnedAlbums: pinnedAlbums,
      addPinnedAlbum: libraryModel.addPinnedAlbum,
      isPinnedAlbum: libraryModel.isPinnedAlbum,
      removePinnedAlbum: libraryModel.removePinnedAlbum,
      starredStations: starredStations,
      unStarStation: libraryModel.unStarStation,
      play: play,
      countryCode: _countryCode,
    );

    final yaruMasterDetailPage = MasterDetailPage(
      setIndex: libraryModel.setIndex,
      totalListAmount: libraryModel.totalListAmount,
      index: index,
      masterItems: masterItems,
      addPlaylist: libraryModel.addPlaylist,
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: yaruMasterDetailPage,
                  ),
                  if (!playerToTheRight)
                    PlayerView(
                      onTextTap: onTextTap,
                      playerViewMode: PlayerViewMode.bottom,
                      isOnline: isOnline,
                    ),
                ],
              ),
            ),
            if (playerToTheRight)
              SizedBox(
                width: 500,
                child: PlayerView(
                  playerViewMode: PlayerViewMode.sideBar,
                  onTextTap: onTextTap,
                  isOnline: isOnline,
                ),
              ),
          ],
        ),
        if (isFullScreen == true)
          Scaffold(
            body: PlayerView(
              onTextTap: onTextTap,
              playerViewMode: PlayerViewMode.fullWindow,
              isOnline: isOnline,
            ),
          ),
      ],
    );
  }
}
