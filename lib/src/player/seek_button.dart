import 'package:flutter/material.dart';

import '../../build_context_x.dart';
import '../../theme.dart';
import '../common/icons.dart';
import 'player_model.dart';

class SeekButton extends StatelessWidget {
  const SeekButton({
    super.key,
    required this.active,
    this.forward = true,
  });
  final bool active;
  final bool forward;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final playerModel = getIt<PlayerModel>();

    final icon = Icon(
      forward ? Iconz().forward30 : Iconz().backward10,
    );
    return IconButton(
      color: active ? theme.colorScheme.onSurface : theme.disabledColor,
      onPressed: () async {
        playerModel.seekInSeconds(forward ? 30 : -10);
      },
      icon: yaruStyled
          ? Stack(
              alignment: Alignment.center,
              children: [
                icon,
                Positioned(
                  bottom: 0,
                  right: 5,
                  child: Text(
                    forward ? '30' : '10',
                    style:
                        context.t.textTheme.labelSmall?.copyWith(fontSize: 7),
                  ),
                ),
              ],
            )
          : icon,
    );
  }
}
