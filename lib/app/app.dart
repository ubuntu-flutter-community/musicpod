import 'package:collection/collection.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:flutter/material.dart';
import 'package:mpris_service/mpris_service.dart';
import 'package:musicpod/app/audio_page_filter_bar.dart';
import 'package:musicpod/app/common/audio_page.dart';
import 'package:musicpod/app/common/constants.dart';
import 'package:musicpod/app/common/offline_page.dart';
import 'package:musicpod/app/connectivity_notifier.dart';
import 'package:musicpod/app/library_model.dart';
import 'package:musicpod/app/liked_audio_page.dart';
import 'package:musicpod/app/local_audio/album_page.dart';
import 'package:musicpod/app/local_audio/failed_imports_content.dart';
import 'package:musicpod/app/local_audio/local_audio_model.dart';
import 'package:musicpod/app/local_audio/local_audio_page.dart';
import 'package:musicpod/app/master_item.dart';
import 'package:musicpod/app/player/player_model.dart';
import 'package:musicpod/app/player/player_view.dart';
import 'package:musicpod/app/playlists/playlist_dialog.dart';
import 'package:musicpod/app/playlists/playlist_page.dart';
import 'package:musicpod/app/podcasts/podcast_model.dart';
import 'package:musicpod/app/podcasts/podcast_page.dart';
import 'package:musicpod/app/podcasts/podcasts_page.dart';
import 'package:musicpod/app/radio/radio_model.dart';
import 'package:musicpod/app/radio/radio_page.dart';
import 'package:musicpod/app/radio/station_page.dart';
import 'package:musicpod/app/responsive_master_tile.dart';
import 'package:musicpod/app/settings/settings_tile.dart';
import 'package:musicpod/app/splash_screen.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:musicpod/service/library_service.dart';
import 'package:musicpod/service/local_audio_service.dart';
import 'package:musicpod/service/podcast_service.dart';
import 'package:musicpod/service/radio_service.dart';
import 'package:musicpod/utils.dart';
import 'package:provider/provider.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class App extends StatefulWidget {
  const App({super.key});

  static Widget create({
    required BuildContext context,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => RadioModel(getService<RadioService>()),
        ),
        ChangeNotifierProvider(
          create: (_) => PlayerModel(getService<MPRIS>()),
        ),
        ChangeNotifierProvider(
          create: (_) => LocalAudioModel(getService<LocalAudioService>()),
        ),
        ChangeNotifierProvider(
          create: (_) => LibraryModel(getService<LibraryService>())..init(),
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
          )..init(),
        )
      ],
      child: const App(),
    );
  }

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _selectedLocalAudioIndex = 0;

  @override
  void initState() {
    super.initState();
    YaruWindow.of(context).onClose(
      () async {
        await context.read<PlayerModel>().dispose();
        return true;
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) {
        context.read<PlayerModel>().init();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final light = theme.brightness == Brightness.light;
    final localAudioModel = context.read<LocalAudioModel>();
    final searchLocal = localAudioModel.search;
    final setLocalSearchQuery = localAudioModel.setSearchQuery;
    final setLocalSearchActive = localAudioModel.setSearchActive;

    final searchPodcasts = context.read<PodcastModel>().search;
    final setPodcastSearchQuery = context.read<PodcastModel>().setSearchQuery;
    final setPodcastSearchActive = context.read<PodcastModel>().setSearchActive;

    final searchRadio = context.read<RadioModel>().search;
    final setRadioQuery = context.read<RadioModel>().setSearchQuery;
    final setRadioSearchActive = context.read<RadioModel>().setSearchActive;

    final play = context.read<PlayerModel>().play;
    final audioType = context.select((PlayerModel m) => m.audio?.audioType);
    final surfaceTintColor =
        context.select((PlayerModel m) => m.surfaceTintColor);
    final isFullScreen = context.select((PlayerModel m) => m.fullScreen);

    final library = context.watch<LibraryModel>();
    final audioPageType = context.select((LibraryModel m) => m.audioPageType);
    final setAudioPageType = library.setAudioPageType;
    final width = MediaQuery.of(context).size.width;
    final shrinkSidebar = (width < 700);
    final playerToTheRight = width > 1700;

    final isOnline = context.select((ConnectivityNotifier c) => c.isOnline);

    void onTextTap({
      required String text,
      AudioType audioType = AudioType.local,
    }) {
      switch (audioType) {
        case AudioType.local:
          setLocalSearchActive(true);
          setLocalSearchQuery(text);
          searchLocal();
          library.index = 0;
          break;
        case AudioType.podcast:
          setPodcastSearchActive(true);
          setPodcastSearchQuery(
            text,
          );
          searchPodcasts(searchQuery: text);
          library.index = 2;
          break;
        case AudioType.radio:
          setRadioSearchActive(true);
          setRadioQuery(text);
          searchRadio(name: text);
          library.index = 1;
          break;
      }
    }

    final masterItems = [
      MasterItem(
        tileBuilder: (context) => Text(context.l10n.localAudio),
        builder: (context) => LocalAudioPage(
          selectedIndex: _selectedLocalAudioIndex,
          onIndexSelected: (i) => setState(() => _selectedLocalAudioIndex = i),
          showWindowControls: !playerToTheRight,
        ),
        iconBuilder: (context, selected) => LocalAudioPageIcon(
          selected: selected,
          isPlaying: audioType == AudioType.local,
        ),
      ),
      MasterItem(
        tileBuilder: (context) => Text(context.l10n.radio),
        builder: (context) => RadioPage(
          isOnline: isOnline,
          showWindowControls: !playerToTheRight,
          onTextTap: (text) =>
              onTextTap(text: text, audioType: AudioType.radio),
        ),
        iconBuilder: (context, selected) => RadioPageIcon(
          selected: selected,
          isPlaying: audioType == AudioType.radio,
        ),
      ),
      MasterItem(
        tileBuilder: (context) => Text(context.l10n.podcasts),
        builder: (context) {
          return PodcastsPage(
            showWindowControls: !playerToTheRight,
            isOnline: isOnline,
          );
        },
        iconBuilder: (context, selected) => PodcastsPageIcon(
          selected: selected,
          isPlaying: audioType == AudioType.podcast,
        ),
      ),
      MasterItem(
        iconBuilder: (context, selected) => const Icon(YaruIcons.plus),
        tileBuilder: (context) => Text(context.l10n.playlistDialogTitleNew),
        builder: (context) => ChangeNotifierProvider.value(
          value: library,
          child: const CreatePlaylistPage(),
        ),
      ),
      MasterItem(
        tileBuilder: (context) => Text(context.l10n.likedSongs),
        builder: (context) => LikedAudioPage(
          onArtistTap: (artist) => onTextTap(text: artist),
          onAlbumTap: (album) => onTextTap(text: album),
          showWindowControls: !playerToTheRight,
          likedAudios: library.likedAudios,
        ),
        iconBuilder: (context, selected) =>
            LikedAudioPage.createIcon(context: context, selected: selected),
      ),
      for (final podcast in library.podcasts.entries)
        MasterItem(
          tileBuilder: (context) => PodcastPage.createTitle(
            title: podcast.key,
            enabled: library.showSubbedPodcasts,
          ),
          builder: (context) => isOnline
              ? PodcastPage(
                  pageId: podcast.key,
                  audios: podcast.value,
                  showWindowControls: !playerToTheRight,
                  onAlbumTap: (album) =>
                      onTextTap(text: album, audioType: AudioType.podcast),
                  onArtistTap: (artist) =>
                      onTextTap(text: artist, audioType: AudioType.podcast),
                  addPodcast: library.addPodcast,
                  removePodcast: library.removePodcast,
                  imageUrl: podcast.value.firstOrNull?.albumArtUrl ??
                      podcast.value.firstOrNull?.imageUrl,
                )
              : const OfflinePage(),
          iconBuilder: (context, selected) => PodcastPage.createIcon(
            context: context,
            imageUrl: podcast.value.firstOrNull?.albumArtUrl ??
                podcast.value.firstOrNull?.imageUrl,
            isOnline: isOnline,
            enabled: library.showSubbedPodcasts,
          ),
        ),
      for (final playlist in library.playlists.entries)
        MasterItem(
          tileBuilder: (context) => Opacity(
            opacity: library.showPlaylists ? 1 : 0.5,
            child: Text(playlist.key),
          ),
          builder: (context) => PlaylistPage(
            onAlbumTap: (album) => onTextTap(text: album),
            onArtistTap: (artist) => onTextTap(text: artist),
            playlist: playlist,
            showWindowControls: !playerToTheRight,
            unPinPlaylist: library.removePlaylist,
          ),
          iconBuilder: (context, selected) => Opacity(
            opacity: library.showPlaylists ? 1 : 0.5,
            child: const Icon(
              YaruIcons.playlist,
            ),
          ),
        ),
      for (final album in library.pinnedAlbums.entries)
        MasterItem(
          tileBuilder: (context) => Opacity(
            opacity: library.showPinnedAlbums ? 1 : 0.5,
            child: Text(createPlaylistName(album.key, context)),
          ),
          builder: (context) => AlbumPage(
            onArtistTap: (artist) => onTextTap(text: artist),
            onAlbumTap: (album) => onTextTap(text: album),
            showWindowControls: !playerToTheRight,
            album: album.value,
            name: album.key,
            addPinnedAlbum: library.addPinnedAlbum,
            isPinnedAlbum: library.isPinnedAlbum,
            removePinnedAlbum: library.removePinnedAlbum,
          ),
          iconBuilder: (context, selected) => AlbumPage.createIcon(
            context,
            album.value.firstOrNull?.pictureData,
            library.showPinnedAlbums,
          ),
        ),
      for (final station in library.starredStations.entries)
        MasterItem(
          tileBuilder: (context) => Opacity(
            opacity: library.showStarredStations ? 1 : 0.5,
            child: Text(station.key),
          ),
          builder: (context) => isOnline
              ? StationPage(
                  showWindowControls: !playerToTheRight,
                  isStarred: true,
                  starStation: (station) {},
                  onTextTap: (text) =>
                      onTextTap(text: text, audioType: AudioType.radio),
                  unStarStation: library.unStarStation,
                  name: station.key,
                  station: station.value.first,
                  onPlay: (audio) => play(newAudio: audio),
                )
              : const OfflinePage(),
          iconBuilder: (context, selected) => StationPage.createIcon(
            context: context,
            imageUrl: station.value.first.imageUrl,
            selected: selected,
            isOnline: isOnline,
            enabled: library.showStarredStations,
          ),
        )
    ];

    final playerBg =
        surfaceTintColor ?? (light ? kBackGroundLight : kBackgroundDark);

    final yaruMasterDetailPage = YaruMasterDetailPage(
      onSelected: (value) => library.index = value ?? 0,
      appBar: const YaruWindowTitleBar(
        backgroundColor: Colors.transparent,
      ),
      bottomBar: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: SettingsTile(
          onDirectorySelected: (directoryPath) async {
            localAudioModel.setDirectory(directoryPath).then(
                  (value) async => await localAudioModel.init(
                    forceInit: true,
                    onFail: (failedImports) =>
                        ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(seconds: 10),
                        content:
                            FailedImportsContent(failedImports: failedImports),
                      ),
                    ),
                  ),
                );
          },
        ),
      ),
      layoutDelegate: shrinkSidebar ? delegateSmall : delegateBig,
      controller: YaruPageController(
        length: library.totalListAmount,
        initialIndex: library.index ?? 0,
      ),
      tileBuilder: (context, index, selected, availableWidth) {
        final tile = ResponsiveMasterTile(
          title: masterItems[index].tileBuilder(context),
          leading: masterItems[index].iconBuilder == null
              ? null
              : masterItems[index].iconBuilder!(
                  context,
                  selected,
                ),
          availableWidth: availableWidth,
        );

        Widget? column;

        if (index == 3) {
          column = Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              const Divider(
                height: 0,
              ),
              const SizedBox(
                height: 15,
              ),
              tile
            ],
          );
        } else if (index == 4 &&
            availableWidth >= 130 &&
            (library.totalListAmount > 5 || library.audioPageType != null)) {
          column = Column(
            children: [
              tile,
              AudioPageFilterBar(
                mainPageType: mainPageType,
                audioPageType: audioPageType,
                setAudioPageType: setAudioPageType,
              ),
            ],
          );
        }

        return column ??
            (index == 0
                ? Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: tile,
                  )
                : tile);
      },
      pageBuilder: (context, index) => YaruDetailPage(
        body: masterItems[index].builder(context),
      ),
    );

    final Widget body = Stack(
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
                child: Column(
                  children: [
                    const YaruWindowTitleBar(
                      backgroundColor: Colors.transparent,
                      border: BorderSide.none,
                    ),
                    Expanded(
                      child: PlayerView(
                        playerViewMode: PlayerViewMode.sideBar,
                        onTextTap: onTextTap,
                      ),
                    ),
                  ],
                ),
              )
          ],
        ),
        if (isFullScreen == true)
          Material(
            child: Material(
              color: playerBg,
              child: Column(
                children: [
                  const YaruWindowTitleBar(
                    border: BorderSide.none,
                    backgroundColor: Colors.transparent,
                  ),
                  Expanded(
                    child: PlayerView(
                      onTextTap: onTextTap,
                      playerViewMode: PlayerViewMode.fullWindow,
                    ),
                  )
                ],
              ),
            ),
          )
      ],
    );

    return Material(
      color: playerBg,
      key: ValueKey(shrinkSidebar),
      child: library.ready ? body : const SplashScreen(),
    );
  }
}
