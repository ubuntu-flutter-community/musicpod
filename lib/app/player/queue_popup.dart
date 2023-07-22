import 'package:flutter/material.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:yaru_icons/yaru_icons.dart';

class QueuePopup extends StatelessWidget {
  const QueuePopup({super.key, this.queue, this.audio});

  final List<Audio>? queue;
  final Audio? audio;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StatefulBuilder(
      key: ObjectKey(audio),
      builder: (context, stateSetter) {
        return PopupMenuButton<double>(
          tooltip: context.l10n.queue,
          icon: const Icon(
            YaruIcons.playlist,
          ),
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                child: SizedBox(
                  height: 200,
                  width: 300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 5),
                        child: Text(
                          context.l10n.upNext,
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          children: [
                            for (final e in queue ?? [])
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 5,
                                  right: 5,
                                ),
                                child: Text(
                                  '${e.title ?? ''} • ${e.artist ?? ''}',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: e == audio
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            ];
          },
        );
      },
    );
  }
}
