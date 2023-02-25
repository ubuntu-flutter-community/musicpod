import 'package:flutter/material.dart';
import 'package:music/app/tabbed_page.dart';
import 'package:music/l10n/l10n.dart';
import 'package:yaru_icons/yaru_icons.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return TabbedPage(
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
        Center(
          child: Text('Local Audio'),
        ),
        Center(
          child: Text('Radio'),
        ),
        Center(
          child: Text('Podcasts'),
        )
      ],
    );
  }
}
