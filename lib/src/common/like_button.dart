import 'package:flutter/material.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../build_context_x.dart';
import '../../data.dart';
import '../../library.dart';
import '../l10n/l10n.dart';
import '../library/add_to_playlist_dialog.dart';
import '../library/playlist_dialog.dart';
import 'icons.dart';
import 'stream_provider_share_button.dart';

class LikeButton extends StatelessWidget {
  const LikeButton({
    super.key,
    required this.audio,
    required this.audioSelected,
    required this.playlistId,
    required this.liked,
    required this.removeLikedAudio,
    required this.addLikedAudio,
    this.onRemoveFromPlaylist,
    required this.playlistIds,
    required this.addAudioToPlaylist,
    required this.addPlaylist,
    this.insertIntoQueue,
    required this.getPlaylistById,
    required this.removePlaylist,
    this.onTextTap,
  });

  final String playlistId;
  final Audio audio;
  final bool audioSelected;
  final bool liked;
  final void Function(Audio, [bool]) removeLikedAudio;
  final void Function(Audio, [bool]) addLikedAudio;
  final void Function(String, Audio)? onRemoveFromPlaylist;
  final List<String>? playlistIds;
  final void Function(String, Audio) addAudioToPlaylist;
  final void Function(String, Set<Audio>) addPlaylist;
  final void Function()? insertIntoQueue;
  final Set<Audio>? Function(String id) getPlaylistById;
  final void Function(String) removePlaylist;
  final void Function({required AudioType audioType, required String text})?
      onTextTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;

    final heartButton = InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => liked ? removeLikedAudio(audio) : addLikedAudio(audio),
      child: Iconz().getAnimatedHeartIcon(
        liked: liked,
        color: audioSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface,
      ),
    );

    return _Button(
      insertIntoQueue: insertIntoQueue,
      audio: audio,
      playlistId: playlistId,
      onRemoveFromPlaylist: onRemoveFromPlaylist == null
          ? null
          : (v) => onRemoveFromPlaylist!(v, audio),
      onCreateNewPlaylist: () {
        showDialog(
          context: context,
          builder: (context) {
            return PlaylistDialog(
              audios: {audio},
              onCreateNewPlaylist: addPlaylist,
            );
          },
        );
      },
      addAudioToPlaylist: addAudioToPlaylist,
      playlistIds: playlistIds ?? [],
      icon: heartButton,
      removePlaylist: removePlaylist,
      getPlaylistById: getPlaylistById,
      onTextTap: onTextTap,
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({
    this.onCreateNewPlaylist,
    this.onRemoveFromPlaylist,
    required this.addAudioToPlaylist,
    this.playlistId,
    required this.playlistIds,
    required this.icon,
    required this.audio,
    this.insertIntoQueue,
    required this.removePlaylist,
    required this.getPlaylistById,
    this.onTextTap,
  });

  final void Function()? insertIntoQueue;
  final void Function()? onCreateNewPlaylist;
  final void Function(String playlistId)? onRemoveFromPlaylist;
  final void Function(String, Audio) addAudioToPlaylist;
  final void Function(String) removePlaylist;
  final String? playlistId;
  final List<String> playlistIds;
  final Widget icon;
  final Audio audio;
  final Set<Audio>? Function(String id) getPlaylistById;
  final void Function({required AudioType audioType, required String text})?
      onTextTap;

  @override
  Widget build(BuildContext context) {
    return YaruPopupMenuButton(
      tooltip: context.l10n.moreOptions,
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.circular(kYaruButtonRadius),
        ),
      ),
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            onTap: insertIntoQueue,
            child: Text(context.l10n.insertIntoQueue),
          ),
          PopupMenuItem(
            onTap: onCreateNewPlaylist,
            child: Text(context.l10n.createNewPlaylist),
          ),
          if (onRemoveFromPlaylist != null)
            PopupMenuItem(
              onTap: onRemoveFromPlaylist == null || playlistId == null
                  ? null
                  : () => onRemoveFromPlaylist!(playlistId!),
              child: Text('Remove from $playlistId'),
            ),
          PopupMenuItem(
            onTap: () => showDialog(
              context: context,
              builder: (context) {
                return AddToPlaylistDialog(
                  audio: audio,
                  playlistIds: playlistIds,
                  addAudioToPlaylist: addAudioToPlaylist,
                  removePlaylist: removePlaylist,
                  getPlaylistById: getPlaylistById,
                  onTextTap: onTextTap,
                );
              },
            ),
            child: Text(
              '${context.l10n.addToPlaylist} ...',
            ),
          ),
          PopupMenuItem(
            padding: EdgeInsets.zero,
            child: StreamProviderRow(
              text: '${audio.artist ?? ''} - ${audio.title ?? ''}',
            ),
          ),
        ];
      },
      child: icon,
    );
  }
}
