import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:mpris_service/mpris_service.dart';
import 'package:music/app/common/audio_page.dart';
import 'package:music/app/local_audio/local_audio_model.dart';
import 'package:music/app/local_audio/local_audio_page.dart';
import 'package:music/app/player.dart';
import 'package:music/app/player_model.dart';
import 'package:music/app/playlists/playlist_dialog.dart';
import 'package:music/app/playlists/playlist_model.dart';
import 'package:music/app/podcasts/podcast_model.dart';
import 'package:music/app/podcasts/podcasts_page.dart';
import 'package:music/app/radio/radio_page.dart';
import 'package:music/data/audio.dart';
import 'package:music/l10n/l10n.dart';
import 'package:music/utils.dart';
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
          create: (_) => PlayerModel(getService<MPRIS>()),
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
  @override
  Widget build(BuildContext context) {
    final localAudioModel = context.watch<LocalAudioModel>();
    final playerModel = context.watch<PlayerModel>();
    final playlistModel = context.watch<PlaylistModel>();
    final theme = Theme.of(context);

    final orbit = Padding(
      padding: const EdgeInsets.only(left: 3),
      child: SizedBox(
        width: 16,
        height: 16,
        child: LoadingIndicator(
          strokeWidth: 0.0,
          indicatorType: Indicator.lineScaleParty,
          pause: !playerModel.isPlaying,
        ),
      ),
    );

    final masterItems = [
      MasterItem(
        tileBuilder: (context) {
          return Text(context.l10n.localAudio);
        },
        builder: (context) {
          return const LocalAudioPage();
        },
        iconBuilder: (context, selected) {
          if (playerModel.audio?.audioType == AudioType.local) {
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
          return RadioPage.create(context);
        },
        iconBuilder: (context, selected) {
          if (playerModel.audio?.audioType == AudioType.radio) {
            return orbit;
          }

          return selected
              ? const Icon(YaruIcons.network_cellular)
              : const Icon(YaruIcons.network_cellular);
        },
      ),
      MasterItem(
        tileBuilder: (context) {
          return Text(context.l10n.podcasts);
        },
        builder: (context) {
          return const PodcastsPage();
        },
        iconBuilder: (context, selected) {
          if (playerModel.audio?.audioType == AudioType.podcast) {
            return orbit;
          }
          return selected
              ? const Icon(YaruIcons.microphone_filled)
              : const Icon(YaruIcons.microphone);
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
      for (final playlist in playlistModel.playlists.entries)
        MasterItem(
          tileBuilder: (context) {
            return Text(createPlaylistName(playlist.key, context));
          },
          builder: (context) {
            return AudioPage(
              audioPageType: playlist.key != 'likedAudio'
                  ? AudioPageType.albumList
                  : AudioPageType.list,
              audios: playlist.value,
              pageName: playlist.key,
              editableName: false,
              deletable: false,
              likeButton: playlist.key != 'likedAudio'
                  ? YaruIconButton(
                      icon: const Icon(YaruIcons.star_filled),
                      onPressed: () =>
                          playlistModel.removePlaylist(playlist.key),
                    )
                  : const SizedBox.shrink(),
            );
          },
          iconBuilder: (context, selected) {
            return playlist.key == 'likedAudio'
                ? const Icon(YaruIcons.heart)
                : const Icon(YaruIcons.star);
          },
        ),
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

    return Scaffold(
      backgroundColor: playerModel.surfaceTintColor,
      body: playerModel.fullScreen == true
          ? Column(
              children: const [
                YaruWindowTitleBar(
                  border: BorderSide.none,
                  backgroundColor: Colors.transparent,
                ),
                Expanded(child: Player())
              ],
            )
          : Column(
              children: [
                Expanded(
                  child: YaruMasterDetailPage(
                    onSelected: (value) => playlistModel.index = value ?? 0,
                    appBar: const YaruWindowTitleBar(
                      title: Text('Ubuntu Music'),
                    ),
                    bottomBar: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: settingsTile,
                    ),
                    layoutDelegate: const YaruMasterResizablePaneDelegate(
                      initialPaneWidth: 200,
                      minPaneWidth: 81,
                      minPageWidth: kYaruMasterDetailBreakpoint / 2,
                    ),
                    controller: YaruPageController(
                      length: playlistModel.playlists.length + 4,
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
                  ),
                ),
                const Divider(
                  height: 0,
                ),
                const Player()
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
