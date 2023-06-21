import 'package:collection/collection.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:mpris_service/mpris_service.dart';
import 'package:musicpod/app/common/audio_page.dart';
import 'package:musicpod/app/common/constants.dart';
import 'package:musicpod/app/common/safe_network_image.dart';
import 'package:musicpod/app/connectivity_notifier.dart';
import 'package:musicpod/app/local_audio/local_audio_model.dart';
import 'package:musicpod/app/local_audio/local_audio_page.dart';
import 'package:musicpod/app/player_model.dart';
import 'package:musicpod/app/player_view.dart';
import 'package:musicpod/app/playlists/playlist_dialog.dart';
import 'package:musicpod/app/playlists/playlist_model.dart';
import 'package:musicpod/app/podcasts/podcast_model.dart';
import 'package:musicpod/app/podcasts/podcast_page.dart';
import 'package:musicpod/app/podcasts/podcasts_page.dart';
import 'package:musicpod/app/radio/radio_page.dart';
import 'package:musicpod/app/responsive_master_tile.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:musicpod/service/library_service.dart';
import 'package:musicpod/service/podcast_service.dart';
import 'package:musicpod/utils.dart';
import 'package:provider/provider.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

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
          home: _App.create(context),
          scaffoldMessengerKey: scaffoldKey,
        );
      },
    );
  }
}

class _App extends StatefulWidget {
  const _App();

