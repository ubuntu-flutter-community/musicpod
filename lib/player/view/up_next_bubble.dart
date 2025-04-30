import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../extensions/build_context_x.dart';
import '../../common/data/audio.dart';
import '../../player/player_model.dart';
import '../../l10n/l10n.dart';

class UpNextBubble extends StatelessWidget with WatchItMixin {
  const UpNextBubble({
    super.key,
    required this.audio,
    required this.nextAudio,
  });

  final Audio? audio;
  final Audio? nextAudio;

  String createQueueElement(Audio? audio) {
    final title = audio?.title?.isNotEmpty == true ? audio?.title! : '';
    final artist =
        audio?.artist?.isNotEmpty == true ? ' • ${audio?.artist}' : '';
    return '$title$artist'.trim();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final setUpNextExpanded = di<PlayerModel>().setUpNextExpanded;
    final isUpNextExpanded =
        watchPropertyValue((PlayerModel m) => m.isUpNextExpanded);
    final queue = watchPropertyValue((PlayerModel m) => m.queue);

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
  }
}
