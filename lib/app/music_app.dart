import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:music/app/home/home_model.dart';
import 'package:music/app/home/local_audio/local_audio_model.dart';
import 'package:music/app/home/local_audio/local_audio_page.dart';
import 'package:music/app/home/radio/radio_page.dart';
import 'package:music/app/player.dart';
import 'package:music/app/player_model.dart';
import 'package:music/l10n/l10n.dart';
import 'package:provider/provider.dart';
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
          create: (_) => PlayerModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => LocalAudioModel(),
        )
      ],
      child: const _App(),
    );
  }

  @override
  State<_App> createState() => _AppState();
}

class _AppState extends State<_App> {
  var _searchActive = false;

  @override
  Widget build(BuildContext context) {
    final localAudioModel = context.watch<LocalAudioModel>();

    final masterItems = [
      MasterItem(
        tileBuilder: (context) {
          return Text(context.l10n.localAudio);
        },
        builder: (context) {
          return const LocalAudioPage();
        },
        iconBuilder: (context, selected) {
          return selected
              ? const Icon(YaruIcons.headphones)
              : const Icon(YaruIcons.headphones);
        },
      ),
      MasterItem(
        tileBuilder: (context) {
          return Text(context.l10n.radio);
        },
        builder: (context) {
          return const RadioPage();
        },
        iconBuilder: (context, selected) {
          return selected
              ? const Icon(YaruIcons.globe_filled)
              : const Icon(YaruIcons.globe);
        },
      ),
      MasterItem(
        tileBuilder: (context) {
          return Text(context.l10n.podcasts);
        },
        builder: (context) {
          return Center(
            child: Text(context.l10n.podcasts),
          );
        },
        iconBuilder: (context, selected) {
          return selected
              ? const Icon(YaruIcons.network_cellular)
              : const Icon(YaruIcons.network_cellular);
        },
      ),
      MasterItem(
        tileBuilder: (context) {
          return Text(context.l10n.likedSongs);
        },
        builder: (context) {
          return Center(
            child: Text(context.l10n.likedSongs),
          );
        },
        iconBuilder: (context, selected) {
          return selected
              ? const Icon(YaruIcons.heart_filled)
              : const Icon(YaruIcons.heart);
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

    final appBar = YaruWindowTitleBar(
      leading: const YaruBackButton(
        style: YaruBackButtonStyle.rounded,
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Center(
            child: YaruIconButton(
              isSelected: _searchActive,
              icon: const Icon(YaruIcons.search),
              onPressed: () => setState(() {
                _searchActive = !_searchActive;
              }),
            ),
          ),
        )
      ],
      title: _searchActive
          ? const SizedBox(
              height: 35,
              // width: 400,
              child: TextField(),
            )
          : const Text('Ubuntu Music'),
    );

    return Scaffold(
      appBar: appBar,
      body: Column(
        children: [
          Expanded(
            child: YaruMasterDetailPage(
              bottomBar: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: settingsTile,
              ),
              layoutDelegate: const YaruMasterResizablePaneDelegate(
                initialPaneWidth: 200,
                minPaneWidth: 81,
                minPageWidth: kYaruMasterDetailBreakpoint / 2,
              ),
              length: masterItems.length,
              initialIndex: 0,
              tileBuilder: (context, index, selected) {
                final tile = YaruMasterTile(
                  title: masterItems[index].tileBuilder(context),
                  leading: masterItems[index].iconBuilder == null
                      ? null
                      : masterItems[index].iconBuilder!(context, selected),
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
