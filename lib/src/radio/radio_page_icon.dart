import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../player.dart';

class RadioPageIcon extends ConsumerWidget {
  const RadioPageIcon({
    super.key,
    required this.selected,
  });

  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioType =
        ref.watch(playerModelProvider.select((m) => m.audio?.audioType));

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
