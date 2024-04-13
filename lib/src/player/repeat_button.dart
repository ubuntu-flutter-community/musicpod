import 'package:flutter/material.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../get.dart';
import '../../l10n.dart';
import 'player_model.dart';

class RepeatButton extends StatelessWidget with WatchItMixin {
  const RepeatButton({
    super.key,
    required this.active,
  });

  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final setRepeatSingle = getIt<PlayerModel>().setRepeatSingle;
    final repeatSingle = watchPropertyValue((PlayerModel m) => m.repeatSingle);

    return IconButton(
      tooltip: context.l10n.repeat,
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
