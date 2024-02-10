import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import '../../build_context_x.dart';
import '../common/icons.dart';
import 'player_service.dart';

class ShuffleButton extends StatelessWidget {
  const ShuffleButton({
    super.key,
    required this.active,
  });

  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final service = getService<PlayerService>();
    final shuffle = service.shuffle.watch(context);
    final setShuffle = service.setShuffle;

    return IconButton(
      icon: Icon(
        Iconz().shuffle,
        color: !active
            ? theme.disabledColor
            : (shuffle
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface),
      ),
      onPressed: !active ? null : () => setShuffle(!(shuffle)),
    );
  }
}
