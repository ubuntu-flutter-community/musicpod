import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../common.dart';
import '../../data.dart';
import '../../library.dart';
import '../../player.dart';
import '../l10n/l10n.dart';
import 'full_height_player_image.dart';

class QueueButton extends StatelessWidget {
  const QueueButton({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final playerModel = context.read<PlayerModel>();
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
            return ChangeNotifierProvider.value(
              value: playerModel,
              child: QueueDialog(
                addPlaylist: libraryModel.addPlaylist,
              ),
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
    final model = context.read<PlayerModel>();
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
    final queue = context.select((PlayerModel m) => m.queue);
    final queueLength = context.select((PlayerModel m) => m.queue.length);
    final currentAudio = context.select((PlayerModel m) => m.audio);
    final playerModel = context.read<PlayerModel>();

    return AlertDialog(
      key: ValueKey(queueLength),
      titlePadding: const EdgeInsets.only(left: 25, right: 25, top: 50),
      contentPadding: const EdgeInsets.only(bottom: 25, top: 5),
      title: Column(
        children: [
          FullHeightPlayerImage(
            audio: currentAudio,
            isOnline: true,
          ),
          const SizedBox(
            height: 20,
          ),
          FullHeightPlayerControls(
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
                      contentPadding:
                          const EdgeInsets.only(right: 20, left: 20),
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
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 45,
                    top: 15,
                  ),
                  child: OutlinedButton(
                    onPressed: () {
                      widget.addPlaylist(
                        '${context.l10n.queue} ${DateTime.now()}',
                        Set.from(queue),
                      );
                      Navigator.of(context).pop();
                    },
                    child: Text(context.l10n.createNewPlaylist),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
