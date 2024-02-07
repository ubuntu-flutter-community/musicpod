import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../build_context_x.dart';
import '../../data.dart';
import '../../player.dart';
import '../l10n/l10n.dart';

class UpNextBubble extends StatelessWidget {
  const UpNextBubble({
    super.key,
    required this.audio,
    required this.nextAudio,
  });

  final Audio? audio;
  final Audio? nextAudio;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;

    return Consumer(
      builder: (context, ref, _) {
        final setUpNextExpanded =
            ref.read(playerModelProvider).setUpNextExpanded;
        final isUpNextExpanded =
            ref.watch(playerModelProvider.select((p) => p.isUpNextExpanded));
        final queue = ref.watch(playerModelProvider.select((p) => p.queue));
        return SizedBox(
          height: isUpNextExpanded ? 180 : 70,
          width: 250,
          child: YaruBanner(
            onTap: () => setUpNextExpanded(!isUpNextExpanded),
            color: theme.cardColor,
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                    top: 10,
                    bottom: 5,
                    right: 10,
                  ),
                  child: Text(
                    isUpNextExpanded ? context.l10n.queue : context.l10n.upNext,
                    style: theme.textTheme.labelSmall,
                  ),
                ),
                if (isUpNextExpanded && queue.isNotEmpty && audio != null)
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 10),
                      children: [
                        for (final e in queue)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 10,
                              right: 10,
                            ),
                            child: Text(
                              createQueueElement(e),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: e == audio
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                      bottom: 10,
                    ),
                    child: Text(
                      createQueueElement(nextAudio),
                      style: theme.textTheme.labelMedium
                          ?.copyWith(color: theme.colorScheme.onSurface),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
