import 'package:flutter/material.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../theme.dart';
import '../l10n/l10n.dart';

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
      mainAxisAlignment: context.m.size.width < kMasterDetailBreakPoint
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
                onPressed: () {
                  runOrConfirm(
                    context: context,
                    noConfirm: audios.length < kAudioQueueThreshHold,
                    message: context.l10n.queueConfirmMessage(
                      audios.length.toString(),
                    ),
                    run: () => onTap!(),
                    onCancel: () {},
                  );
                },
                icon: Padding(
                  padding: appleStyled
                      ? const EdgeInsets.only(left: 3)
                      : EdgeInsets.zero,
                  child: Icon(
                    icon ?? Iconz().playFilled,
                    color: theme.colorScheme.onInverseSurface,
                  ),
                ),
              ),
            ),
          ),
        if (controlButton != null) controlButton!,
      ],
    );
  }
}
