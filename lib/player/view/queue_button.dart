import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:watch_it/watch_it.dart';

import '../../app/app_model.dart';
import '../../app_config.dart';
import '../../common/data/audio.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/icons.dart';
import '../../common/view/modals.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../player_model.dart';
import 'player_main_controls.dart';

enum _Mode {
  icon,
  text;
}

class QueueButton extends StatelessWidget with WatchItMixin {
  const QueueButton({super.key, this.color, this.isSelected})
      : _mode = _Mode.icon;

  const QueueButton.text({super.key, this.color, this.isSelected})
      : _mode = _Mode.text;

  final Color? color;
  final bool? isSelected;

  final _Mode _mode;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final playerToTheRight = context.mediaQuerySize.width > kSideBarThreshHold;
    final isFullScreen = watchPropertyValue((AppModel m) => m.fullWindowMode);
    final radio = watchPropertyValue(
      (PlayerModel m) => m.audio?.audioType == AudioType.radio,
    );

    return switch (_mode) {
      _Mode.icon => IconButton(
          isSelected: isSelected ??
              watchPropertyValue((AppModel m) => m.showQueueOverlay),
          color: color ?? theme.colorScheme.onSurface,
          padding: EdgeInsets.zero,
          tooltip: radio ? context.l10n.hearingHistory : context.l10n.queue,
          icon: Icon(
            Iconz.playlist,
            color: color ?? theme.colorScheme.onSurface,
          ),
          onPressed: () => onPressed(playerToTheRight, isFullScreen, context),
        ),
      _Mode.text => TextButton(
          onPressed: () => onPressed(playerToTheRight, isFullScreen, context),
          child: Text(
            context.l10n.queue,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colorScheme.onSurface,
            ),
          ),
        )
    };
  }

  void onPressed(
    bool playerToTheRight,
    bool? isFullScreen,
    BuildContext context,
  ) {
    if ((playerToTheRight || isFullScreen == true) && !isMobilePlatform) {
      di<AppModel>().setOrToggleQueueOverlay();
    } else {
      showModal(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        content: ModalMode.platformModalMode == ModalMode.bottomSheet
            ? const QueueBody()
            : const QueueDialog(),
        mode: ModalMode.platformModalMode,
      );
    }
  }
}

class QueueDialog extends StatelessWidget with WatchItMixin {
  const QueueDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final queue = watchPropertyValue((PlayerModel m) => m.queue);

    return AlertDialog(
      titlePadding: const EdgeInsets.only(
        left: 10,
        right: 10,
        top: kLargestSpace,
        bottom: 10,
      ),
      contentPadding: const EdgeInsets.only(bottom: kLargestSpace, top: 10),
      title: const PlayerMainControls(active: true),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        OutlinedButton(
          onPressed: () {
            di<LibraryModel>().addPlaylist(
              '${context.l10n.queue} ${DateTime.now()}',
              List.from(queue),
            );
            Navigator.of(context).pop();
          },
          child: Text(context.l10n.createNewPlaylist),
        ),
      ],
      content: const QueueBody(),
    );
  }
}

class QueueBody extends StatefulWidget with WatchItStatefulWidgetMixin {
  const QueueBody({
    super.key,
    this.selectedColor,
  });

  final Color? selectedColor;

  @override
  State<QueueBody> createState() => _QueueBodyState();
}

class _QueueBodyState extends State<QueueBody> {
  late AutoScrollController _controller;
  Audio? _audio;

  @override
  void initState() {
    super.initState();
    _controller = AutoScrollController();
    _jump();
  }

  void _jump() {
    final model = di<PlayerModel>();
    final currentAudio = model.audio;
    if (currentAudio != null && model.queue.isNotEmpty == true) {
      _controller.scrollToIndex(
        model.queue.indexOf(currentAudio),
        preferPosition: AutoScrollPosition.middle,
        duration: const Duration(milliseconds: 1),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final queue = watchPropertyValue((PlayerModel m) => m.queue);
    watchPropertyValue((PlayerModel m) => m.queue.length);

    final queueName = watchPropertyValue((PlayerModel m) => m.queueName);
    final currentAudio = watchPropertyValue((PlayerModel m) => m.audio);
    if (_audio != currentAudio) {
      _jump();
    }
    _audio = currentAudio;
    return SizedBox(
      key: ValueKey(queue.length),
      width: 400,
      height: 500,
      child: Column(
        children: [
          Expanded(
            child: ReorderableListView.builder(
              scrollController: _controller,
              padding: const EdgeInsets.only(
                left: 25,
                right: 25,
              ),
              buildDefaultDragHandles: false,
              proxyDecorator: (child, index, animation) => Material(
                color: context.colorScheme.onSurface.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                child: child,
              ),
              itemBuilder: (context, index) {
                final audio = queue.elementAt(index);
                final selected = audio == currentAudio;

                return _QueueTile(
                  key: ValueKey(index),
                  index: index,
                  controller: _controller,
                  selectedColor: context.colorScheme.primary,
                  queueName: queueName,
                  queue: queue,
                  audio: audio,
                  selected: selected,
                );
              },
              itemCount: queue.length,
              onReorder: di<PlayerModel>().moveAudioInQueue,
            ),
          ),
        ],
      ),
    );
  }
}

class _QueueTile extends StatefulWidget {
  const _QueueTile({
    required super.key,
    required this.queueName,
    required this.queue,
    required this.audio,
    required this.selected,
    this.selectedColor,
    required this.index,
    required this.controller,
  });

  final int index;
  final String? queueName;
  final List<Audio> queue;
  final Audio audio;
  final bool selected;
  final Color? selectedColor;
  final AutoScrollController controller;

  @override
  State<_QueueTile> createState() => _QueueTileState();
}

class _QueueTileState extends State<_QueueTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return ReorderableDragStartListener(
      key: widget.key,
      index: widget.index,
      child: AutoScrollTag(
        index: widget.index,
        controller: widget.controller,
        key: ValueKey('${widget.key.toString()}${widget.index}'),
        child: MouseRegion(
          onEnter: (e) => setState(() => _hovered = true),
          onExit: (e) => setState(() => _hovered = false),
          child: ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            onTap: widget.queueName == null
                ? null
                : () => di<PlayerModel>()
                  ..setShuffle(false)
                  ..startPlaylist(
                    listName: widget.queueName!,
                    audios: widget.queue,
                    index: widget.queue.indexOf(widget.audio),
                  ),
            hoverColor: context.colorScheme.onSurface.withOpacity(0.3),
            leading: Visibility(
              visible: widget.selected,
              child: const Text('>'),
            ),
            contentPadding: const EdgeInsets.only(right: 10, left: 10),
            selected: widget.selected,
            selectedColor: widget.selectedColor,
            title: Text(widget.audio.title ?? ''),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_hovered && !widget.selected)
                  SizedBox.square(
                    dimension: 30,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => di<PlayerModel>().remove(widget.audio),
                      icon: Icon(Iconz.remove),
                    ),
                  )
                else
                  Visibility(
                    visible: widget.selected,
                    child: const Text('<'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
