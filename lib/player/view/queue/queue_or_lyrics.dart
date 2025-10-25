import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';
import '../../../common/view/ui_constants.dart';
import '../../../l10n/l10n.dart';
import '../../../settings/settings_model.dart';
import '../../player_model.dart';
import '../player_lyrics.dart';
import 'queue_body.dart';

class QueueOrLyrics extends StatefulWidget with WatchItStatefulWidgetMixin {
  const QueueOrLyrics({
    super.key,
    this.selectedColor,
    this.shownInDialog = false,
  });

  final Color? selectedColor;
  final bool shownInDialog;

  @override
  State<QueueOrLyrics> createState() => _QueueOrLyricsState();
}

class _QueueOrLyricsState extends State<QueueOrLyrics>
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
    final audio = watchPropertyValue((PlayerModel m) => m.audio);

    return Column(
      spacing: kLargestSpace,
      children: [
        YaruTabBar(
          onTap: (i) => di<SettingsModel>().setShowPlayerLyrics(i == 1),
          tabs: [
            Tab(text: context.l10n.queue),
            Tab(text: context.l10n.lyrics),
          ],
          tabController: _controller,
        ),
        Expanded(
          child: TabBarView(
            controller: _controller,
            children: [
              QueueBody(
                selectedColor: widget.selectedColor,
                shownInDialog: widget.shownInDialog,
              ),
              audio == null
                  ? const SizedBox.shrink()
                  : PlayerLyrics(audio: audio),
            ],
          ),
        ),
      ],
    );
  }
}
