import 'package:flutter/material.dart';
import 'package:music/app/home/home_model.dart';
import 'package:music/app/home/local_audio/local_audio_page.dart';
import 'package:music/app/home/radio/radio_page.dart';
import 'package:music/app/tabbed_page.dart';
import 'package:music/l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:yaru_icons/yaru_icons.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeModel = context.watch<HomeModel>();

    return TabbedPage(
      initialIndex: homeModel.selectedTab,
      onTap: (index) => homeModel.selectedTab = index,
      tabIcons: const [
        Icon(YaruIcons.headphones),
        Icon(YaruIcons.globe),
        Icon(
          YaruIcons.network_cellular,
        )
      ],
      tabTitles: [
        context.l10n.localAudio,
        context.l10n.radio,
        context.l10n.podcasts,
      ],
      views: const [
        LocalAudioPage(),
        RadioPage(),
        Center(
          child: Text('Podcasts'),
        )
      ],
    );
  }
}
