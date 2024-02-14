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

    final icon = Icon(
      forward ? Iconz().forward30 : Iconz().backward10,
    );
    return IconButton(
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
