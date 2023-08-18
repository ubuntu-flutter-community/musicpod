import 'package:flutter/material.dart';
import 'package:musicpod/app/common/confirmation_dialog.dart';
import 'package:musicpod/app/playlists/playlist_dialog.dart';
import 'package:musicpod/constants.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class AudioPageControlPanel extends StatelessWidget {
  const AudioPageControlPanel({
    super.key,
    required this.audios,
    required this.listName,
    this.editableName = false,
    this.pinButton,
    required this.isPlaying,
    this.queueName,
    required this.startPlaylist,
    required this.pause,
    required this.resume,
    this.removePlaylist,
    this.updatePlaylistName,
    this.title,
  });

  final Set<Audio> audios;
  final String listName;
  final Widget? title;
  final bool editableName;

  final Widget? pinButton;
  final bool isPlaying;
  final String? queueName;
  final void Function(Set<Audio> audios, String listName)? startPlaylist;
  final void Function() pause;
  final void Function() resume;
  final void Function(String name)? removePlaylist;
  final void Function(String oldName, String newName)? updatePlaylistName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        if (startPlaylist != null)
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: CircleAvatar(
              radius: kYaruTitleBarItemHeight / 2,
              backgroundColor: theme.colorScheme.inverseSurface,
              child: IconButton(
                onPressed: () {
                  if (queueName != listName) {
                    if (audios.length > kAudioQueueThreshHold) {
                      showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return ConfirmationDialog(
                            message: SizedBox(
                              width: 300,
                              child: Text(
                                context.l10n.queueConfirmMessage(
                                  audios.length.toString(),
                                ),
                                style: theme.textTheme.bodyLarge,
                              ),
                            ),
                          );
                        },
                      ).then((value) {
                        if (value == true) {
                          startPlaylist!(audios, listName);
                        }
                      });
                    } else {
                      startPlaylist!(audios, listName);
                    }
                  } else {
                    if (isPlaying) {
                      pause();
                    } else {
                      resume();
                    }
                  }
                },
                icon: Icon(
                  isPlaying && queueName == listName
                      ? YaruIcons.media_pause
                      : YaruIcons.playlist_play,
                  color: theme.colorScheme.onInverseSurface,
                ),
              ),
            ),
          ),
        if (editableName)
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: const Icon(YaruIcons.pen),
              onPressed: () => showDialog(
                context: context,
                builder: (context) => PlaylistDialog(
                  playlistName: listName,
                  onDeletePlaylist: removePlaylist == null
                      ? null
                      : () => removePlaylist!(listName),
                  onUpdatePlaylistName: updatePlaylistName == null
                      ? null
                      : (name) => updatePlaylistName!(listName, name),
                ),
              ),
            ),
          )
        else if (pinButton != null)
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: pinButton!,
          ),
        Expanded(
          child: title ??
              Text(
                '${listName == 'likedAudio' ? context.l10n.likedSongs : listName}  •  ${audios.length} ${context.l10n.titles}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w100),
              ),
        ),
      ],
    );
  }
}
