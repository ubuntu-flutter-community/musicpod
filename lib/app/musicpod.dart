import 'package:collection/collection.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:flutter/material.dart';
import 'package:mpris_service/mpris_service.dart';
import 'package:musicpod/app/audio_page_filter_bar.dart';
import 'package:musicpod/app/common/audio_page.dart';
import 'package:musicpod/app/common/constants.dart';
import 'package:musicpod/app/connectivity_notifier.dart';
import 'package:musicpod/app/library_model.dart';
import 'package:musicpod/app/liked_audio_page.dart';
import 'package:musicpod/app/local_audio/album_page.dart';
import 'package:musicpod/app/local_audio/local_audio_model.dart';
import 'package:musicpod/app/local_audio/local_audio_page.dart';
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
import 'package:musicpod/service/podcast_service.dart';
import 'package:musicpod/service/radio_service.dart';
import 'package:musicpod/utils.dart';
import 'package:provider/provider.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class MusicPod extends StatelessWidget {
  const MusicPod({super.key});

  static final GlobalKey<ScaffoldMessengerState> scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return YaruTheme(
      builder: (context, yaruThemeData, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: yaruThemeData.theme,
          darkTheme: yaruThemeData.darkTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: supportedLocales,
          onGenerateTitle: (context) => 'Music',
          home: _App.create(
            context: context,
            showSnackBar: scaffoldKey.currentState?.showSnackBar,
          ),
          scaffoldMessengerKey: scaffoldKey,
        );
      },
    );
  }
}

class _App extends StatefulWidget {
  const _App();

  static Widget create({
    required BuildContext context,
    required ScaffoldFeatureController<SnackBar, SnackBarClosedReason> Function(
      SnackBar snackBar,
    )? showSnackBar,
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
          create: (_) => LocalAudioModel()..init(showSnackBar: showSnackBar),
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
      child: const _App(),
    );
  }

  @override
  State<_App> createState() => _AppState();
}

class _AppState extends State<_App> with TickerProviderStateMixin {
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
    final localAudioModel = context.watch<LocalAudioModel>();
    final searchLocal = localAudioModel.search;
    final setLocalSearchQuery = localAudioModel.setSearchQuery;

    final searchPodcasts = context.read<PodcastModel>().search;
    final setPodcastSearchQuery = context.read<PodcastModel>().setSearchQuery;

    final searchRadio = context.read<RadioModel>().search;
    final setRadioQuery = context.read<RadioModel>().setSearchQuery;

    // final isPlaying = context.select((PlayerModel m) => m.isPlaying);
    final play = context.read<PlayerModel>().play;
    final audioType = context.select((PlayerModel m) => m.audio?.audioType);
    final surfaceTintColor =
        context.select((PlayerModel m) => m.surfaceTintColor);
    final isFullScreen = context.select((PlayerModel m) => m.fullScreen);

    final library = context.watch<LibraryModel>();
    final width = MediaQuery.of(context).size.width;
    final shrinkSidebar = (width < 700);
    final playerToTheRight = width > 1700;

    void onTextTap({
      required String text,
      AudioType audioType = AudioType.local,
    }) {
      switch (audioType) {
        case AudioType.local:
          setLocalSearchQuery(text);
          searchLocal();
          library.index = 0;
          break;
        case AudioType.podcast:
          setPodcastSearchQuery(
            text,
          );
          searchPodcasts(searchQuery: text, useAlbumImage: true);
          library.index = 2;
          break;
        case AudioType.radio:
          setRadioQuery(text);
          searchRadio(tag: text);
          library.index = 1;
          break;
      }
    }

