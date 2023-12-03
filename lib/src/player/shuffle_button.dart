import 'package:flutter/material.dart';
import '../common/icons.dart';
import 'player_model.dart';
import 'package:provider/provider.dart';

class ShuffleButton extends StatelessWidget {
  const ShuffleButton({
    super.key,
    required this.active,
  });

  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shuffle = context.select((PlayerModel m) => m.shuffle);
    final setShuffle = context.read<PlayerModel>().setShuffle;

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
