import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/data/audio.dart';
import '../../common/view/icons.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../player_model.dart';
import 'player_main_controls.dart';

class QueueButton extends StatelessWidget {
  const QueueButton({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;

    return IconButton(
      color: color ?? theme.colorScheme.onSurface,
      padding: EdgeInsets.zero,
      tooltip: context.l10n.queue,
      icon: Icon(
        Iconz().playlist,
        color: color ?? theme.colorScheme.onSurface,
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return const QueueDialog();
          },
        );
      },
    );
  }
}

class QueueDialog extends StatelessWidget with WatchItMixin {
  const QueueDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final queue = watchPropertyValue((PlayerModel m) => m.queue);
    final queueLength = watchPropertyValue((PlayerModel m) => m.queue.length);

    return AlertDialog(
      key: ValueKey(queueLength),
      titlePadding:
          const EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 10),
      contentPadding: const EdgeInsets.only(bottom: 20, top: 10),
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
    this.advancedList = true,
  });

  final bool advancedList;

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
        preferPosition: AutoScrollPosition.begin,
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
    final queueName = watchPropertyValue((PlayerModel m) => m.queueName);
    final currentAudio = watchPropertyValue((PlayerModel m) => m.audio);
    if (_audio != currentAudio) {
      _jump();
    }
    _audio = currentAudio;
    return SizedBox(
      width: 400,
      height: 500,
      child: Column(
        children: [
          Expanded(
            child: widget.advancedList
                ? ReorderableListView.builder(
                    scrollController: _controller,
                    padding: const EdgeInsets.only(
                      left: 25,
                      right: 25,
                    ),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final audio = queue.elementAt(index);
                      final selected = audio == currentAudio;

                      return AutoScrollTag(
                        key: ObjectKey(audio),
                        controller: _controller,
                        index: index,
                        child: _QueueTile(
                          key: ValueKey(index),
                          advancedTile: widget.advancedList,
                          queueName: queueName,
                          queue: queue,
                          audio: audio,
                          selected: selected,
                        ),
                      );
                    },
                    itemCount: queue.length,
                    onReorder: di<PlayerModel>().moveAudioInQueue,
                  )
                : ListView.builder(
                    itemCount: queue.length,
                    controller: _controller,
                    padding: const EdgeInsets.only(
                      left: 25,
                      right: 25,
                    ),
                    itemBuilder: (context, index) {
                      final audio = queue.elementAt(index);
                      final selected = audio == currentAudio;

                      return AutoScrollTag(
                        index: index,
                        controller: _controller,
                        key: ObjectKey(audio),
                        child: _QueueTile(
                          key: ValueKey(index),
                          advancedTile: widget.advancedList,
                          queueName: queueName,
                          queue: queue,
                          audio: audio,
                          selected: selected,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _QueueTile extends StatelessWidget {
  const _QueueTile({
    super.key,
    required this.advancedTile,
    required this.queueName,
    required this.queue,
    required this.audio,
    required this.selected,
  });

  final String? queueName;
  final List<Audio> queue;
  final Audio audio;
  final bool selected;
  final bool advancedTile;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: advancedTile
          ? null
          : RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      onTap: advancedTile
          ? null
          : queueName == null
              ? null
              : () => di<PlayerModel>().startPlaylist(
                    listName: queueName!,
                    audios: queue,
                    index: queue.indexOf(audio),
                  ),
      leading: advancedTile
          ? IconButton(
              onPressed:
                  selected ? null : () => di<PlayerModel>().remove(audio),
              icon: Icon(Iconz().close),
            )
          : null,
      contentPadding:
          advancedTile ? null : const EdgeInsets.only(right: 10, left: 0),
      selected: selected,
      key: key,
      title: Padding(
        padding: EdgeInsets.only(
          left: advancedTile ? 0 : 20,
          right: 20,
        ),
        child: Text(audio.title ?? ''),
      ),
    );
  }
}
