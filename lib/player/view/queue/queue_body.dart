import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../../common/data/audio.dart';
import '../../../common/view/confirm.dart';
import '../../../common/view/icons.dart';
import '../../../common/view/ui_constants.dart';
import '../../../extensions/build_context_x.dart';
import '../../../local_audio/local_audio_manager.dart';
import '../../../local_audio/playlist_action.dart';
import '../../player_model.dart';

class QueueBody extends StatefulWidget with WatchItStatefulWidgetMixin {
  const QueueBody({super.key, this.selectedColor, this.shownInDialog = false});

  final Color? selectedColor;
  final bool shownInDialog;

  @override
  State<QueueBody> createState() => _QueueBodyState();
}

class _QueueBodyState extends State<QueueBody>
    with AutomaticKeepAliveClientMixin {
  final AutoScrollController _controller = AutoScrollController();

  void _jump() {
    final model = di<PlayerModel>();
    final currentAudio = model.audio;
    if (currentAudio != null &&
        model.queue.isNotEmpty == true &&
        _controller.hasClients) {
      _controller.scrollToIndex(
        model.queue.indexOf(currentAudio),
        preferPosition: AutoScrollPosition.middle,
        duration: const Duration(milliseconds: 1),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final l10n = context.l10n;
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    final queueAutoScroll = watchPropertyValue(
      (PlayerModel m) => m.queueAutoScroll,
    );

    callOnceAfterThisBuild((_) {
      if (queueAutoScroll) {
        _jump();
      }
    });
    onDispose(_controller.dispose);

    registerStreamHandler(
      select: (PlayerModel m) => m.newAudioStream,
      handler: (context, snapshot, cancel) {
        if (!snapshot.hasData) return;
        if (queueAutoScroll) {
          _jump();
        }
      },
    );

    final currentAudio = watchPropertyValue((PlayerModel m) => m.audio);
    final queueLength = watchPropertyValue((PlayerModel m) => m.queue.length);

    final queue = di<PlayerModel>().queue;
    final queueName = di<PlayerModel>().queueName;

    return SizedBox(
      width: 400,
      height: 500,
      child: Column(
        spacing: kLargestSpace,
        children: [
          Expanded(
            child: ReorderableListView.builder(
              scrollController: _controller,
              padding: const EdgeInsets.only(left: 25, right: 25),
              buildDefaultDragHandles: false,
              proxyDecorator: (child, index, animation) => Material(
                color: colorScheme.onSurface.withValues(alpha: 0.1),
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
                  selectedColor: colorScheme.onSurface,
                  queueName: queueName,
                  queue: queue,
                  audio: audio,
                  selected: selected,
                );
              },
              itemCount: queueLength,
              onReorder: di<PlayerModel>().moveAudioInQueue,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 3 * kLargestSpace),
            child: Row(
              spacing: kMediumSpace,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  tooltip: l10n.createNewPlaylist,
                  onPressed: queue.where((e) => e.isLocal).isEmpty
                      ? null
                      : () => ConfirmationDialog.show(
                          context: context,
                          title: Text(l10n.createNewPlaylist + '?'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            spacing: kMediumSpace,
                            children: [
                              Text(
                                '"${l10n.queue} ${DateTime.now()}"',
                                style: theme.textTheme.titleMedium,
                              ),
                              Text(l10n.youCanEditTheNameLater),
                            ],
                          ),
                          onConfirm: () {
                            di<LocalAudioManager>()
                                .playlistCommand(
                                  '${l10n.queue} ${DateTime.now()}',
                                )
                                .run(
                                  PlaylistChange(
                                    id: '${l10n.queue} ${DateTime.now()}',
                                    audios: List.from(
                                      queue.where((e) => e.isLocal),
                                    ),
                                    action: PlaylistAction.create,
                                  ),
                                );
                            if (widget.shownInDialog && context.canPop()) {
                              context.pop();
                            }
                          },
                        ),
                  icon: Icon(
                    Iconz.createPlaylist,
                    color: queue.where((e) => e.isLocal).isEmpty
                        ? theme.disabledColor
                        : widget.selectedColor,
                  ),
                ),
                IconButton(
                  icon: Icon(Iconz.clearAll, semanticLabel: l10n.clearQueue),
                  tooltip: l10n.clearQueue,
                  onPressed:
                      queue.isEmpty ||
                          di<PlayerModel>().queueName == null ||
                          di<PlayerModel>().audio == null
                      ? null
                      : () => di<PlayerModel>().clearQueue(),
                ),
                IconButton(
                  tooltip: l10n.autoScrolling,
                  isSelected: queueAutoScroll,
                  icon: Icon(Iconz.autoScrollOn),
                  onPressed: () {
                    if (!di<PlayerModel>().queueAutoScroll) _jump();
                    di<PlayerModel>().toggleQueueAutoScroll();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: kLargestSpace),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            onTap: widget.queueName == null
                ? null
                : () => di<PlayerModel>()
                    ..setShuffle(false)
                    ..startPlaylist(
                      listName: widget.queueName!,
                      audios: widget.queue,
                      index: widget.queue.indexOf(widget.audio),
                    ),
            hoverColor: context.colorScheme.onSurface.withValues(alpha: 0.3),
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
                  Visibility(visible: widget.selected, child: const Text('<')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
