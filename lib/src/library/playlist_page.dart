import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import '../../common.dart';
import '../../data.dart';
import '../../library.dart';
import '../../local_audio.dart';
import '../../utils.dart';
import '../common/fall_back_header_image.dart';
import '../l10n/l10n.dart';
import '../theme.dart';

class PlaylistPage extends StatelessWidget {
  const PlaylistPage({
    super.key,
    required this.playlist,
    required this.libraryModel,
  });

  final MapEntry<String, Set<Audio>> playlist;
  final LibraryModel libraryModel;

  @override
  Widget build(BuildContext context) {
    final localAudioService = getService<LocalAudioService>();
    final libraryModel = context.read<LibraryModel>();
    return AudioPage(
      onAlbumTap: ({required audioType, required text}) {
        final albumAudios = localAudioService.findAlbum(Audio(album: text));
        if (albumAudios?.firstOrNull == null) return;
        final id = generateAlbumId(albumAudios!.first);
        if (id == null) return;

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) {
              return AlbumPage(
                isPinnedAlbum: libraryModel.isPinnedAlbum,
                removePinnedAlbum: libraryModel.removePinnedAlbum,
                addPinnedAlbum: libraryModel.addPinnedAlbum,
                id: id,
                album: albumAudios,
              );
            },
          ),
        );
      },
      onArtistTap: ({required audioType, required text}) {
        final artistAudios = localAudioService.findArtist(Audio(artist: text));
        final images = localAudioService.findImages(artistAudios ?? {});

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) {
              return ArtistPage(
                images: images,
                artistAudios: artistAudios,
              );
            },
          ),
        );
      },
      showAudioTileHeader:
          playlist.value.any((e) => e.audioType != AudioType.podcast),
      audioPageType: AudioPageType.playlist,
      image: FallBackHeaderImage(
        color: getAlphabetColor(playlist.key),
        child: Icon(
          Iconz().playlist,
          size: 65,
        ),
      ),
      headerLabel: context.l10n.playlist,
      headerTitle: playlist.key,
      audios: playlist.value,
      pageId: playlist.key,
      noResultMessage: Text(context.l10n.emptyPlaylist),
      controlPanelButton: IconButton(
        icon: Icon(Iconz().pen),
        onPressed: () => showDialog(
          context: context,
          builder: (context) => PlaylistDialog(
            playlistName: playlist.key,
            initialValue: playlist.key,
            allowDelete: true,
            allowRename: true,
            libraryModel: libraryModel,
          ),
        ),
      ),
    );
  }
}
