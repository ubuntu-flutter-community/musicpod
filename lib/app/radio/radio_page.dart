import 'package:flutter/material.dart';
import 'package:music/app/player_model.dart';
import 'package:music/data/audio.dart';
import 'package:music/data/stations.dart';
import 'package:music/l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class RadioPage extends StatefulWidget {
  const RadioPage({super.key});

  @override
  State<RadioPage> createState() => _RadioPageState();
}

class _RadioPageState extends State<RadioPage> {
  bool _searchActive = false;
  @override
  Widget build(BuildContext context) {
    final playerModel = context.watch<PlayerModel>();
    final theme = Theme.of(context);
    final page = ListView.builder(
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

    final appBar = YaruWindowTitleBar(
      leading: Navigator.of(context).canPop()
          ? const YaruBackButton(
              style: YaruBackButtonStyle.rounded,
            )
          : null,
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
          : Text(context.l10n.radio),
    );

    return YaruDetailPage(
      appBar: appBar,
      body: page,
    );
  }
}
