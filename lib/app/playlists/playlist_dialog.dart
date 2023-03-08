import 'package:flutter/material.dart';
import 'package:musicpod/app/playlists/playlist_model.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class PlaylistDialog extends StatefulWidget {
  const PlaylistDialog({
    super.key,
    required this.audios,
    required this.name,
    required this.editableName,
    required this.deletable,
  });

  final Set<Audio> audios;
  final String name;
  final bool editableName;
  final bool deletable;

  @override
  State<PlaylistDialog> createState() => _PlaylistDialogState();
}

class _PlaylistDialogState extends State<PlaylistDialog> {
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
    final isPlaylistSaved = context.read<PlaylistModel>().isPlaylistSaved;
    final removePlaylist = context.read<PlaylistModel>().removePlaylist;
    final updatePlaylistName = context.read<PlaylistModel>().updatePlaylistName;
    final addPlaylist = context.read<PlaylistModel>().addPlaylist;

    return AlertDialog(
      title: YaruDialogTitleBar(
        title: isPlaylistSaved(widget.name)
            ? Text(context.l10n.playlistDialogTitleEdit)
            : Text(context.l10n.playlistDialogTitleNew),
      ),
      titlePadding: EdgeInsets.zero,
      scrollable: true,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            autofocus: true,
            controller: _nameController,
            decoration: const InputDecoration(label: Text('Playlist name')),
          )
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        if (widget.deletable)
          OutlinedButton.icon(
            label: Text(context.l10n.deletePlaylist),
            icon: const Icon(YaruIcons.trash),
            onPressed: () {
              removePlaylist(widget.name);
              Navigator.pop(context);
            },
          ),
        if (isPlaylistSaved(widget.name))
          ElevatedButton(
            onPressed: () {
              updatePlaylistName(widget.name, _nameController.text);
              Navigator.pop(context);
            },
            child: Text(context.l10n.save),
          )
        else
          ElevatedButton(
            onPressed: () {
              addPlaylist(_nameController.text, widget.audios);
              Navigator.pop(context);
            },
            child: Text(context.l10n.add),
          )
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
    final isPlaylistSaved = context.read<PlaylistModel>().isPlaylistSaved;
    final removePlaylist = context.read<PlaylistModel>().removePlaylist;
    final updatePlaylistName = context.read<PlaylistModel>().updatePlaylistName;
    final addPlaylist = context.read<PlaylistModel>().addPlaylist;
    return YaruDetailPage(
      appBar: YaruWindowTitleBar(
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
                )
            ],
          )
        ],
      ),
    );
  }
}
