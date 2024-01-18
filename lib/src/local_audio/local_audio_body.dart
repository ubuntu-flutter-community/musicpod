import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data.dart';
import '../../library.dart';
import '../../player.dart';
import 'album_view.dart';
import 'artists_view.dart';
import 'local_audio_model.dart';
import 'local_audio_view.dart';
import 'titles_view.dart';

class LocalAudioBody extends StatelessWidget {
  const LocalAudioBody({
    super.key,
    required this.localAudioView,
    required this.titles,
    required this.artists,
    required this.albums,
    this.noResultMessage,
  });

  final LocalAudioView localAudioView;
  final Set<Audio>? titles;
  final Set<Audio>? artists;
  final Set<Audio>? albums;
  final Widget? noResultMessage;

  @override
  Widget build(BuildContext context) {
    final libraryModel = context.read<LibraryModel>();
    final playerModel = context.read<PlayerModel>();
    final model = context.read<LocalAudioModel>();
    return switch (localAudioView) {
      LocalAudioView.titles => TitlesView(
          audios: titles,
          noResultMessage: noResultMessage,
        ),
      LocalAudioView.artists => ArtistsView(
          artists: artists,
          findArtist: model.findArtist,
          findImages: model.findImages,
          noResultMessage: noResultMessage,
        ),
      LocalAudioView.albums => AlbumsView(
          albums: albums,
          addPinnedAlbum: libraryModel.addPinnedAlbum,
          findAlbum: model.findAlbum,
          isPinnedAlbum: libraryModel.isPinnedAlbum,
          removePinnedAlbum: libraryModel.removePinnedAlbum,
          startPlaylist: playerModel.startPlaylist,
          noResultMessage: noResultMessage,
        ),
    };
  }
}
