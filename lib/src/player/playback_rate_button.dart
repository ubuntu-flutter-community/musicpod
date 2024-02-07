import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../build_context_x.dart';
import '../common/icons.dart';
import 'player_model.dart';

class PlaybackRateButton extends StatelessWidget {
  const PlaybackRateButton({
    super.key,
    required this.active,
    this.color,
  });

  final bool active;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;

    return Consumer(
      builder: (context, ref, _) {
        final rate = ref.watch(playerModelProvider.select((p) => p.rate));
        final setRate = ref.read(playerModelProvider).setRate;
        return PopupMenuButton(
          icon: Icon(
            switch (rate) {
              2.0 => Iconz().levelHigh,
              1.5 => Iconz().levelMiddle,
              _ => Iconz().levelLow
            },
            color: !active
                ? theme.disabledColor
                : (rate != 1.0
                    ? theme.colorScheme.primary
                    : (color ?? theme.colorScheme.onSurface)),
          ),
          initialValue: rate,
          itemBuilder: (context) {
            return rateValues
                .map(
                  (e) => PopupMenuItem(
                    onTap: () => setRate(e),
                    child: Text('x$e'),
                  ),
                )
                .toList();
          },
        );
      },
    );
  }
}
