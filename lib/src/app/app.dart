import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../app.dart';
import '../../data.dart';
import '../../library.dart';
import '../../local_audio.dart';
import '../../patch_notes.dart';
import '../../player.dart';
import '../../podcasts.dart';
import '../../radio.dart';
import '../common/colors.dart';
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
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final playerToTheRight = MediaQuery.of(context).size.width > 1700;

    // Connectivity
    final isOnline = context.select((ConnectivityNotifier c) => c.isOnline);

    // Local Audio
    final localAudioModel = context.read<LocalAudioModel>();

    // Podcasts
    final podcastModel = context.read<PodcastModel>();
    final checkingForPodcastUpdates =
        context.select((PodcastModel m) => m.checkingForUpdates);

    // Radio
    final radioModel = context.read<RadioModel>();

    // Player
    final play = context.read<PlayerModel>().play;
    final audioType = context.select((PlayerModel m) => m.audio?.audioType);

    final color = context.select((PlayerModel m) => m.color);
    final isFullScreen = context.select((PlayerModel m) => m.fullScreen);
    final Color playerBg = getPlayerBg(color, theme.scaffoldBackgroundColor);

    // Library
    // Watching values
    final libraryModel = context.read<LibraryModel>();
    final localAudioIndex =
        context.select((LibraryModel m) => m.localAudioindex);
    final index = context.select((LibraryModel m) => m.index);
    final likedLocalAudios = context.select(
      (LibraryModel m) => Set<Audio>.from(
        m.likedAudios.where((e) => e.audioType == AudioType.local),
      ),
    );
    final likedPodcasts = context.select(
      (LibraryModel m) => Set<Audio>.from(
        m.likedAudios.where((e) => e.audioType == AudioType.podcast),
      ),
    );

    final subbedPodcasts = context.select((LibraryModel m) => m.podcasts);
    final playlists = context.select((LibraryModel m) => m.playlists);
    final showPlaylists = context.select((LibraryModel m) => m.showPlaylists);
    final starredStations =
        context.select((LibraryModel m) => m.starredStations);
    final pinnedAlbums = context.select((LibraryModel m) => m.pinnedAlbums);
    final showSubbedPodcasts =
        context.select((LibraryModel m) => m.showSubbedPodcasts);
    final showStarredStations =
        context.select((LibraryModel m) => m.showStarredStations);
    final showPinnedAlbums =
        context.select((LibraryModel m) => m.showPinnedAlbums);
    final audioPageType = context.select((LibraryModel m) => m.audioPageType);
    final ready = context.select((LibraryModel m) => m.ready);
    context.select((LibraryModel m) => m.podcasts.length);
    context.select((LibraryModel m) => m.pinnedAlbums.length);
    context.select((LibraryModel m) => m.starredStations.length);
    context.select((LibraryModel m) => m.playlists.length);
    context.select((LibraryModel m) => m.playlists.keys);
    context.select((LibraryModel m) => m.podcastUpdates.length);

    if (!ready) {
      return SplashScreen(
        color: playerBg,
      );
    }

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
          radioModel.setSearchActive(true);
          radioModel.setSearchQuery(text);
          radioModel.search(name: text);
          break;
        case AudioType.podcast:
          libraryModel.setIndex(2);
          podcastModel.setSearchActive(true);
          podcastModel.setSearchQuery(text);
          podcastModel.search(searchQuery: text);
          break;
      }
    }

    final masterItems = createMasterItems(
      showFilter: (libraryModel.totalListAmount > 7 ||
              libraryModel.audioPageType != null) &&
          width > 600.0,
      localAudioIndex: localAudioIndex,
      setLocalAudioindex: libraryModel.setLocalAudioindex,
      audioType: audioType,
      isOnline: isOnline,
      onTextTap: onTextTap,
      likedLocalAudios: likedLocalAudios,
      likedPodcasts: likedPodcasts,
      audioPageType: audioPageType,
      setAudioPageType: libraryModel.setAudioPageType,
      subbedPodcasts: subbedPodcasts,
      showSubbedPodcasts: showSubbedPodcasts,
      addPodcast: libraryModel.addPodcast,
      removePodcast: libraryModel.removePodcast,
      playlists: playlists,
      showPlaylists: showPlaylists,
      removePlaylist: libraryModel.removePlaylist,
      updatePlaylistName: libraryModel.updatePlaylistName,
      pinnedAlbums: pinnedAlbums,
      showPinnedAlbums: showPinnedAlbums,
      addPinnedAlbum: libraryModel.addPinnedAlbum,
      isPinnedAlbum: libraryModel.isPinnedAlbum,
      removePinnedAlbum: libraryModel.removePinnedAlbum,
      starredStations: starredStations,
      showStarredStations: showStarredStations,
      unStarStation: libraryModel.unStarStation,
      play: play,
      countryCode: _countryCode,
      podcastUpdateAvailable: libraryModel.podcastUpdateAvailable,
      checkingForPodcastUpdates: checkingForPodcastUpdates,
    );

    final yaruMasterDetailPage = MasterDetailPage(
      setIndex: libraryModel.setIndex,
      onDirectorySelected: (directoryPath) async {
        localAudioModel.setDirectory(directoryPath).then(
              (value) async => await localAudioModel.init(
                forceInit: true,
                onFail: (failedImports) {
                  if (libraryModel.neverShowFailedImports) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 10),
                      content: FailedImportsContent(
                        failedImports: failedImports,
                        onNeverShowFailedImports:
                            libraryModel.setNeverShowLocalImports,
                      ),
                    ),
                  );
                },
              ),
            );
      },
      totalListAmount: libraryModel.totalListAmount,
      index: index,
      masterItems: masterItems,
      addPlaylist: libraryModel.addPlaylist,
    );

    return Material(
      color: playerBg,
      child: Stack(
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
                    if (!playerToTheRight) const Divider(),
                    if (!playerToTheRight)
                      Material(
                        color: playerBg,
                        child: PlayerView(
                          onTextTap: onTextTap,
                          playerViewMode: PlayerViewMode.bottom,
                          isOnline: isOnline,
                        ),
                      ),
                  ],
                ),
              ),
              if (playerToTheRight) const VerticalDivider(),
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
              body: Material(
                color: playerBg,
                child: PlayerView(
                  onTextTap: onTextTap,
                  playerViewMode: PlayerViewMode.fullWindow,
                  isOnline: isOnline,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
