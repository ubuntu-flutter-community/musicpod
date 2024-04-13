import 'package:flutter/material.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../get.dart';
import '../../player.dart';

class RadioPageIcon extends StatelessWidget with WatchItMixin {
  const RadioPageIcon({
    super.key,
    required this.selected,
  });

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final audioType = watchPropertyValue((PlayerModel m) => m.audio?.audioType);

    final theme = context.t;
    if (audioType == AudioType.radio) {
      return Icon(
        Iconz().play,
        color: theme.colorScheme.primary,
      );
    }

    return Padding(
      padding: kMainPageIconPadding,
      child: selected ? Icon(Iconz().radioFilled) : Icon(Iconz().radio),
    );
  }
}
