import 'package:flutter/material.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';

import '../../common.dart';
import '../../data.dart';
import '../../player.dart';
import '../l10n/l10n.dart';

class QueuePopup extends StatelessWidget {
  const QueuePopup({super.key, this.audio});

  final Audio? audio;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final queue = context.select((PlayerModel m) => m.queue);

    final content = SizedBox(
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
                for (final e in queue)
                  Text(
                    createQueueElement(e),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: e == audio
                          ? theme.colorScheme.onSurface
                          : theme.hintColor,
                      fontWeight:
                          e == audio ? FontWeight.bold : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    return IconButton(
      padding: EdgeInsets.zero,
      tooltip: context.l10n.queue,
      icon: Icon(
        Iconz().playlist,
      ),
      onPressed: () => showStyledPopover(
        context: context,
        content: content,
        direction: PopoverDirection.top,
      ),
    );
  }
}
