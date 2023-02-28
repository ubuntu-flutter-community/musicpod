import 'package:flutter/material.dart';
import 'package:music/app/playlists/playlist_model.dart';
import 'package:music/data/audio.dart';
import 'package:music/l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class PlaylistDialog extends StatefulWidget {
  const PlaylistDialog({
    super.key,
    required this.audios,
    this.name,
  });

  final List<Audio> audios;
  final String? name;

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
            decoration: const InputDecoration(label: Text('Playlist name')),
          )
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        if (model.playlists.containsKey(widget.name))
          OutlinedButton.icon(
            label: Text(context.l10n.deletePlaylist),
            icon: const Icon(YaruIcons.trash),
            onPressed: () {
              model.removePlaylist(widget.name!);
              Navigator.pop(context);
            },
          ),
        if (model.playlists.containsKey(widget.name))
          ElevatedButton(
            onPressed: () {
              model.updatePlaylistName(widget.name!, _nameController.text);
              Navigator.pop(context);
            },
            child: Text(context.l10n.save),
          )
        else
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
  Widget build(BuildContext context) {
    final model = context.watch<PlaylistModel>();

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
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.l10n.cancel),
              ),
              if (model.playlists.containsKey(widget.name))
                OutlinedButton.icon(
                  label: Text(context.l10n.deletePlaylist),
                  icon: const Icon(YaruIcons.trash),
                  onPressed: () {
                    model.removePlaylist(widget.name!);
                    Navigator.pop(context);
                  },
                ),
              if (model.playlists.containsKey(widget.name))
                ElevatedButton(
                  onPressed: () {
                    model.updatePlaylistName(
                      widget.name!,
                      _nameController.text,
                    );
                    Navigator.pop(context);
                  },
                  child: Text(context.l10n.save),
                )
              else
                ElevatedButton(
                  onPressed: () {
                    model.addPlaylist(_nameController.text, []);
                    Navigator.pop(context);
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
