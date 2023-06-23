import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_card.dart';
import 'package:musicpod/app/common/constants.dart';
import 'package:musicpod/app/local_audio/album_page.dart';
import 'package:musicpod/app/local_audio/local_audio_model.dart';
import 'package:musicpod/app/player/player_model.dart';
import 'package:musicpod/app/library_model.dart';
import 'package:musicpod/data/audio.dart';
import 'package:provider/provider.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/constants.dart';

class AlbumsView extends StatefulWidget {
  const AlbumsView({
    super.key,
    required this.albums,
    required this.showWindowControls,
    this.onArtistTap,
    this.onAlbumTap,
  });

  final Set<Audio> albums;
  final bool showWindowControls;
  final void Function(String artist)? onArtistTap;
  final void Function(String album)? onAlbumTap;

  @override
  State<AlbumsView> createState() => _AlbumsViewState();
}

class _AlbumsViewState extends State<AlbumsView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final startPlaylist = context.read<PlayerModel>().startPlaylist;
    final isPinnedAlbum = context.read<LibraryModel>().isPinnedAlbum;
    final removePinnedAlbum = context.read<LibraryModel>().removePinnedAlbum;
    final addPinnedAlbum = context.read<LibraryModel>().addPinnedAlbum;

    final findAlbum = context.read<LocalAudioModel>().findAlbum;

    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(kYaruPagePadding),
      itemCount: widget.albums.length,
      gridDelegate: kImageGridDelegate,
      itemBuilder: (context, index) {
        final audio = widget.albums.elementAt(index);
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
            child: Tooltip(
              message: audio.album == null ? '' : audio.album!,
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
                  audio.album == null ? '' : audio.album!,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    color: theme.colorScheme.onInverseSurface,
                  ),
                ),
              ),
            ),
          ),
          image: image,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return AlbumPage(
                  onAlbumTap: widget.onAlbumTap,
                  onArtistTap: widget.onArtistTap,
                  name: name,
                  isPinnedAlbum: isPinnedAlbum,
                  removePinnedAlbum: removePinnedAlbum,
                  album: album,
                  addPinnedAlbum: addPinnedAlbum,
                  showWindowControls: widget.showWindowControls,
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
