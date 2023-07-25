import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_page.dart';
import 'package:musicpod/app/common/safe_network_image.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class PlaylistPage extends StatelessWidget {
  const PlaylistPage({
    super.key,
    required this.playlist,
    required this.unPinPlaylist,
    this.onArtistTap,
    this.onAlbumTap,
  });

  final MapEntry<String, Set<Audio>> playlist;
  final void Function(String playlist) unPinPlaylist;
  final void Function(String artist)? onArtistTap;
  final void Function(String album)? onAlbumTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final noPicture = playlist.value.firstOrNull == null ||
        playlist.value.firstOrNull!.pictureData == null;

    final noImage = playlist.value.firstOrNull == null ||
        playlist.value.firstOrNull!.imageUrl == null;

    return AudioPage(
      onArtistTap: onArtistTap,
      onAlbumTap: onAlbumTap,
      audioPageType: AudioPageType.playlist,
      image: !noPicture
          ? Image.memory(
              playlist.value.firstOrNull!.pictureData!,
              width: 200.0,
              fit: BoxFit.fitWidth,
              filterQuality: FilterQuality.medium,
            )
          : !noImage
              ? SafeNetworkImage(
                  fallBackIcon: SizedBox(
                    width: 200,
                    child: Center(
                      child: Icon(
                        YaruIcons.music_note,
                        size: 80,
                        color: theme.hintColor,
                      ),
                    ),
                  ),
                  url: playlist.value.firstOrNull!.imageUrl,
                  fit: BoxFit.fitWidth,
                  filterQuality: FilterQuality.medium,
                )
              : null,
      pageLabel: context.l10n.playlist,
      pageTitle: playlist.key,
      pageDescription: '',
      pageSubtile: '',
      audios: playlist.value,
      pageId: playlist.key,
      showTrack: playlist.value.firstOrNull?.trackNumber != null,
      editableName: true,
      deletable: true,
      controlPageButton: YaruIconButton(
        icon: Icon(
          YaruIcons.star_filled,
          color: theme.primaryColor,
        ),
        onPressed: () => unPinPlaylist(playlist.key),
      ),
    );
  }
}
