import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/data/audio_type.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/string_x.dart';
import '../../l10n/l10n.dart';
import '../../radio/view/radio_history_list.dart';
import '../../settings/settings_model.dart';
import '../mpv_metadata_manager.dart';
import '../player_model.dart';
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
    final audio = watchPropertyValue((PlayerModel m) => m.audio);

    final splitByDash = watchValue(
      (MpvMetadataManager m) =>
          m.mpvMetaDataCommand.select((cmd) => cmd?.icyTitle.splitByDash),
    );

    return Column(
      children: [
        TabBar(
          controller: _controller,
          tabs: [
            Tab(
              text: audio?.isRadio == true
                  ? context.l10n.hearingHistory
                  : context.l10n.queue,
            ),
            Tab(text: context.l10n.lyrics),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: kLargestSpace),
            child: TabBarView(
              controller: _controller,
              children: [
                if (audio?.audioType == AudioType.radio) ...[
                  const RadioHistoryList(simpleList: true),
                ] else ...[
                  const QueueBody(),
                ],
                PlayerLyrics(
                  key: ValueKey(audio.toString() + splitByDash.toString()),
                  title: audio?.audioType != AudioType.radio
                      ? null
                      : splitByDash?.songName,
                  artist: audio?.audioType != AudioType.radio
                      ? null
                      : splitByDash?.artist,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
