import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/icons.dart';
import '../../extensions/build_context_x.dart';

import '../player_manager.dart';

class ShuffleButton extends StatelessWidget with WatchItMixin {
  const ShuffleButton({super.key, required this.active, this.iconColor});

  final bool active;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final shuffle = watchPropertyValue((PlayerManager m) => m.shuffle);

    return IconButton(
      isSelected: shuffle,
      tooltip: context.l10n.shuffle,
      color: iconColor,
      icon: Icon(Iconz.shuffle),
      onPressed: !active
          ? null
          : () => di<PlayerManager>().setShuffle(!shuffle),
    );
  }
}
