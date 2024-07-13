import 'package:flutter/material.dart';

import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../data/audio.dart';
import 'common_widgets.dart';
import 'icons.dart';

class AudioPageControlPanel extends StatelessWidget {
  const AudioPageControlPanel({
    super.key,
    required this.audios,
    this.controlButton,
    required this.onTap,
    this.title,
    this.icon,
  });

  final Set<Audio> audios;
  final Widget? title;

  final Widget? controlButton;
  final void Function()? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;

    return Row(
      mainAxisAlignment: context.smallWindow
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: [
        if (onTap != null)
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: CircleAvatar(
              radius: avatarIconSize,
              backgroundColor: theme.colorScheme.inverseSurface,
              child: IconButton(
                tooltip: context.l10n.playAll,
                onPressed: onTap,
                icon: Icon(
                  icon ?? Iconz().playFilled,
                  color: theme.colorScheme.onInverseSurface,
                ),
              ),
            ),
          ),
        if (controlButton != null) controlButton!,
      ],
    );
  }
}
