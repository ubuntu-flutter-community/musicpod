import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import '../../build_context_x.dart';
import '../../theme.dart';
import '../common/icons.dart';
import 'player_service.dart';

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
    final service = getService<PlayerService>();
    final position = service.position.watch(context);
    final setPosition = service.setPosition;
    final duration = service.duration.watch(context);
    final seek = service.seek;
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
