import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/full_window_mode_manager.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/icons.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/platform_x.dart';
import 'full_window_player_top_controls.dart';

class FullWindowPlayerHeaderBar extends ConsumerWidget {
  const FullWindowPlayerHeaderBar({super.key, required this.isVideo});

  final bool isVideo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HeaderBar(
      heroTag: 'fullWindowPlayerHeaderBar',
      hideOnMobile: true,
      leading: isMobile
          ? Center(
              child: IconButton(
                tooltip: context.l10n.leaveFullWindow,
                icon: Icon(
                  Iconz.fullWindowExit,
                  color: isVideo == true ? Colors.white : null,
                ),
                onPressed: () => ref
                    .read(fullWindowModeManagerProvider.notifier)
                    .setFullWindowMode(false),
              ),
            )
          : null,
      includeBackButton: false,
      includeSidebarButton: false,
      title: const Text('', maxLines: 1, overflow: TextOverflow.ellipsis),
      foregroundColor: isVideo == true ? Colors.white : null,
      backgroundColor: isVideo == true ? Colors.black : Colors.transparent,
      actions: [
        FullWindowPlayerTopControls(
          iconColor: isVideo ? Colors.white : context.colorScheme.onSurface,
          video: isVideo,
        ),
      ],
    );
  }
}
