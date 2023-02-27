import 'package:flutter/material.dart';
import 'package:music/app/common/audio_tile.dart';
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
    final page = ListView.builder(
      padding: const EdgeInsets.all(kYaruPagePadding),
      itemCount: stationsMap.length,
      itemBuilder: (context, index) {
        final audioSelected = playerModel.audio?.url ==
            stationsMap.entries.elementAt(index).value;

        final audio = Audio(
          name: stationsMap.entries.elementAt(index).key,
          audioType: AudioType.radio,
          url: stationsMap.entries.elementAt(index).value,
        );

        return AudioTile(
          selected: audioSelected,
          audio: audio,
          likeIcon: const Icon(YaruIcons.star),
        );
      },
    );

    final appBar = YaruWindowTitleBar(
      leading: Navigator.of(context).canPop()
          ? const YaruBackButton(
              style: YaruBackButtonStyle.rounded,
            )
          : const SizedBox(
              width: 40,
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
          : Center(child: Text(context.l10n.radio)),
    );

    return YaruDetailPage(
      appBar: appBar,
      body: page,
    );
  }
}
