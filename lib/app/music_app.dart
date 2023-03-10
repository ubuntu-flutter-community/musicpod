import 'package:collection/collection.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:mpris_service/mpris_service.dart';
import 'package:musicpod/app/common/audio_page.dart';
import 'package:musicpod/app/common/safe_network_image.dart';
import 'package:musicpod/app/local_audio/local_audio_model.dart';
import 'package:musicpod/app/local_audio/local_audio_page.dart';
import 'package:musicpod/app/player_model.dart';
import 'package:musicpod/app/player_view.dart';
import 'package:musicpod/app/playlists/playlist_dialog.dart';
import 'package:musicpod/app/playlists/playlist_model.dart';
import 'package:musicpod/app/podcasts/podcast_model.dart';
import 'package:musicpod/app/podcasts/podcasts_page.dart';
import 'package:musicpod/app/radio/radio_page.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:musicpod/utils.dart';
import 'package:provider/provider.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

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
          create: (_) => PlayerModel(getService<MPRIS>())..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => LocalAudioModel()..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => PlaylistModel()..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => PodcastModel()
            ..init(
              WidgetsBinding.instance.window.locale.countryCode?.toUpperCase(),
            ),
        )
      ],
      child: const _App(),
    );
  }

  @override
  State<_App> createState() => _AppState();
}

class _AppState extends State<_App> with TickerProviderStateMixin {
  final _delegateSmall = const YaruMasterResizablePaneDelegate(
    initialPaneWidth: 81,
    minPaneWidth: 81,
    minPageWidth: kYaruMasterDetailBreakpoint / 2,
  );

  final _delegateBig = const YaruMasterResizablePaneDelegate(
    initialPaneWidth: 200,
    minPaneWidth: 81,
    minPageWidth: kYaruMasterDetailBreakpoint / 2,
  );

