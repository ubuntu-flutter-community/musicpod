import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_page.dart';
import 'package:musicpod/app/common/super_like_button.dart';
import 'package:musicpod/app/playlists/playlist_dialog.dart';
import 'package:musicpod/data/audio.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class LikeButton extends StatelessWidget {
  const LikeButton({
    super.key,
    required this.audio,
    required this.audioSelected,
    required this.audioPageType,
    required this.pageId,
    required this.isLiked,
    required this.removeLikedAudio,
    required this.addLikedAudio,
    required this.removeAudioFromPlaylist,
    required this.getTopFivePlaylistNames,
    required this.addAudioToPlaylist,
    required this.addPlaylist,
  });

  final AudioPageType audioPageType;
  final String pageId;
  final Audio audio;
  final bool audioSelected;
  final bool Function(Audio) isLiked;
  final void Function(Audio, [bool]) removeLikedAudio;
  final void Function(Audio, [bool]) addLikedAudio;
  final void Function(String, Audio) removeAudioFromPlaylist;
  final List<String> Function() getTopFivePlaylistNames;
  final void Function(String, Audio) addAudioToPlaylist;
  final void Function(String, Set<Audio>) addPlaylist;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Widget likeButton;
    if (audioPageType != AudioPageType.podcast &&
        audioPageType != AudioPageType.radio) {
      final liked = isLiked(audio);

      likeButton = SuperLikeButton(
        playlistId: pageId,
        onRemoveFromPlaylist: audioPageType == AudioPageType.album ||
                audioPageType == AudioPageType.immutable
            ? null
            : (v) => removeAudioFromPlaylist(v, audio),
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
        onAddToPlaylist: (playlistId) => addAudioToPlaylist(playlistId, audio),
        topFivePlaylistIds: getTopFivePlaylistNames(),
        icon: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => liked ? removeLikedAudio(audio) : addLikedAudio(audio),
          child: YaruAnimatedIcon(
            liked
                ? const YaruAnimatedHeartIcon(filled: true)
                : const YaruAnimatedHeartIcon(filled: false),
            initialProgress: 1.0,
            color:
                audioSelected ? theme.colorScheme.onSurface : theme.hintColor,
            size: kYaruIconSize,
          ),
        ),
      );
    } else {
      final liked = isLiked(audio);

      likeButton = Padding(
        padding: const EdgeInsets.only(right: 30, left: 10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => liked ? removeLikedAudio(audio) : addLikedAudio(audio),
          child: YaruAnimatedIcon(
            liked
                ? const YaruAnimatedHeartIcon(filled: true)
                : const YaruAnimatedHeartIcon(filled: false),
            initialProgress: 1.0,
            color:
                audioSelected ? theme.colorScheme.onSurface : theme.hintColor,
            size: kYaruIconSize,
          ),
        ),
      );
    }

    return likeButton;
  }
}
