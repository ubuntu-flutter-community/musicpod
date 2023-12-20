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
    required this.pause,
    required this.resume,
    this.title,
  });

  final Set<Audio> audios;
  final Widget? title;

  final Widget? controlButton;
  final void Function()? onTap;
  final void Function() pause;
  final void Function() resume;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;

    return Row(
      mainAxisAlignment: context.m.size.width < 600
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
                onPressed: () {
                  if (audios.length > kAudioQueueThreshHold) {
                    showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return ConfirmationDialog(
                          message: Text(
                            context.l10n.queueConfirmMessage(
                              audios.length.toString(),
                            ),
                          ),
                        );
                      },
                    ).then((value) {
                      if (value == true) {
                        onTap!();
                      }
                    });
                  } else {
                    onTap!();
                  }
                },
                icon: Padding(
                  padding: appleStyled
                      ? const EdgeInsets.only(left: 3)
                      : EdgeInsets.zero,
                  child: Icon(
                    Iconz().playFilled,
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
