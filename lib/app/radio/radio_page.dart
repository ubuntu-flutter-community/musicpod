import 'package:flutter/material.dart';
import 'package:music/app/common/audio_list.dart';
import 'package:music/app/common/search_field.dart';
import 'package:music/data/audio.dart';
import 'package:music/data/stations.dart';
import 'package:music/l10n/l10n.dart';
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
    final page = Padding(
      padding: const EdgeInsets.only(top: 20),
      child: AudioList(
        listName: context.l10n.radio,
        audios: Set.from(
          stationsMap.entries
              .map(
                (e) => Audio(
                  name: e.key,
                  url: e.value,
                  audioType: AudioType.radio,
                ),
              )
              .toList(),
        ),
      ),
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
          ? const SearchField()
          : Center(child: Text(context.l10n.radio)),
    );

    return YaruDetailPage(
      appBar: appBar,
      body: page,
    );
  }
}
