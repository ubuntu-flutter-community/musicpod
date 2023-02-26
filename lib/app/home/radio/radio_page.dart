import 'package:flutter/material.dart';
import 'package:music/app/player_model.dart';
import 'package:music/data/audio.dart';
import 'package:music/data/stations.dart';
import 'package:provider/provider.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class RadioPage extends StatelessWidget {
  const RadioPage({super.key});

  @override
  Widget build(BuildContext context) {
    final playerModel = context.watch<PlayerModel>();
    final theme = Theme.of(context);
    return ListView.builder(
      padding: const EdgeInsets.all(kYaruPagePadding),
      itemCount: stationsMap.length,
      itemBuilder: (context, index) {
        final audioSelected = playerModel.audio?.url ==
            stationsMap.entries.elementAt(index).value;

        Future<void> onTap() async {
          if (playerModel.isPlaying && audioSelected) {
            playerModel.pause();
          } else {
            playerModel.audio = Audio(
              name: stationsMap.entries.elementAt(index).key,
              audioType: AudioType.radio,
              url: stationsMap.entries.elementAt(index).value,
            );
            await playerModel.play();
          }
        }

        return ListTile(
          contentPadding: const EdgeInsets.only(left: 8, right: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kYaruButtonRadius),
          ),
          onTap: onTap,
          title: Text(
            stationsMap.entries.elementAt(index).key,
            style: TextStyle(
              color:
                  audioSelected ? theme.colorScheme.onSurface : theme.hintColor,
            ),
          ),
          trailing: YaruIconButton(
            icon: const Icon(YaruIcons.star),
            onPressed: () {},
          ),
        );
      },
    );
  }
}
