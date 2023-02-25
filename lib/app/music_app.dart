import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import 'package:music/l10n/l10n.dart';

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
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Expanded(
            child: YaruIconButton(
              icon: Icon(YaruIcons.skip_backward),
            ),
          ),
          YaruIconButton(
            icon: Icon(YaruIcons.media_play),
          ),
          Expanded(
            child: YaruIconButton(
              icon: Icon(YaruIcons.skip_forward),
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
