import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import 'package:music/l10n/l10n.dart';

const _kTestAudio =
    'https://d1o44v9snwqbit.cloudfront.net/musicfox_demo_MF-701.mp3';

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
          home: const Home(),
        );
      },
    );
  }
}

class Home extends StatefulWidget {
  const Home({
    super.key,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var _searchActive = false;
  final _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    _audioPlayer.onPlayerStateChanged.listen((playerState) {
      setState(() {
        _isPlaying = playerState == PlayerState.playing;
      });
    });
    _audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        _duration = newDuration;
      });
    });
    _audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        _position = newPosition;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final masterItems = [
      MasterItem(
        tileBuilder: (context) {
          return const Text('Home');
        },
        builder: (context) {
          return const Center(
            child: Text('Home'),
          );
        },
        iconBuilder: (context, selected) {
          return selected
              ? const Icon(YaruIcons.home_filled)
              : const Icon(YaruIcons.home);
        },
      ),
      MasterItem(
        tileBuilder: (context) {
          return const Text('Library');
        },
        builder: (context) {
          return const Center(
            child: Text('Library'),
          );
        },
        iconBuilder: (context, selected) {
          return selected
              ? const Icon(YaruIcons.book_filled)
              : const Icon(YaruIcons.book);
        },
      ),
      MasterItem(
        tileBuilder: (context) {
          return const Text('JP doggo walk playlist');
        },
        builder: (context) {
          return const Center(
            child: Text('JP doggo walk playlist'),
          );
        },
      ),
    ];

    final appBar = YaruWindowTitleBar(
      leading: Center(
        child: YaruIconButton(
          isSelected: _searchActive,
          icon: const Icon(YaruIcons.search),
          onPressed: () => setState(() {
            _searchActive = !_searchActive;
          }),
        ),
      ),
      title: _searchActive
          ? const SizedBox(
              height: 35,
              // width: 400,
              child: TextField(),
            )
          : const Text('Ubuntu Music'),
    );

    final audioPlayerBottom = SizedBox(
      height: 100,
      child: Column(
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: Slider(
                min: 0,
                max: _duration.inSeconds.toDouble(),
                value: _position.inSeconds.toDouble(),
                onChanged: (v) async {
                  final position = Duration(seconds: v.toInt());
                  await _audioPlayer.seek(position);
                  await _audioPlayer.resume();
                },
              ),
            ),
          ),
          SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: YaruIconButton(
                    icon: Icon(YaruIcons.skip_backward),
                  ),
                ),
                YaruIconButton(
                  onPressed: () async {
                    if (_isPlaying) {
                      await _audioPlayer.pause();
                    } else {
                      String url = _kTestAudio;
                      await _audioPlayer.play(UrlSource(url));
                    }
                  },
                  icon: Icon(
                    _isPlaying ? YaruIcons.media_pause : YaruIcons.media_play,
                  ),
                ),
                const Expanded(
                  child: YaruIconButton(
                    icon: Icon(YaruIcons.skip_forward),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Column(
      children: [
        appBar,
        Expanded(
          child: YaruMasterDetailPage(
            layoutDelegate: const YaruMasterResizablePaneDelegate(
              initialPaneWidth: 280,
              minPaneWidth: 170,
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

              if (index == 2) {
                column = Column(
                  children: [
                    const Divider(
                      height: 30,
                    ),
                    tile
                  ],
                );
              }

              return column ??
                  YaruMasterTile(
                    title: masterItems[index].tileBuilder(context),
                    leading: masterItems[index].iconBuilder == null
                        ? null
                        : masterItems[index].iconBuilder!(context, selected),
                  );
            },
            pageBuilder: (context, index) => YaruDetailPage(
              body: masterItems[index].builder(context),
            ),
          ),
        ),
        const Divider(
          height: 0,
        ),
        audioPlayerBottom
      ],
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
