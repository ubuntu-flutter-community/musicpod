import 'package:flutter/material.dart';

import '../../data.dart';
import '../common/icons.dart';
import '../l10n/l10n.dart';

class QueuePopup extends StatelessWidget {
  const QueuePopup({super.key, this.queue, this.audio});

  final List<Audio>? queue;
  final Audio? audio;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopupMenuButton<double>(
      padding: EdgeInsets.zero,
      tooltip: context.l10n.queue,
      icon: Icon(
        Iconz().playlist,
      ),
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            padding: EdgeInsets.zero,
            child: SizedBox(
              height: 200,
              width: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5, left: 20),
                    child: Text(
                      context.l10n.queue,
                      style: theme.textTheme.labelMedium,
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                      ),
                      children: [
                        for (final e in queue ?? [])
                          Text(
                            '${e.title ?? ''} • ${e.artist ?? ''}',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: e == audio
                                  ? theme.colorScheme.onSurface
                                  : theme.hintColor,
                              fontWeight: e == audio
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ];
      },
    );
  }
}
