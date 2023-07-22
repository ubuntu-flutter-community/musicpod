import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_card.dart';
import 'package:musicpod/app/common/audio_filter.dart';
import 'package:musicpod/app/common/constants.dart';
import 'package:musicpod/app/local_audio/album_page.dart';
import 'package:musicpod/data/audio.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/constants.dart';

class AlbumsView extends StatelessWidget {
  const AlbumsView({
    super.key,
    required this.albums,
    required this.showWindowControls,
    this.onArtistTap,
    this.onAlbumTap,
    required this.startPlaylist,
    required this.isPinnedAlbum,
    required this.removePinnedAlbum,
    required this.addPinnedAlbum,
    required this.findAlbum,
  });

  final Set<Audio> albums;
  final bool showWindowControls;
  final void Function(String artist)? onArtistTap;
  final void Function(String album)? onAlbumTap;

  final Future<void> Function(Set<Audio>, String) startPlaylist;
  final bool Function(String) isPinnedAlbum;
  final void Function(String) removePinnedAlbum;
  final void Function(String, Set<Audio>) addPinnedAlbum;
  final Set<Audio>? Function(Audio, [AudioFilter]) findAlbum;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(kYaruPagePadding),
      itemCount: albums.length,
      gridDelegate: kImageGridDelegate,
      itemBuilder: (context, index) {
        final audio = albums.elementAt(index);
        final name = audio.album;
        final album = findAlbum(audio);

        final image = audio.pictureData == null
            ? Center(
                child: Icon(
                  YaruIcons.music_note,
                  size: 140,
                  color: theme.hintColor,
                ),
              )
            : Image.memory(
                audio.pictureData!,
                fit: BoxFit.fitWidth,
                filterQuality: FilterQuality.medium,
              );

        return AudioCard(
          bottom: Align(
            alignment: Alignment.bottomCenter,
            child:
                AudioCardBottom(text: audio.album == null ? '' : audio.album!),
          ),
          image: image,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return AlbumPage(
                  onAlbumTap: onAlbumTap,
                  onArtistTap: onArtistTap,
                  name: name,
                  isPinnedAlbum: isPinnedAlbum,
                  removePinnedAlbum: removePinnedAlbum,
                  album: album,
                  addPinnedAlbum: addPinnedAlbum,
                  showWindowControls: showWindowControls,
                );
              },
            ),
          ),
          onPlay: album == null || album.isEmpty || name == null
              ? null
              : () => startPlaylist(album, name),
        );
      },
    );
  }
}

class AudioCardBottom extends StatelessWidget {
  const AudioCardBottom({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.bottomCenter,
      child: Tooltip(
        message: text,
        child: Container(
          width: double.infinity,
          height: 30,
          margin: const EdgeInsets.all(1),
          padding: const EdgeInsets.symmetric(
            vertical: 5,
            horizontal: 10,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.inverseSurface,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(kYaruContainerRadius),
              bottomRight: Radius.circular(kYaruContainerRadius),
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
              color: theme.colorScheme.onInverseSurface,
            ),
          ),
        ),
      ),
    );
  }
}
