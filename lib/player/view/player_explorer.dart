import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/data/audio_type.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/string_x.dart';
import '../../radio/radio_model.dart';
import '../../radio/view/radio_history_list.dart';
import '../../settings/settings_model.dart';
import '../player_model.dart';
import 'audio_visualizer.dart';
import 'player_lyrics.dart';
import 'queue/queue_body.dart';

class PlayerExplorer extends StatefulWidget with WatchItStatefulWidgetMixin {
  const PlayerExplorer({
    super.key,
    this.selectedColor,
    this.shownInDialog = false,
  });

  final Color? selectedColor;
  final bool shownInDialog;

  @override
  State<PlayerExplorer> createState() => _PlayerExplorerState();
}

class _PlayerExplorerState extends State<PlayerExplorer>
    with TickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(
      length: 2,
      vsync: this,
      initialIndex: di<SettingsModel>().showPlayerLyrics ? 1 : 0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showPlayerLyrics = watchPropertyValue(
      (SettingsModel m) => m.showPlayerLyrics,
    );
    if (showPlayerLyrics) {
      setState(() => _controller.index = 1);
    }

    final showAudioVisualizer = watchPropertyValue(
      (PlayerModel m) => m.showAudioVisualizer,
    );

    final audio = watchPropertyValue((PlayerModel m) => m.audio);

    final splitByDash = watchPropertyValue(
      (RadioModel m) => m.mpvMetaData?.icyTitle.splitByDash,
    );

    return Padding(
      padding: const EdgeInsets.only(top: kLargestSpace),
      child: Builder(
        builder: (context) {
          if (showAudioVisualizer) {
            return const AudioVisualizer(height: 200);
          }

          if (showPlayerLyrics)
            return audio == null
                ? const SizedBox.shrink()
                : audio.audioType == AudioType.podcast
                ? const NoLyricsFound()
                : PlayerLyrics(
                    key: ValueKey(audio.toString() + splitByDash.toString()),
                    title: audio.audioType != AudioType.radio
                        ? null
                        : splitByDash?.songName,
                    artist: audio.audioType != AudioType.radio
                        ? null
                        : splitByDash?.artist,
                    audio: audio,
                  );

          return audio?.audioType == AudioType.radio
              ? const RadioHistoryList(simpleList: true)
              : QueueBody(
                  selectedColor: widget.selectedColor,
                  shownInDialog: widget.shownInDialog,
                );
        },
      ),
    );
  }
}