  static Widget create(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PlayerModel(getService<MPRIS>()),
        ),
        ChangeNotifierProvider(
          create: (_) => LocalAudioModel()..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => PlaylistModel(getService<LibraryService>())..init(),
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

    // final isPlaying = context.select((PlayerModel m) => m.isPlaying);
    final audioType = context.select((PlayerModel m) => m.audio?.audioType);
    final surfaceTintColor =
        context.select((PlayerModel m) => m.surfaceTintColor);
    final isFullScreen = context.select((PlayerModel m) => m.fullScreen);

    final playlistModel = context.watch<PlaylistModel>();
    final theme = Theme.of(context);
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
          playlistModel.index = 0;
          break;
        case AudioType.podcast:
          setPodcastSearchQuery(
            text,
          );
          searchPodcasts(searchQuery: text, useAlbumImage: true);
          playlistModel.index = 2;
          break;
        case AudioType.radio:
          // TODO: Handle this case.
          break;
      }
    }

    final masterItems = [
      MasterItem(
        tileBuilder: (context) {
          return Text(context.l10n.localAudio);
        },
        builder: (context) {
          return LocalAudioPage(
            showWindowControls: !playerToTheRight,
          );
        },
        iconBuilder: (context, selected) => LocalAudioPageIcon(
          selected: selected,
          isPlaying: audioType == AudioType.local,
        ),
      ),
      MasterItem(
        tileBuilder: (context) {
          return Text(context.l10n.radio);
        },
        builder: (context) {
          return RadioPage.create(context, !playerToTheRight);
        },
        iconBuilder: (context, selected) => RadioPageIcon(
          selected: selected,
          isPlaying: audioType == AudioType.radio,
        ),
      ),
      MasterItem(
        tileBuilder: (context) {
          return Text(context.l10n.podcasts);
        },
        builder: (context) {
          return PodcastsPage(showWindowControls: !playerToTheRight);
        },
        iconBuilder: (context, selected) => PodcastsPageIcon(
          selected: selected,
          isPlaying: audioType == AudioType.podcast,
        ),
      ),
      MasterItem(
        iconBuilder: (context, selected) {
          return const Icon(YaruIcons.plus);
        },
        tileBuilder: (context) {
          return Text(context.l10n.playlistDialogTitleNew);
        },
        builder: (context) {
          return ChangeNotifierProvider.value(
            value: playlistModel,
            child: const CreatePlaylistPage(),
          );
        },
      ),
      MasterItem(
        tileBuilder: (context) {
          return Text(context.l10n.likedSongs);
        },
        builder: (context) {
          return AudioPage(
            onArtistTap: (artist) => onTextTap(text: artist),
            onAlbumTap: (album) => onTextTap(text: album),
            audioPageType: AudioPageType.likedAudio,
            placeTrailer: false,
            showWindowControls: !playerToTheRight,
            audios: playlistModel.likedAudios,
            pageId: 'likedAudio',
            pageTitle: context.l10n.likedSongs,
            editableName: false,
            deletable: false,
            controlPageButton: const SizedBox.shrink(),
          );
        },
        iconBuilder: (context, selected) {
          return const Icon(YaruIcons.heart);
        },
      ),
      if (playlistModel.audioPageType == null ||
          playlistModel.audioPageType == AudioPageType.podcast)
        for (final podcast in playlistModel.podcasts.entries)
          MasterItem(
            tileBuilder: (context) {
              return Text(podcast.key);
            },
            builder: (context) {
              return PodcastPage(
                pageId: podcast.key,
                audios: podcast.value,
                showWindowControls: !playerToTheRight,
                onAlbumTap: (album) =>
                    onTextTap(text: album, audioType: AudioType.podcast),
                onArtistTap: (artist) =>
                    onTextTap(text: artist, audioType: AudioType.podcast),
                onControlButtonPressed: () =>
                    playlistModel.removePodcast(podcast.key),
                imageUrl: podcast.value.firstOrNull?.imageUrl,
              );
            },
            iconBuilder: (context, selected) {
              final picture = podcast.value.firstOrNull?.imageUrl;
              Widget? albumArt;
              if (picture != null) {
                albumArt = SizedBox(
                  width: 23,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: SafeNetworkImage(
                      url: picture,
                      fit: BoxFit.fitHeight,
                      filterQuality: FilterQuality.medium,
                      fallBackIcon: Icon(
                        YaruIcons.podcast,
                        color: theme.hintColor,
                      ),
                    ),
                  ),
                );
              }
              return albumArt ??
                  const Icon(
                    YaruIcons.rss,
                  );
            },
          ),
      if (playlistModel.audioPageType == null ||
          playlistModel.audioPageType == AudioPageType.playlist)
        for (final playlist in playlistModel.playlists.entries)
          MasterItem(
            tileBuilder: (context) {
              return Text(playlist.key);
            },
            builder: (context) {
              final noPicture = playlist.value.firstOrNull == null ||
                  playlist.value.firstOrNull!.pictureData == null;

              final noImage = playlist.value.firstOrNull == null ||
                  playlist.value.firstOrNull!.imageUrl == null;

              return AudioPage(
                onArtistTap: (artist) => onTextTap(text: artist),
                onAlbumTap: (album) => onTextTap(text: album),
                audioPageType: AudioPageType.playlist,
                image: !noPicture
                    ? Image.memory(
                        playlist.value.firstOrNull!.pictureData!,
                        width: 200.0,
                        fit: BoxFit.fitWidth,
                        filterQuality: FilterQuality.medium,
                      )
                    : !noImage
                        ? SafeNetworkImage(
                            fallBackIcon: SizedBox(
                              width: 200,
                              child: Center(
                                child: Icon(
                                  YaruIcons.music_note,
                                  size: 80,
                                  color: theme.hintColor,
                                ),
                              ),
                            ),
                            url: playlist.value.firstOrNull!.imageUrl,
                            fit: BoxFit.fitWidth,
                            filterQuality: FilterQuality.medium,
                          )
                        : null,
                pageLabel: context.l10n.playlist,
                pageTitle: playlist.key,
                pageDescription: '',
                pageSubtile: '',
                showWindowControls: !playerToTheRight,
                audios: playlist.value,
                pageId: playlist.key,
                showTrack: playlist.value.firstOrNull?.trackNumber != null,
                editableName: true,
                deletable: true,
                controlPageButton: YaruIconButton(
                  icon: Icon(
                    YaruIcons.star_filled,
                    color: theme.primaryColor,
                  ),
                  onPressed: () => playlistModel.removePlaylist(playlist.key),
                ),
              );
            },
            iconBuilder: (context, selected) {
              return const Icon(
                YaruIcons.playlist,
              );
            },
          ),
      if (playlistModel.audioPageType == null ||
          playlistModel.audioPageType == AudioPageType.album)
        for (final album in playlistModel.pinnedAlbums.entries)
          MasterItem(
            tileBuilder: (context) {
              return Text(createPlaylistName(album.key, context));
            },
            builder: (context) {
              final noPicture = album.value.firstOrNull == null ||
                  album.value.firstOrNull!.pictureData == null;

              return AudioPage(
                onArtistTap: (artist) => onTextTap(text: artist),
                onAlbumTap: (album) => onTextTap(text: album),
                audioPageType: AudioPageType.album,
                image: !noPicture
                    ? Image.memory(
                        album.value.firstOrNull!.pictureData!,
                        width: 200.0,
                        fit: BoxFit.fitWidth,
                        filterQuality: FilterQuality.medium,
                      )
                    : null,
                pageLabel: context.l10n.album,
                pageTitle: album.key,
                pageDescription: '',
                pageSubtile: album.value.firstOrNull?.artist ?? '',
                showWindowControls: !playerToTheRight,
                audios: album.value,
                pageId: album.key,
                showTrack: album.value.firstOrNull?.trackNumber != null,
                editableName: false,
                deletable: true,
                controlPageButton: YaruIconButton(
                  icon: Icon(
                    YaruIcons.pin,
                    color: theme.primaryColor,
                  ),
                  onPressed: () => playlistModel.removePinnedAlbum(album.key),
                ),
              );
            },
            iconBuilder: (context, selected) {
              final picture = album.value.firstOrNull?.pictureData!;
              Widget? albumArt;
              if (picture != null) {
                albumArt = SizedBox(
                  width: 23,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.memory(
                      picture,
                      height: 23,
                      fit: BoxFit.fitHeight,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                );
              }
              return albumArt ??
                  const Icon(
                    YaruIcons.playlist_play,
                  );
            },
          ),
      if (playlistModel.audioPageType == null ||
          playlistModel.audioPageType == AudioPageType.radio)
        for (final station in playlistModel.starredStations.entries)
          MasterItem(
            tileBuilder: (context) {
              return Text(station.key);
            },
            builder: (context) {
              return AudioPage(
                audioPageType: AudioPageType.radio,
                placeTrailer: false,
                showTrack: false,
                showWindowControls: !playerToTheRight,
                audios: station.value,
                pageId: station.key,
                pageTitle: station.key,
                editableName: false,
                deletable: false,
                controlPageButton: YaruIconButton(
                  icon: const Icon(YaruIcons.star_filled),
                  onPressed: () => playlistModel.unStarStation(station.key),
                ),
              );
            },
            iconBuilder: (context, selected) {
              return const Icon(YaruIcons.star);
            },
          )
    ];

    final settingsTile = LayoutBuilder(
      builder: (context, constraints) => ResponsiveMasterTile(
        title: const Text('Settings'),
        leading: const Icon(YaruIcons.settings),
        availableWidth: constraints.maxWidth,
        onTap: () => showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(
              titlePadding: EdgeInsets.zero,
              title: const YaruDialogTitleBar(
                title: Text('Chose collection directory'),
              ),
              children: [
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      localAudioModel.directory = await getDirectoryPath();
                      await localAudioModel
                          .init()
                          .then((value) => Navigator.of(context).pop());
                    },
                    child: const Text('Pick your music collection'),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );

    var yaruMasterDetailPage = YaruMasterDetailPage(
      onSelected: (value) => playlistModel.index = value ?? 0,
      appBar: const YaruWindowTitleBar(),
      bottomBar: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: settingsTile,
      ),
      layoutDelegate: shrinkSidebar ? delegateSmall : delegateBig,
      controller: YaruPageController(
        length: playlistModel.totalListAmount,
        initialIndex: playlistModel.index ?? 0,
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
            (playlistModel.totalListAmount > 5 ||
                playlistModel.audioPageType != null)) {
          var mainPageType = AudioPageType.values.where(
            (e) => !<AudioPageType>[
              AudioPageType.immutable,
              AudioPageType.likedAudio,
              AudioPageType.artist,
            ].contains(e),
          );

          column = Column(
            children: [
              tile,
              Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                  bottom: 5,
                  right: 18,
                  left: 18,
                ),
                child: YaruChoiceChipBar(
                  wrap: true,
                  labels: mainPageType
                      .map((e) => Text(e.localize(context.l10n)))
                      .toList(),
                  onSelected: (index) => playlistModel
                      .setAudioPageType(mainPageType.elementAt(index)),
                  isSelected: mainPageType
                      .map((e) => e == playlistModel.audioPageType)
                      .toList(),
                ),
              ),
            ],
          );
        }

        return column ?? tile;
      },
      pageBuilder: (context, index) => YaruDetailPage(
        body: masterItems[index].builder(context),
      ),
    );

    return Scaffold(
      key: ValueKey(shrinkSidebar),
      backgroundColor: surfaceTintColor,
      body: isFullScreen == true
          ? const Column(
              children: [
                YaruWindowTitleBar(
                  border: BorderSide.none,
                  backgroundColor: Colors.transparent,
                ),
                Expanded(child: PlayerView())
              ],
            )
          : !playerToTheRight
              ? Column(
                  children: [
                    Expanded(
                      child: yaruMasterDetailPage,
                    ),
                    const Divider(
                      height: 0,
                    ),
                    const PlayerView()
                  ],
                )
              : Row(
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
                ),
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