  @override
  void initState() {
    super.initState();
    YaruWindow.of(context).onClose(
      () {
        context.read<PlayerModel>().dispose();
        return true;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localAudioModel = context.watch<LocalAudioModel>();

    final isPlaying = context.select((PlayerModel m) => m.isPlaying);
    final audioType = context.select((PlayerModel m) => m.audio?.audioType);
    final surfaceTintColor =
        context.select((PlayerModel m) => m.surfaceTintColor);
    final isFullScreen = context.select((PlayerModel m) => m.fullScreen);

    final playlistModel = context.watch<PlaylistModel>();
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final shrinkSidebar = (width < 700);
    final playerToTheRight = width > 1700;

    final orbit = Padding(
      padding: const EdgeInsets.only(left: 3),
      child: SizedBox(
        width: 16,
        height: 16,
        child: LoadingIndicator(
          strokeWidth: 0.0,
          indicatorType: Indicator.lineScaleParty,
          pause: !isPlaying,
        ),
      ),
    );

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
        iconBuilder: (context, selected) {
          if (audioType == AudioType.local) {
            return orbit;
          }
          return Stack(
            children: [
              selected
                  ? const Icon(YaruIcons.drive_harddisk_filled)
                  : const Icon(YaruIcons.drive_harddisk),
              Positioned(
                left: 5,
                top: 1,
                child: Icon(
                  YaruIcons.music_note,
                  size: 10,
                  color: selected
                      ? theme.colorScheme.surface
                      : theme.colorScheme.onSurface,
                ),
              )
            ],
          );
        },
      ),
      MasterItem(
        tileBuilder: (context) {
          return Text(context.l10n.radio);
        },
        builder: (context) {
          return RadioPage.create(context, !playerToTheRight);
        },
        iconBuilder: (context, selected) {
          if (audioType == AudioType.radio) {
            return orbit;
          }

          return selected
              ? const Icon(YaruIcons.radio_filled)
              : const Icon(YaruIcons.radio);
        },
      ),
      MasterItem(
        tileBuilder: (context) {
          return Text(context.l10n.podcasts);
        },
        builder: (context) {
          return PodcastsPage(showWindowControls: !playerToTheRight);
        },
        iconBuilder: (context, selected) {
          if (audioType == AudioType.podcast) {
            return orbit;
          }
          return selected
              ? const Icon(YaruIcons.podcast_filled)
              : const Icon(YaruIcons.podcast);
        },
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
            audioPageType: AudioPageType.likedAudio,
            placeTrailer: false,
            showWindowControls: !playerToTheRight,
            audios: playlistModel.likedAudios,
            pageId: 'likedAudio',
            pageTitle: context.l10n.likedSongs,
            editableName: false,
            deletable: false,
            likePageButton: const SizedBox.shrink(),
          );
        },
        iconBuilder: (context, selected) {
          return const Icon(YaruIcons.heart);
        },
      ),
      for (final podcast in playlistModel.podcasts.entries)
        MasterItem(
          tileBuilder: (context) {
            return Text(podcast.key);
          },
          builder: (context) {
            final noImage = podcast.value.firstOrNull == null ||
                podcast.value.firstOrNull!.imageUrl == null;

            return AudioPage(
              audioPageType: AudioPageType.podcast,
              image: !noImage
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
                      url: podcast.value.firstOrNull!.imageUrl,
                      fit: BoxFit.fitWidth,
                      filterQuality: FilterQuality.medium,
                    )
                  : null,
              pageLabel: context.l10n.podcast,
              pageTitle: podcast.key,
              showWindowControls: !playerToTheRight,
              audios: podcast.value,
              pageId: podcast.key,
              showTrack: false,
              editableName: false,
              deletable: false,
              likePageButton: YaruIconButton(
                icon: Icon(
                  YaruIcons.rss,
                  color: theme.primaryColor,
                ),
                onPressed: () => playlistModel.removePodcast(podcast.key),
              ),
            );
          },
          iconBuilder: (context, selected) {
            return const Icon(
              YaruIcons.rss,
            );
          },
        ),
      for (final playlist in playlistModel.playlists.entries)
        MasterItem(
          tileBuilder: (context) {
            return Text(playlist.key);
          },
          builder: (context) {
            final noPicture = playlist.value.firstOrNull == null ||
                playlist.value.firstOrNull!.metadata == null ||
                playlist.value.firstOrNull!.metadata!.picture == null;

            final noImage = playlist.value.firstOrNull == null ||
                playlist.value.firstOrNull!.imageUrl == null;

            return AudioPage(
              audioPageType: AudioPageType.playlist,
              image: !noPicture
                  ? Image.memory(
                      playlist.value.firstOrNull!.metadata!.picture!.data,
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
              showTrack:
                  playlist.value.firstOrNull?.metadata?.trackNumber != null,
              editableName: true,
              deletable: true,
              likePageButton: YaruIconButton(
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
              YaruIcons.star,
            );
          },
        ),
      for (final album in playlistModel.pinnedAlbums.entries)
        MasterItem(
          tileBuilder: (context) {
            return Text(createPlaylistName(album.key, context));
          },
          builder: (context) {
            final noPicture = album.value.firstOrNull == null ||
                album.value.firstOrNull!.metadata == null ||
                album.value.firstOrNull!.metadata!.picture == null;

            final noImage = album.value.firstOrNull == null ||
                album.value.firstOrNull!.imageUrl == null;

            return AudioPage(
              audioPageType: AudioPageType.album,
              image: !noPicture
                  ? Image.memory(
                      album.value.firstOrNull!.metadata!.picture!.data,
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
                          url: album.value.firstOrNull!.imageUrl,
                          fit: BoxFit.fitWidth,
                          filterQuality: FilterQuality.medium,
                        )
                      : null,
              pageLabel: context.l10n.album,
              pageTitle: album.key,
              pageDescription: '',
              pageSubtile: '',
              showWindowControls: !playerToTheRight,
              audios: album.value,
              pageId: album.key,
              showTrack: album.value.firstOrNull?.metadata?.trackNumber != null,
              editableName: false,
              deletable: true,
              likePageButton: YaruIconButton(
                icon: Icon(
                  YaruIcons.pin,
                  color: theme.primaryColor,
                ),
                onPressed: () => playlistModel.removePinnedAlbum(album.key),
              ),
            );
          },
          iconBuilder: (context, selected) {
            return const Icon(
              YaruIcons.pin,
            );
          },
        ),
      for (final station in playlistModel.starredStations.entries)
        MasterItem(
          tileBuilder: (context) {
            return Text(station.key);
          },
          builder: (context) {
            return AudioPage(
              audioPageType: AudioPageType.radio,
              placeTrailer: false,
              showWindowControls: !playerToTheRight,
              audios: station.value,
              pageId: station.key,
              pageTitle: station.key,
              editableName: false,
              deletable: false,
              likePageButton: YaruIconButton(
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

    final settingsTile = YaruMasterTile(
      title: const Text('Settings'),
      leading: const Icon(YaruIcons.settings),
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
    );

    var yaruMasterDetailPage = YaruMasterDetailPage(
      onSelected: (value) => playlistModel.index = value ?? 0,
      appBar: const YaruWindowTitleBar(),
      bottomBar: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: settingsTile,
      ),
      layoutDelegate: shrinkSidebar ? _delegateSmall : _delegateBig,
      controller: YaruPageController(
        length: playlistModel.totalListAmount,
        initialIndex: playlistModel.index ?? 0,
      ),
      tileBuilder: (context, index, selected) {
        final tile = YaruMasterTile(
          title: masterItems[index].tileBuilder(context),
          leading: masterItems[index].iconBuilder == null
              ? null
              : masterItems[index].iconBuilder!(
                  context,
                  selected,
                ),
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
          ? Column(
              children: const [
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
                    SizedBox(
                      width: 500,
                      child: Column(
                        children: const [
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
