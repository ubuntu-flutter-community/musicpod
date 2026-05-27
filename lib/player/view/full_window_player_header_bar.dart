import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/app_manager.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/icons.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/taget_platform_x.dart';
import 'full_window_player_top_controls.dart';

class FullWindowPlayerHeaderBar extends StatelessWidget {
  const FullWindowPlayerHeaderBar({super.key, required this.isVideo});

  final bool isVideo;

  @override
  Widget build(BuildContext context) {
    return HeaderBar(
      heroTag: 'fullWindowPlayerHeaderBar',
      leading: isMobile
          ? Center(
              child: IconButton(
                tooltip: context.l10n.leaveFullWindow,
                icon: Icon(
                  Iconz.fullWindowExit,
                  color: isVideo == true ? Colors.white : null,
                ),
                onPressed: () => di<AppManager>().setFullWindowMode(false),
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
