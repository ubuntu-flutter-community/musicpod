import 'package:flutter/material.dart';
import 'package:musicpod/app/library_model.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class PlaylistDialog extends StatefulWidget {
  const PlaylistDialog({
    super.key,
    this.onCreateNewPlaylist,
    this.onDeletePlaylist,
    this.onUpdatePlaylistName,
    this.playlistName,
    this.audios,
  });

  final Set<Audio>? audios;
  final void Function(String name, Set<Audio> audios)? onCreateNewPlaylist;
  final void Function(String name)? onUpdatePlaylistName;
  final void Function()? onDeletePlaylist;
  final String? playlistName;

  @override
  State<PlaylistDialog> createState() => _PlaylistDialogState();
}

class _PlaylistDialogState extends State<PlaylistDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.playlistName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: YaruDialogTitleBar(
        title: widget.playlistName != null ? Text(widget.playlistName!) : null,
        border: BorderSide.none,
        backgroundColor: Colors.transparent,
      ),
      titlePadding: EdgeInsets.zero,
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
          ElevatedButton(
            onPressed: () {
              widget.onUpdatePlaylistName!(_controller.text);
              Navigator.of(context).pop();
            },
            child: Text(
              context.l10n.save,
            ),
          ),
        if (widget.onCreateNewPlaylist != null)
          ElevatedButton(
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

class CreatePlaylistPage extends StatefulWidget {
  const CreatePlaylistPage({super.key, this.name});
  final String? name;

  @override
  State<CreatePlaylistPage> createState() => _CreatePlaylistPageState();
}

class _CreatePlaylistPageState extends State<CreatePlaylistPage> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPlaylistSaved = context.read<LibraryModel>().isPlaylistSaved;
    final removePlaylist = context.read<LibraryModel>().removePlaylist;
    final updatePlaylistName = context.read<LibraryModel>().updatePlaylistName;
    final addPlaylist = context.read<LibraryModel>().addPlaylist;
    return YaruDetailPage(
      appBar: YaruWindowTitleBar(
        backgroundColor: Colors.transparent,
        border: BorderSide.none,
        title: Text(context.l10n.createNewPlaylist),
      ),
      body: ListView(
        padding: const EdgeInsets.all(kYaruPagePadding),
        children: [
          Row(
            children: [
              SizedBox(
                width: 300,
                child: TextField(
                  autofocus: true,
                  controller: _nameController,
                  decoration:
                      const InputDecoration(label: Text('Playlist name')),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: kYaruPagePadding,
          ),
          Wrap(
            spacing: 10,
            children: [
              if (isPlaylistSaved(widget.name))
                OutlinedButton.icon(
                  label: Text(context.l10n.deletePlaylist),
                  icon: const Icon(YaruIcons.trash),
                  onPressed: () {
                    removePlaylist(widget.name!);
                  },
                ),
              if (isPlaylistSaved(widget.name))
                ElevatedButton(
                  onPressed: () {
                    updatePlaylistName(
                      widget.name!,
                      _nameController.text,
                    );
                  },
                  child: Text(context.l10n.save),
                )
              else
                ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.isEmpty) return;
                    addPlaylist(_nameController.text, {});
                  },
                  child: Text(context.l10n.add),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
