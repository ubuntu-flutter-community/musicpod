import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/full_window_mode_manager.dart';
import '../../common/view/icons.dart';
import '../../extensions/build_context_x.dart';
import '../manager/play_pause_manager.dart';

class StopButton extends ConsumerWidget {
  const StopButton({super.key, required this.active});

  final bool active;

  @override
  Widget build(BuildContext context, WidgetRef ref) => IconButton(
    tooltip: context.l10n.stop,
    onPressed: active
        ? () {
            ref
                .read(fullWindowModeManagerProvider.notifier)
                .setFullWindowMode(false);
            ref.read(playPauseManagerProvider.notifier).stop();
          }
        : null,
    icon: Icon(Iconz.stopFilled),
  );
}
