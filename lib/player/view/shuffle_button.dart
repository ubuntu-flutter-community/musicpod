import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/view/icons.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/theme_data_x.dart';
import '../manager/shuffle_manager.dart';

class ShuffleButton extends ConsumerWidget {
  const ShuffleButton({super.key, required this.active, this.iconColor});

  final bool active;
  final Color? iconColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shuffle = ref.watch(shuffleManagerProvider);

    final color = shuffle ? context.theme.contrastyPrimary : iconColor;

    return IconButton(
      isSelected: shuffle,
      tooltip: context.l10n.shuffle,
      color: color,
      icon: Icon(Iconz.shuffle),
      onPressed: !active
          ? null
          : () => ref.read(shuffleManagerProvider.notifier).toggle(),
    );
  }
}
