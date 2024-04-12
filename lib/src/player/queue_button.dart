import 'package:flutter/material.dart';

import 'package:scroll_to_index/scroll_to_index.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../data.dart';
import '../../library.dart';
import '../../player.dart';
import '../l10n/l10n.dart';

class QueueButton extends StatelessWidget {
  const QueueButton({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final libraryModel = getIt<LibraryModel>();

    return IconButton(
      color: color ?? theme.colorScheme.onSurface,
      padding: EdgeInsets.zero,
      tooltip: context.l10n.queue,
      icon: Icon(
        Iconz().playlist,
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return QueueDialog(
              addPlaylist: libraryModel.addPlaylist,
            );
          },
        );
      },
    );
  }
}

class QueueDialog extends StatefulWidget {
  const QueueDialog({
    super.key,
    required this.addPlaylist,
  });

  final void Function(String name, Set<Audio> audios) addPlaylist;

  @override
  State<QueueDialog> createState() => _QueueDialogState();
}

class _QueueDialogState extends State<QueueDialog> {
  late AutoScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AutoScrollController();
    _jump();
  }

  void _jump() {
    final model = getIt<PlayerModel>();
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
    final queue = ref.watch(playerModelProvider.select((m) => m.queue));
    final queueLength =
        ref.watch(playerModelProvider.select((m) => m.queue.length));
    final currentAudio = ref.watch(playerModelProvider.select((m) => m.audio));
    final playerModel = getIt<PlayerModel>();

    return AlertDialog(
      key: ValueKey(queueLength),
      titlePadding:
          const EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 10),
      contentPadding: const EdgeInsets.only(bottom: 20, top: 10),
      title: Column(
        children: [
          PlayerMainControls(
            podcast: false,
            playPrevious: () async => await playerModel.playPrevious().then(
                  (_) => _jump(),
                ),
            playNext: () async => await playerModel.playNext().then(
                  (_) => _jump(),
                ),
            active: true,
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        OutlinedButton(
          onPressed: () {
            widget.addPlaylist(
              '${context.l10n.queue} ${DateTime.now()}',
              Set.from(queue),
            );
            Navigator.of(context).pop();
          },
          child: Text(context.l10n.createNewPlaylist),
        ),
      ],
      content: SizedBox(
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
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final audio = queue.elementAt(index);
                  final selected = audio == currentAudio;

                  return AutoScrollTag(
                    key: ObjectKey(audio),
                    controller: _controller,
                    index: index,
                    child: ListTile(
                      leading: IconButton(
                        onPressed:
                            selected ? null : () => playerModel.remove(audio),
                        icon: Icon(Iconz().close),
                      ),
                      contentPadding: const EdgeInsets.only(right: 10, left: 0),
                      selected: selected,
                      key: ValueKey(index),
                      title: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Text(audio.title ?? ''),
                      ),
                    ),
                  );
                },
                itemCount: queue.length,
                onReorder: playerModel.moveAudioInQueue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
