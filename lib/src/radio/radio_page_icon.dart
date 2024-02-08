import '../../build_context_x.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RadioPageIcon extends StatelessWidget {
  const RadioPageIcon({
    super.key,
    required this.selected,
  });

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final audioType = context.select((PlayerModel m) => m.audio?.audioType);

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
