import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../common/data/audio.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import 'add_to_playlist_navigator.dart';

class AddToPlaylistDialog extends StatelessWidget {
  const AddToPlaylistDialog({super.key, required this.audios});

  final List<Audio> audios;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: YaruDialogTitleBar(
      title: Text(context.l10n.addToPlaylist),
      border: BorderSide.none,
      backgroundColor: context.theme.dialogTheme.backgroundColor,
    ),
    titlePadding: EdgeInsets.zero,
    content: SizedBox(
      height: 200,
      width: 400,
      child: AddToPlaylistNavigator(audios: audios),
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: kLargestSpace),
  );
}
