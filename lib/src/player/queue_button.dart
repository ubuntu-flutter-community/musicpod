import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

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
    final libraryModel = context.read<LibraryModel>();

    return IconButton(
      color: color,
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
    final service = getService<PlayerService>();
    final currentAudio = service.audio.watch(context);
    final queue = service.queue.value.$2;
    if (currentAudio != null && queue.isNotEmpty == true) {
      _controller.scrollToIndex(
        queue.indexOf(currentAudio),
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
    final service = getService<PlayerService>();

    final queue = service.queue.watch(context).$2;
    final queueLength = queue.length;
    final currentAudio = service.audio.watch(context);

    return AlertDialog(
      key: ValueKey(queueLength),
      titlePadding:
          const EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 10),
      contentPadding: const EdgeInsets.only(bottom: 20, top: 10),
      title: Column(
        children: [
          PlayerMainControls(
            podcast: false,
            playPrevious: () async => await service.playPrevious().then(
                  (_) => _jump(),
                ),
            playNext: () async => await service.playNext().then(
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
                            selected ? null : () => service.remove(audio),
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
                onReorder: service.moveAudioInQueue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
