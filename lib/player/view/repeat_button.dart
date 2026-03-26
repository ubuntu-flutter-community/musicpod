import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:media_kit/media_kit.dart';

import '../../common/view/icons.dart';
import '../../l10n/l10n.dart';
import '../player_model.dart';

class PlaylistModeButton extends StatelessWidget with WatchItMixin {
  const PlaylistModeButton({super.key, required this.active, this.iconColor});

  final bool active;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final playlistMode = watchPropertyValue((PlayerModel m) => m.playlistMode);

    return IconButton(
      isSelected: playlistMode != PlaylistMode.none,
      color: iconColor,
      tooltip: switch (playlistMode) {
        PlaylistMode.none => context.l10n.repeatOff,
        PlaylistMode.single => context.l10n.repeat,
        PlaylistMode.loop => context.l10n.repeatAll,
      },
      icon: switch (playlistMode) {
        PlaylistMode.none => Icon(Iconz.repeatSingle, color: iconColor),
        PlaylistMode.single => Icon(Iconz.repeatSingle, color: iconColor),
        PlaylistMode.loop => Icon(Iconz.repeatAll, color: iconColor),
      },
      onPressed: !active ? null : () => di<PlayerModel>().setPlaylistMode(),
    );
  }
}
