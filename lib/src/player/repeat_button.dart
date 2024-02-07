import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import 'player_model.dart';

class RepeatButton extends StatelessWidget {
  const RepeatButton({
    super.key,
    required this.active,
  });

  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;

    return Consumer(
      builder: (context, ref, _) {
        final setRepeatSingle = ref.read(playerModelProvider).setRepeatSingle;
        final repeatSingle =
            ref.watch(playerModelProvider.select((p) => p.repeatSingle));
        return IconButton(
          icon: Icon(
            Iconz().repeatSingle,
            color: !active
                ? theme.disabledColor
                : (repeatSingle
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface),
          ),
          onPressed: !active ? null : () => setRepeatSingle(!(repeatSingle)),
        );
      },
    );
  }
}
