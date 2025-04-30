import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/icons.dart';
import '../../l10n/l10n.dart';
import '../player_model.dart';

class RepeatButton extends StatelessWidget with WatchItMixin {
  const RepeatButton({
    super.key,
    required this.active,
    this.iconColor,
  });

  final bool active;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final setRepeatSingle = di<PlayerModel>().setRepeatSingle;
    final repeatSingle = watchPropertyValue((PlayerModel m) => m.repeatSingle);

    return IconButton(
      isSelected: repeatSingle,
      color: iconColor,
      tooltip: context.l10n.repeat,
      icon: Icon(Iconz.repeatSingle),
      onPressed: !active ? null : () => setRepeatSingle(!repeatSingle),
    );
  }
}
