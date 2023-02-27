import 'package:flutter/material.dart';
import 'package:music/app/common/audio_tile.dart';
import 'package:music/app/local_audio/local_audio_model.dart';
import 'package:music/app/player_model.dart';
import 'package:music/app/playlists/playlist_dialog.dart';
import 'package:music/app/playlists/playlist_model.dart';
import 'package:music/data/audio.dart';
import 'package:music/l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class AudioList extends StatefulWidget {
  const AudioList({super.key, required this.audios});

  final List<Audio> audios;

  @override
  State<AudioList> createState() => _AudioListState();
}

class _AudioListState extends State<AudioList> {
  late ScrollController _controller;
  int _amount = 40;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _controller.addListener(() {
      if (_controller.position.maxScrollExtent == _controller.offset) {
        setState(() {
          _amount++;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localAudioModel = context.watch<LocalAudioModel>();
    final playerModel = context.watch<PlayerModel>();
    final playlistModel = context.watch<PlaylistModel>();
    final theme = Theme.of(context);
    return ListView.builder(
      controller: _controller,
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
      ),
      itemCount: widget.audios.take(_amount).length,
      itemBuilder: (context, index) {
        final audioSelected =
            playerModel.audio == localAudioModel.audios![index];

        return AudioTile(
          key: ValueKey(localAudioModel.audios![index]),
          selected: audioSelected,
          audio: localAudioModel.audios![index],
          likeIcon: YaruPopupMenuButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                side: BorderSide.none,
                borderRadius: BorderRadius.circular(kYaruButtonRadius),
              ),
            ),
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: Text(context.l10n.createNewPlaylist),
                  onTap: () => showDialog(
                    context: context,
                    builder: (context) {
                      return ChangeNotifierProvider.value(
                        value: playlistModel,
                        child: PlaylistDialog(
                          audios: [localAudioModel.audios![index]],
                        ),
                      );
                    },
                  ),
                ),
                for (final playlist
                    in playlistModel.playlists.entries.take(5).toList())
                  PopupMenuItem(
                    child: Text(
                      '${context.l10n.addTo} ${playlist.key == 'likedAudio' ? context.l10n.likedSongs : playlist.key}',
                    ),
                  )
              ];
            },
            onSelected: (value) {},
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {},
              child: Icon(
                YaruIcons.heart,
                color: audioSelected
                    ? theme.colorScheme.onSurface
                    : theme.hintColor,
              ),
            ),
          ),
        );
      },
    );
  }
}
