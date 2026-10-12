import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/view/icons.dart';
import '../../extensions/build_context_x.dart';
import '../manager/rate_manager.dart';

class PlaybackRateButton extends ConsumerWidget {
  const PlaybackRateButton({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final rate = ref.watch(rateManagerProvider);

    return PopupMenuButton(
      tooltip: 'x$rate',
      icon: Icon(
        switch (rate) {
          2.0 => Iconz.levelHigh,
          1.5 => Iconz.levelMiddle,
          _ => Iconz.levelLow,
        },
        color:
            color ??
            (rate != 1.0
                ? theme.colorScheme.primary
                : (theme.colorScheme.onSurface)),
      ),
      initialValue: rate,
      itemBuilder: (context) => RateManager.rateValues
          .map(
            (e) => PopupMenuItem(
              onTap: () => ref.read(rateManagerProvider.notifier).setRate(e),
              child: Text('x$e'),
            ),
          )
          .toList(),
    );
  }
}
