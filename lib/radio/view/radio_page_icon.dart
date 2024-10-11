import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/icons.dart';
import '../../extensions/build_context_x.dart';

import '../../constants.dart';
import '../../common/data/audio.dart';
import '../../player/player_model.dart';

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
        Iconz.playFilled,
        color: theme.colorScheme.primary,
      );
    }

    return Padding(
      padding: kMainPageIconPadding,
      child: selected ? Icon(Iconz.radioFilled) : Icon(Iconz.radio),
    );
  }
}
