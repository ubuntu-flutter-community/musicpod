import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/icons.dart';
import '../../extensions/build_context_x.dart';
import '../player_manager.dart';

class PlaybackRateButton extends StatelessWidget with WatchItMixin {
  const PlaybackRateButton({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final rate = watchPropertyValue((PlayerManager m) => m.rate);

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
      itemBuilder: (context) => PlayerManager.rateValues
          .map(
            (e) => PopupMenuItem(
              onTap: () => di<PlayerManager>().setRate(e),
              child: Text('x$e'),
            ),
          )
          .toList(),
    );
  }
}
