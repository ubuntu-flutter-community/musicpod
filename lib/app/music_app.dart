import 'package:flutter/material.dart';
import 'package:music/l10n/l10n.dart';
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
    return YaruNavigationPage(
      length: 3,
      leading: const SizedBox(
        width: 60,
        child: YaruWindowTitleBar(style: YaruTitleBarStyle.undecorated),
      ),
      itemBuilder: (context, index, selected) {
        switch (index) {
          case 0:
            return YaruNavigationRailItem(
              icon: const Icon(YaruIcons.headphones),
              style: YaruNavigationRailStyle.compact,
            );
          case 1:
            return YaruNavigationRailItem(
              icon: const Icon(YaruIcons.modem),
              style: YaruNavigationRailStyle.compact,
            );
          default:
            return YaruNavigationRailItem(
              icon: const Icon(YaruIcons.network_cellular),
              style: YaruNavigationRailStyle.compact,
            );
        }
      },
      pageBuilder: (context, index) {
        Widget body = const Center(
          child: YaruCircularProgressIndicator(),
        );

        switch (index) {
          case 0:
            body = Center(
              child: Text(context.l10n.music),
            );
            break;
          case 1:
            body = Center(
              child: Text(context.l10n.radio),
            );
            break;
          default:
            body = Center(
              child: Text(context.l10n.podcasts),
            );
            break;
        }

        return YaruDetailPage(
          appBar: YaruWindowTitleBar(
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
                    width: 400,
                    child: Padding(
                      padding: EdgeInsets.only(right: 40),
                      child: TextField(),
                    ),
                  )
                : Text(
                    index == 0
                        ? context.l10n.music
                        : index == 1
                            ? context.l10n.radio
                            : context.l10n.podcasts,
                  ),
          ),
          body: body,
        );
      },
    );
  }
}
