import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:mpris_service/mpris_service.dart';
import 'package:musicpod/app/app_model.dart';
import 'package:musicpod/app/connectivity_notifier.dart';
import 'package:musicpod/app/library_model.dart';
import 'package:musicpod/app/local_audio/failed_imports_content.dart';
import 'package:musicpod/app/local_audio/local_audio_model.dart';
import 'package:musicpod/app/master_detail_page.dart';
import 'package:musicpod/app/master_items.dart';
import 'package:musicpod/app/player/player_model.dart';
import 'package:musicpod/app/player/player_view.dart';
import 'package:musicpod/app/podcasts/podcast_model.dart';
import 'package:musicpod/app/radio/radio_model.dart';
import 'package:musicpod/app/splash_screen.dart';
import 'package:musicpod/constants.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:musicpod/service/library_service.dart';
import 'package:musicpod/service/local_audio_service.dart';
import 'package:musicpod/service/podcast_service.dart';
import 'package:musicpod/service/radio_service.dart';
import 'package:provider/provider.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class App extends StatefulWidget {
  const App({super.key});

  static Widget create({
    required BuildContext context,
  }) {
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
            videoController: getService<VideoController>(),
            mpris: getService<MPRIS>(),
            libraryService: getService<LibraryService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => LocalAudioModel(getService<LocalAudioService>()),
        ),
        ChangeNotifierProvider(
          create: (_) => LibraryModel(getService<LibraryService>()),
        ),
        ChangeNotifierProvider(
          create: (_) => PodcastModel(
            getService<PodcastService>(),
            getService<LibraryService>(),
            getService<Connectivity>(),
            getService<NotificationsClient>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ConnectivityNotifier(
            getService<Connectivity>(),
          ),
        )
      ],
      child: const App(),
    );
  }

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  String? _countryCode;

  @override
  void initState() {
    super.initState();

    _countryCode = WidgetsBinding.instance.platformDispatcher.locale.countryCode
        ?.toLowerCase();

    YaruWindow.of(context).onClose(
      () async {
        await context.read<PlayerModel>().dispose().then((_) async {
          await context.read<LibraryModel>().dispose().then((_) async {
            await resetAllServices();
          });
        });

        return true;
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        final lm = context.read<LibraryModel>();
        final pm = context.read<PlayerModel>();
        final c = context.read<ConnectivityNotifier>();
        await lm.init();
        await pm.init();
        await c.init();
        if (lm.recentPatchNotesDisposed == false) {
          _showPatchNotes(lm.disposePatchNotes);
        }
      }
    });
  }

  Future<dynamic> _showPatchNotes(Future<void> Function() disposePatchNotes) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(kRecentPatchNotesTitle),
          content: Text(
            kRecentPatchNotes,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await disposePatchNotes()
                    .then((value) => Navigator.of(context).pop());
              },
              child: Text(context.l10n.ok),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final playerToTheRight = MediaQuery.of(context).size.width > 1700;

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
    final audioType = context.select((PlayerModel m) => m.audio?.audioType);
    final surfaceTintColor =
        context.select((PlayerModel m) => m.surfaceTintColor);
    final isFullScreen = context.select((PlayerModel m) => m.fullScreen);
    final playerBg = surfaceTintColor ?? (theme.scaffoldBackgroundColor);

    // Library
    // Watching values
    final libraryModel = context.read<LibraryModel>();
    final localAudioIndex =
        context.select((LibraryModel m) => m.localAudioindex);
    final index = context.select((LibraryModel m) => m.index);
    final likedAudios = context.select((LibraryModel m) => m.likedAudios);
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
    context.select<LibraryModel, int>((m) => m.podcastUpdates.length);

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
          localAudioModel.setSearchActive(true);
          localAudioModel.setSearchQuery(text);
          localAudioModel.search();
          libraryModel.setIndex(0);
          break;
        case AudioType.podcast:
          podcastModel.setSearchActive(true);
          podcastModel.setSearchQuery(
            text,
          );
          podcastModel.search(searchQuery: text);
          libraryModel.setIndex(2);
          break;
        case AudioType.radio:
          radioModel.setSearchActive(true);
          radioModel.setSearchQuery(text);
          radioModel.search(name: text);
          libraryModel.setIndex(1);
          break;
      }
    }

    final masterItems = createMasterItems(
      localAudioIndex: localAudioIndex,
      setLocalAudioindex: libraryModel.setLocalAudioindex,
      audioType: audioType,
      isOnline: isOnline,
      onTextTap: onTextTap,
      likedAudios: likedAudios,
      audioPageType: audioPageType,
      setAudioPageType: libraryModel.setAudioPageType,
      subbedPodcasts: subbedPodcasts,
      showSubbedPodcasts: showSubbedPodcasts,
      addPodcast: libraryModel.addPodcast,
      removePodcast: libraryModel.removePodcast,
      playlists: playlists,
      showPlaylists: showPlaylists,
      removePlaylist: libraryModel.removePlaylist,
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
      removePodcastUpdate: libraryModel.removePodcastUpdate,
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
                    if (!playerToTheRight)
                      const Divider(
                        height: 0,
                      ),
                    if (!playerToTheRight)
                      Material(
                        color: playerBg,
                        child: PlayerView(
                          onTextTap: onTextTap,
                          playerViewMode: PlayerViewMode.bottom,
                        ),
                      )
                  ],
                ),
              ),
              if (playerToTheRight)
                const VerticalDivider(
                  width: 0,
                ),
              if (playerToTheRight)
                SizedBox(
                  width: 500,
                  child: PlayerView(
                    playerViewMode: PlayerViewMode.sideBar,
                    onTextTap: onTextTap,
                  ),
                )
            ],
          ),
          if (isFullScreen == true)
            Material(
              child: Material(
                color: playerBg,
                child: PlayerView(
                  onTextTap: onTextTap,
                  playerViewMode: PlayerViewMode.fullWindow,
                ),
              ),
            )
        ],
      ),
    );
  }
}