    final masterItems = [
      MasterItem(
        tileBuilder: (context) => Text(context.l10n.localAudio),
        builder: (context) => LocalAudioPage(
          showWindowControls: !playerToTheRight,
        ),
        iconBuilder: (context, selected) => LocalAudioPageIcon(
          selected: selected,
          isPlaying: audioType == AudioType.local,
        ),
      ),
      MasterItem(
        tileBuilder: (context) => Text(context.l10n.radio),
        builder: (context) => RadioPage(showWindowControls: !playerToTheRight),
        iconBuilder: (context, selected) => RadioPageIcon(
          selected: selected,
          isPlaying: audioType == AudioType.radio,
        ),
      ),
      MasterItem(
        tileBuilder: (context) => Text(context.l10n.podcasts),
        builder: (context) {
          return PodcastsPage(showWindowControls: !playerToTheRight);
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
      if (library.showSubbedPodcasts)
        for (final podcast in library.podcasts.entries)
          MasterItem(
            tileBuilder: (context) => Text(podcast.key),
            builder: (context) => PodcastPage(
              pageId: podcast.key,
              audios: podcast.value,
              showWindowControls: !playerToTheRight,
              onAlbumTap: (album) =>
                  onTextTap(text: album, audioType: AudioType.podcast),
              onArtistTap: (artist) =>
                  onTextTap(text: artist, audioType: AudioType.podcast),
              onControlButtonPressed: () => library.removePodcast(podcast.key),
              imageUrl: podcast.value.firstOrNull?.imageUrl,
            ),
            iconBuilder: (context, selected) => PodcastPage.createIcon(
              context,
              podcast.value.firstOrNull?.imageUrl,
            ),
          ),
      if (library.showPlaylists)
        for (final playlist in library.playlists.entries)
          MasterItem(
            tileBuilder: (context) => Text(playlist.key),
            builder: (context) => PlaylistPage(
              onAlbumTap: (album) => onTextTap(text: album),
              onArtistTap: (artist) => onTextTap(text: artist),
              playlist: playlist,
              showWindowControls: !playerToTheRight,
              unPinPlaylist: library.removePlaylist,
            ),
            iconBuilder: (context, selected) => const Icon(
              YaruIcons.playlist,
            ),
          ),
      if (library.showPinnedAlbums)
        for (final album in library.pinnedAlbums.entries)
          MasterItem(
            tileBuilder: (context) =>
                Text(createPlaylistName(album.key, context)),
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
            ),
          ),
      if (library.showStarredStations)
        for (final station in library.starredStations.entries)
          MasterItem(
            tileBuilder: (context) => Text(station.key),
            builder: (context) => StationPage(
              onTextTap: (text) =>
                  onTextTap(text: text, audioType: AudioType.radio),
              unStarStation: library.unStarStation,
              name: station.key,
              station: station.value.first,
              onPlay: (audio) => play(newAudio: audio),
            ),
            iconBuilder: (context, selected) => StationPage.createIcon(
              context: context,
              station: station.value.first,
              selected: selected,
            ),
          )
    ];

    final yaruMasterDetailPage = YaruMasterDetailPage(
      onSelected: (value) => library.index = value ?? 0,
      appBar: const YaruWindowTitleBar(),
      bottomBar: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: SettingsTile(
          onDirectorySelected: (directoryPath) async {
            localAudioModel.setDirectory(directoryPath).then(
                  (value) async => await localAudioModel.init(
                    warningColor: Theme.of(context).colorScheme.warning,
                    showSnackBar: ScaffoldMessenger.of(context).showSnackBar,
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
              const Divider(
                height: 30,
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
              AudioPageFilterBar(mainPageType: mainPageType),
            ],
          );
        }

        return column ?? tile;
      },
      pageBuilder: (context, index) => YaruDetailPage(
        body: masterItems[index].builder(context),
      ),
    );

    final Widget body;
    if (isFullScreen == true) {
      body = const Column(
        children: [
          YaruWindowTitleBar(
            border: BorderSide.none,
            backgroundColor: Colors.transparent,
          ),
          Expanded(child: PlayerView())
        ],
      );
    } else {
      if (!playerToTheRight) {
        body = Column(
          children: [
            Expanded(
              child: yaruMasterDetailPage,
            ),
            const Divider(
              height: 0,
            ),
            const PlayerView()
          ],
        );
      } else {
        body = Row(
          children: [
            Expanded(
              child: yaruMasterDetailPage,
            ),
            const VerticalDivider(
              width: 0,
            ),
            const SizedBox(
              width: 500,
              child: Column(
                children: [
                  YaruWindowTitleBar(),
                  Expanded(
                    child: PlayerView(
                      expandHeight: true,
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      }
    }

    return Scaffold(
      key: ValueKey(shrinkSidebar),
      backgroundColor: surfaceTintColor,
      body: library.ready ? body : const SplashScreen(),
    );
  }
}

class MasterItem {
  MasterItem({
    required this.tileBuilder,
    required this.builder,
    this.iconBuilder,
  });

  final WidgetBuilder tileBuilder;
  final WidgetBuilder builder;
  final Widget Function(BuildContext context, bool selected)? iconBuilder;
}
