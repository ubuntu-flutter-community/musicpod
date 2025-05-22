import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/icons.dart';
import '../../l10n/l10n.dart';
import '../player_model.dart';

class ShuffleButton extends StatelessWidget with WatchItMixin {
  const ShuffleButton({super.key, required this.active, this.iconColor});

  final bool active;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final shuffle = watchPropertyValue((PlayerModel m) => m.shuffle);

    return IconButton(
      isSelected: shuffle,
      tooltip: context.l10n.shuffle,
      color: iconColor,
      icon: Icon(Iconz.shuffle),
      onPressed: !active ? null : () => di<PlayerModel>().setShuffle(!shuffle),
    );
  }
}
