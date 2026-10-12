import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';

import '../../common/view/icons.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/theme_data_x.dart';
import '../manager/playlist_mode_manager.dart';

class PlaylistModeButton extends ConsumerWidget {
  const PlaylistModeButton({super.key, required this.active, this.iconColor});

  final bool active;
  final Color? iconColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistMode = ref.watch(playlistModeManagerProvider);

    final isSelected = playlistMode != PlaylistMode.none;
    final color = isSelected ? context.theme.contrastyPrimary : iconColor;
    return IconButton(
      isSelected: isSelected,
      color: color,
      tooltip: switch (playlistMode) {
        PlaylistMode.none => context.l10n.repeatOff,
        PlaylistMode.single => context.l10n.repeat,
        PlaylistMode.loop => context.l10n.repeatAll,
      },
      icon: switch (playlistMode) {
        PlaylistMode.none => Icon(Iconz.repeatAll, color: color),
        PlaylistMode.single => Icon(Iconz.repeatSingle, color: color),
        PlaylistMode.loop => Icon(Iconz.repeatAll, color: color),
      },
      onPressed: !active
          ? null
          : () => ref.read(playlistModeManagerProvider.notifier).cycle(),
    );
  }
}
