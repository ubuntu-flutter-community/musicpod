import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import 'player_model.dart';

class RepeatButton extends ConsumerWidget {
  const RepeatButton({
    super.key,
    required this.active,
  });

  final bool active;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.t;
    final setRepeatSingle = ref.read(playerModelProvider).setRepeatSingle;
    final repeatSingle =
        ref.watch(playerModelProvider.select((m) => m.repeatSingle));

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
  }
}
