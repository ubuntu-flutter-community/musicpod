import 'package:flutter/material.dart';
import 'package:music/app/playlists/playlist_model.dart';
import 'package:music/data/audio.dart';
import 'package:music/l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class PlaylistDialog extends StatefulWidget {
  const PlaylistDialog({super.key, required this.audios});

  final List<Audio> audios;

  @override
  State<PlaylistDialog> createState() => _PlaylistDialogState();
}

class _PlaylistDialogState extends State<PlaylistDialog> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PlaylistModel>();
    return AlertDialog(
      title: YaruDialogTitleBar(
        title: Text(context.l10n.playlistDialogTitleNew),
      ),
      titlePadding: EdgeInsets.zero,
      scrollable: true,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
          )
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            model.addPlaylist(_nameController.text, widget.audios);
            Navigator.pop(context);
          },
          child: Text(context.l10n.add),
        )
      ],
    );
  }
}
