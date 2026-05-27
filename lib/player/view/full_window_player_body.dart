import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import 'full_window_player_main_panel.dart';
import 'player_explorer.dart';

class FullWindowPlayerBody extends StatelessWidget with WatchItMixin {
  const FullWindowPlayerBody({super.key, required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final mediaQuerySize = context.mediaQuerySize;

    final playerWithSidePanel = mediaQuerySize.width > 2 * kPlayerExplorerWidth;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (playerWithSidePanel)
          SizedBox(
            width: kPlayerExplorerWidth,
            child: FullWindowPlayerMainPanel(active: active),
          ),
        Padding(
          padding: playerWithSidePanel
              ? const EdgeInsets.only(bottom: 3 * kLargestSpace)
              : EdgeInsets.zero,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: kPlayerExplorerWidth,
              maxHeight: playerWithSidePanel
                  ? mediaQuerySize.height - 0.3 * mediaQuerySize.height
                  : mediaQuerySize.height,
            ),
            child: PlayerExplorer(
              selectedColor: context.colorScheme.onSurface,
              includeImage: !playerWithSidePanel,
            ),
          ),
        ),
      ],
    );
  }
}
