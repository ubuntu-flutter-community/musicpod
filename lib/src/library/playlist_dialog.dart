import 'package:flutter/material.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../common.dart';
import '../../data.dart';
import '../../library.dart';
import '../../theme.dart';
import '../l10n/l10n.dart';

class PlaylistDialog extends StatefulWidget {
  const PlaylistDialog({
    super.key,
    this.playlistName,
    this.initialValue,
    this.audios,
    this.allowDelete = false,
    this.allowRename = false,
    this.allowCreate = false,
    required this.libraryModel,
  });

  final LibraryModel libraryModel;
  final Set<Audio>? audios;
  final String? playlistName;
  final String? initialValue;
  final bool allowRename, allowDelete, allowCreate;

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
      actionsOverflowButtonSpacing: 10,
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            context.l10n.cancel,
          ),
        ),
        if (widget.allowDelete && widget.playlistName != null)
          OutlinedButton(
            onPressed: () {
              widget.libraryModel.removePlaylist(widget.playlistName!);
              Navigator.of(context).pop();
            },
            child: Text(
              context.l10n.deletePlaylist,
            ),
          ),
        if (widget.allowRename && widget.playlistName != null)
          ImportantButton(
            onPressed: () {
              widget.libraryModel
                  .updatePlaylistName(widget.playlistName!, _controller.text);
              Navigator.of(context).pop();
            },
            child: Text(
              context.l10n.save,
            ),
          ),
        if (widget.allowCreate)
          ImportantButton(
            onPressed: () {
              widget.libraryModel.addPlaylist(
                _controller.text,
                widget.audios ?? {},
              );
              _snack(context, _controller.text);
            },
            child: Text(
              context.l10n.add,
            ),
          ),
      ],
    );
  }

  void _snack(BuildContext context, String id) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AddToPlaylistSnackBar(
          libraryModel: widget.libraryModel,
          id: id,
        ),
      ),
    );
  }
}
