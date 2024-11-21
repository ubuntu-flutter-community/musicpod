import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../app_config.dart';
import '../../common/data/audio.dart';
import '../../l10n/l10n.dart';
import 'add_to_playlist_navigator.dart';

class AddToPlaylistDialog extends StatelessWidget {
  const AddToPlaylistDialog({super.key, required this.audios});

  final List<Audio> audios;

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: yaruStyled
            ? YaruDialogTitleBar(
                title: Text(context.l10n.addToPlaylist),
              )
            : Text(context.l10n.addToPlaylist),
        titlePadding: yaruStyled
            ? EdgeInsets.zero
            : const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
        content: SizedBox(
          height: 200,
          width: 400,
          child: AddToPlaylistNavigator(audios: audios),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 20),
      );
}
