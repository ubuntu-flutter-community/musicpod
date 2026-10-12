import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../../common/data/audio.dart';
import '../../../common/view/confirm.dart';
import '../../../common/view/icons.dart';
import '../../../common/view/progress.dart';
import '../../../common/view/ui_constants.dart';
import '../../../extensions/build_context_x.dart';
import '../../../local_audio/data/playlist_action.dart';
import '../../../local_audio/manager/playlist_ids_manager.dart';
import '../../data/queue.dart';
import '../../manager/current_audio_manager.dart';
import '../../manager/queue_manager.dart';
import '../../manager/queue_scroll_manager.dart';
import '../../manager/shuffle_manager.dart';

class QueueBody extends ConsumerStatefulWidget {
  const QueueBody({super.key, this.selectedColor, this.shownInDialog = false});

  final Color? selectedColor;
  final bool shownInDialog;

  @override
  ConsumerState<QueueBody> createState() => _QueueBodyState();
}

class _QueueBodyState extends ConsumerState<QueueBody>
    with AutomaticKeepAliveClientMixin {
  final AutoScrollController _controller = AutoScrollController();
  bool _initialJumpDone = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final scrollState = ref.read(queueScrollManagerProvider);
      if (scrollState.autoScroll && !_initialJumpDone) {
        _initialJumpDone = true;
        final notifier = ref.read(queueScrollManagerProvider.notifier);
        _jump(
          isJumping: scrollState.isJumping,
          autoScrollEnabled: scrollState.autoScroll,
          setJumping: notifier.setJumping,
          setShowSpinner: notifier.setShowSpinner,
          showSpinner: true,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _jump({
    required bool isJumping,
    required bool autoScrollEnabled,
    required void Function(bool) setJumping,
    required void Function(bool) setShowSpinner,
    bool showSpinner = false,
  }) {
    final currentAudio = ref.read(currentAudioManagerProvider);
    final queue = ref.read(queueManagerProvider);
    if (!isJumping &&
        autoScrollEnabled &&
        currentAudio != null &&
        queue.audios.isNotEmpty &&
        _controller.hasClients) {
      final targetIndex = queue.audios.indexOf(currentAudio);
      if (targetIndex < 0) return;
      setJumping(true);
      if (showSpinner) {
        setShowSpinner(true);
      }
      _controller
          .scrollToIndex(
            targetIndex,
            preferPosition: AutoScrollPosition.middle,
            duration: const Duration(microseconds: 60),
          )
          .then((_) {
            setJumping(false);
            setShowSpinner(false);
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final l10n = context.l10n;
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    ref.listen(currentAudioManagerProvider, (previous, next) {
      if (next == null) return;
      final scrollState = ref.read(queueScrollManagerProvider);
      if (scrollState.autoScroll) {
        final notifier = ref.read(queueScrollManagerProvider.notifier);
        _jump(
          isJumping: scrollState.isJumping,
          autoScrollEnabled: scrollState.autoScroll,
          setJumping: notifier.setJumping,
          setShowSpinner: notifier.setShowSpinner,
        );
      }
    });

    final currentAudio = ref.watch(currentAudioManagerProvider);
    final queue = ref.watch(queueManagerProvider);
    final scrollState = ref.watch(queueScrollManagerProvider);
    final jumping = scrollState.isJumping;
    final showSpinnerWhileJumping = scrollState.showSpinner;
    final queueAutoScroll = scrollState.autoScroll;
    final notifier = ref.read(queueScrollManagerProvider.notifier);

    return SizedBox(
      width: 400,
      height: 500,
      child: Column(
        spacing: kLargestSpace,
        children: [
          Expanded(
            child: Stack(
              children: [
                if (jumping && showSpinnerWhileJumping)
                  const Center(child: Progress()),
                Opacity(
                  opacity: jumping && showSpinnerWhileJumping ? 0.0 : 1,
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
                      final audio = queue.audios.elementAt(index);
                      final selected = audio == currentAudio;

                      return _QueueTile(
                        key: ValueKey(index),
                        index: index,
                        controller: _controller,
                        selectedColor: colorScheme.onSurface,
                        queue: queue,
                        audio: audio,
                        selected: selected,
                      );
                    },
                    itemCount: queue.audios.length,
                    onReorderItem: ref
                        .read(queueManagerProvider.notifier)
                        .moveAudioInQueue,
                  ),
                ),
              ],
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
                  onPressed: queue.audios.where((e) => e.isLocal).isEmpty
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
                            ref
                                .read(playlistIDsManagerProvider.notifier)
                                .createOrChangePlaylist(
                                  PlaylistChange(
                                    id: '${l10n.queue} ${DateTime.now()}',
                                    audios: List.from(
                                      queue.audios.where((e) => e.isLocal),
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
                    color: queue.audios.where((e) => e.isLocal).isEmpty
                        ? theme.disabledColor
                        : widget.selectedColor,
                  ),
                ),
                IconButton(
                  icon: Icon(Iconz.clearAll, semanticLabel: l10n.clearQueue),
                  tooltip: l10n.clearQueue,
                  onPressed: queue.audios.isEmpty || currentAudio == null
                      ? null
                      : () => ref
                            .read(queueManagerProvider.notifier)
                            .clearQueue(),
                ),
                IconButton(
                  tooltip: l10n.autoScrolling,
                  isSelected: queueAutoScroll,
                  icon: Icon(Iconz.autoScrollOn),
                  onPressed: () {
                    if (!queueAutoScroll) {
                      _jump(
                        isJumping: jumping,
                        autoScrollEnabled: true,
                        setJumping: notifier.setJumping,
                        setShowSpinner: notifier.setShowSpinner,
                      );
                    }
                    notifier.toggleAutoScroll();
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

class _QueueTile extends ConsumerStatefulWidget {
  const _QueueTile({
    required super.key,
    required this.queue,
    required this.audio,
    required this.selected,
    this.selectedColor,
    required this.index,
    required this.controller,
  });

  final int index;
  final Audio audio;
  final Queue queue;
  final bool selected;
  final Color? selectedColor;
  final AutoScrollController controller;

  @override
  ConsumerState<_QueueTile> createState() => _QueueTileState();
}

class _QueueTileState extends ConsumerState<_QueueTile> {
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
            onTap: () async {
              await ref.read(shuffleManagerProvider.notifier).setShuffle(false);
              await ref
                  .read(currentAudioManagerProvider.notifier)
                  .play(
                    listName: widget.queue.name,
                    audios: widget.queue.audios,
                    index: widget.queue.audios.indexOf(widget.audio),
                  );
            },
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
                      onPressed: () => ref
                          .read(queueManagerProvider.notifier)
                          .remove(widget.audio),
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
