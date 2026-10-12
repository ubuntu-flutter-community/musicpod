import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/data/audio_type.dart';
import '../../common/view/ui_constants.dart';
import '../../dependencies.dart';
import '../../extensions/build_context_x.dart';
import '../../lyrics/view/lyrics_viewer.dart';
import '../../radio/view/radio_history_list.dart';
import '../../settings/data/shared_preferences_keys.dart';
import '../../settings/manager/settings_manager.dart';
import '../../settings/service/settings_service.dart';
import '../manager/current_audio_manager.dart';
import 'queue/queue_body.dart';

class PlayerExplorer extends ConsumerStatefulWidget {
  const PlayerExplorer({super.key, this.selectedColor, this.firstChild});

  final Color? selectedColor;
  final Widget? firstChild;

  @override
  ConsumerState<PlayerExplorer> createState() => _PlayerExplorerState();
}

class _PlayerExplorerState extends ConsumerState<PlayerExplorer>
    with TickerProviderStateMixin {
  late TabController _controller = _createController();

  @override
  void didUpdateWidget(covariant PlayerExplorer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.firstChild != widget.firstChild) {
      _controller = _createController();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  TabController _createController() {
    final length = widget.firstChild != null ? 3 : 2;
    final savedIndex =
        di<SettingsService>().getInt(SPKeys.playerExplorerTabIndex) ?? 0;
    final initialIndex = savedIndex < length ? savedIndex : savedIndex - 1;
    return TabController(
      vsync: this,
      length: length,
      initialIndex: initialIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final audio = ref.watch(currentAudioManagerProvider);

    return Column(
      spacing: kLargestSpace,
      children: [
        TabBar(
          onTap: (index) => ref
              .read(
                settingsIntManagerProvider(
                  SPKeys.playerExplorerTabIndex,
                ).notifier,
              )
              .set(
                widget.firstChild != null
                    ? index
                    : index > 2
                        ? 2
                        : index,
              ),
          controller: _controller,
          tabs: [
            if (widget.firstChild != null) Tab(text: context.l10n.arts),
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
              ?widget.firstChild,
              if (audio?.audioType == AudioType.radio)
                const RadioHistoryList(simpleList: true)
              else
                QueueBody(selectedColor: widget.selectedColor),
              const LyricsViewer(),
            ],
          ),
        ),
      ],
    );
  }
}
