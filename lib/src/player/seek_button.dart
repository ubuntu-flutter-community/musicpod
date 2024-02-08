import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final playerModel = context.read<PlayerModel>();
    final position = context.select((PlayerModel m) => m.position);
    final setPosition = playerModel.setPosition;
    final duration = context.select((PlayerModel m) => m.duration);
    final seek = playerModel.seek;
    final icon = Icon(
      forward ? Iconz().forward30 : Iconz().backward10,
    );
    return IconButton(
      onPressed: () async {
        if (position == null ||
            duration == null ||
            (forward
                ? (position.inSeconds + 30 > duration.inSeconds)
                : (position.inSeconds - 10 < 0))) return;
        setPosition(
          Duration(
            seconds:
                forward ? position.inSeconds + 30 : position.inSeconds - 10,
          ),
        );
        await seek();
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
