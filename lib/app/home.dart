import 'package:flutter/material.dart';
import 'package:music/app/home_model.dart';
import 'package:music/app/player_model.dart';
import 'package:music/app/tabbed_page.dart';
import 'package:music/data/audio.dart';
import 'package:music/data/stations.dart';
import 'package:music/l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final playerModel = context.watch<PlayerModel>();
    final homeModel = context.watch<HomeModel>();

    final theme = Theme.of(context);
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
      views: [
        const Center(
          child: Text('Local Audio'),
        ),
        ListView.builder(
          padding: const EdgeInsets.all(kYaruPagePadding),
          itemCount: stationsMap.length,
          itemBuilder: (context, index) {
            final audioSelected = playerModel.audio?.resourceUrl ==
                stationsMap.entries.elementAt(index).value;

            Future<void> onTap() async {
              if (playerModel.isPlaying && audioSelected) {
                playerModel.pause();
              } else {
                playerModel.audio = Audio(
                  title: stationsMap.entries.elementAt(index).key,
                  audioType: AudioType.radio,
                  resourceUrl: stationsMap.entries.elementAt(index).value,
                );
                await playerModel.play();
              }
            }

            return ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kYaruButtonRadius),
              ),
              onTap: onTap,
              title: Text(
                stationsMap.entries.elementAt(index).key,
                style: TextStyle(
                  color: audioSelected
                      ? theme.colorScheme.onSurface
                      : theme.hintColor,
                ),
              ),
              trailing: audioSelected
                  ? Icon(
                      YaruIcons.media_play,
                      color: theme.colorScheme.primary,
                    )
                  : null,
            );
          },
        ),
        const Center(
          child: Text('Podcasts'),
        )
      ],
    );
  }
}
