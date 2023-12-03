import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final theme = Theme.of(context);
    final setRepeatSingle = context.read<PlayerModel>().setRepeatSingle;
    final repeatSingle = context.select((PlayerModel m) => m.repeatSingle);

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
