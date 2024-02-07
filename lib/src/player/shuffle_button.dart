import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../build_context_x.dart';
import '../common/icons.dart';
import 'player_model.dart';

class ShuffleButton extends StatelessWidget {
  const ShuffleButton({
    super.key,
    required this.active,
  });

  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;

    return Consumer(
      builder: (context, ref, _) {
        final shuffle = ref.watch(playerModelProvider.select((p) => p.shuffle));
        final setShuffle = ref.read(playerModelProvider).setShuffle;

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
      },
    );
  }
}
