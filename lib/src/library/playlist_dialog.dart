import 'package:flutter/material.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../common.dart';
import '../../data.dart';
import '../../theme.dart';
import '../l10n/l10n.dart';

class PlaylistDialog extends StatefulWidget {
  const PlaylistDialog({
    super.key,
    this.onCreateNewPlaylist,
    this.onDeletePlaylist,
    this.onUpdatePlaylistName,
    this.playlistName,
    this.initialValue,
    this.audios,
  });

  final Set<Audio>? audios;
  final void Function(String name, Set<Audio> audios)? onCreateNewPlaylist;
  final void Function(String name)? onUpdatePlaylistName;
  final void Function()? onDeletePlaylist;
  final String? playlistName;
  final String? initialValue;

  @override
  State<PlaylistDialog> createState() => _PlaylistDialogState();
}

class _PlaylistDialogState extends State<PlaylistDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: yaruStyled
          ? YaruDialogTitleBar(
              title: widget.playlistName != null
                  ? Text(widget.playlistName!)
                  : null,
              border: BorderSide.none,
              backgroundColor: Colors.transparent,
            )
          : null,
      titlePadding: yaruStyled ? EdgeInsets.zero : null,
      content: TextField(
        decoration: InputDecoration(label: Text(context.l10n.playlist)),
        controller: _controller,
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            context.l10n.cancel,
          ),
        ),
        if (widget.onDeletePlaylist != null)
          OutlinedButton(
            onPressed: () {
              widget.onDeletePlaylist!();
              Navigator.pop(context);
            },
            child: Text(
              context.l10n.deletePlaylist,
            ),
          ),
        if (widget.onUpdatePlaylistName != null)
          ImportantButton(
            onPressed: () {
              widget.onUpdatePlaylistName!(_controller.text);
              Navigator.of(context).pop();
            },
            child: Text(
              context.l10n.save,
            ),
          ),
        if (widget.onCreateNewPlaylist != null)
          ImportantButton(
            onPressed: () {
              widget.onCreateNewPlaylist!(
                _controller.text,
                widget.audios ?? {},
              );
              Navigator.of(context).pop();
            },
            child: Text(
              context.l10n.add,
            ),
          ),
      ],
    );
  }
}
