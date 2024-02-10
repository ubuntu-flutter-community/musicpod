import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import 'player_service.dart';

class RepeatButton extends StatelessWidget {
  const RepeatButton({
    super.key,
    required this.active,
  });

  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final service = getService<PlayerService>();
    final setRepeatSingle = service.setRepeatSingle;
    final repeatSingle = service.repeatSingle.watch(context);

    return IconButton(
      icon: Icon(
        Iconz().repeatSingle,
        color: !active
            ? theme.disabledColor
            : (repeatSingle
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface),
      ),
      onPressed: !active ? null : () => setRepeatSingle(!(repeatSingle)),
    );
  }
}
