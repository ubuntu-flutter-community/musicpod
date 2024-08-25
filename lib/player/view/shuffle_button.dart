import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../common/view/icons.dart';
import '../player_model.dart';

class ShuffleButton extends StatelessWidget with WatchItMixin {
  const ShuffleButton({
    super.key,
    required this.active,
  });

  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final shuffle = watchPropertyValue((PlayerModel m) => m.shuffle);

    return IconButton(
      tooltip: context.l10n.shuffle,
      icon: Icon(
        Iconz().shuffle,
        color: !active
            ? theme.disabledColor
            : (shuffle
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface),
      ),
      onPressed: !active ? null : () => di<PlayerModel>().setShuffle(!shuffle),
    );
  }
}
