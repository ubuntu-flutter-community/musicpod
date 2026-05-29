import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/data/audio_type.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../radio/view/radio_history_list.dart';
import '../../settings/settings_model.dart';
import '../player_model.dart';
import 'full_window_player_image.dart';
import 'player_lyrics.dart';
import 'queue/queue_body.dart';

class PlayerExplorer extends StatefulWidget with WatchItStatefulWidgetMixin {
  const PlayerExplorer({
    super.key,
    this.selectedColor,
    this.includeImage = false,
  });

  final Color? selectedColor;
  final bool includeImage;

  @override
  State<PlayerExplorer> createState() => _PlayerExplorerState();
}

class _PlayerExplorerState extends State<PlayerExplorer>
    with TickerProviderStateMixin {
  late TabController _controller = _createController();

  @override
  void didUpdateWidget(covariant PlayerExplorer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.includeImage != widget.includeImage) {
      _controller = _createController();
    }
  }

  TabController _createController() {
    final length = widget.includeImage ? 3 : 2;
    final savedIndex = di<SettingsModel>().playerExplorerTabIndex;
    final initialIndex = savedIndex < length ? savedIndex : savedIndex - 1;
    return TabController(
      vsync: this,
      length: length,
      initialIndex: initialIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    onDispose(_controller.dispose);

    final audio = watchPropertyValue((PlayerModel m) => m.audio);

    return Column(
      spacing: kLargestSpace,
      children: [
        TabBar(
          onTap: (index) => di<SettingsModel>().setPlayerExplorerTabIndex(
            widget.includeImage
                ? index
                : index > 2
                ? 2
                : index,
          ),
          controller: _controller,
          tabs: [
            if (widget.includeImage) Tab(text: context.l10n.arts),
            Tab(
              text: audio?.isRadio == true
                  ? context.l10n.hearingHistory
                  : context.l10n.queue,
            ),
            Tab(text: context.l10n.lyrics),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _controller,
            children: [
              if (widget.includeImage) const FullWindowPlayerImage(),
              if (audio?.audioType == AudioType.radio)
                const RadioHistoryList(simpleList: true)
              else
                QueueBody(selectedColor: widget.selectedColor),
              const PlayerLyrics(),
            ],
          ),
        ),
      ],
    );
  }
}
