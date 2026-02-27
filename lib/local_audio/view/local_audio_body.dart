import 'package:flutter/material.dart';

import '../../common/data/audio.dart';
import '../local_audio_view.dart';
import 'album_view.dart';
import 'artists_view.dart';
import 'genres_view.dart';
import 'playlists_view.dart';
import 'titles_view.dart';

class LocalAudioBody extends StatelessWidget {
  const LocalAudioBody({
    super.key,
    required this.localAudioView,
    required this.titles,
    required this.artists,
    required this.albumIDs,
    required this.genres,
    required this.playlists,
    this.noResultMessage,
    this.noResultIcon,
    required this.constraints,
  });

  final LocalAudioView localAudioView;
  final List<Audio>? titles;
  final List<String>? artists;

  final List<String>? albumIDs;
  final List<String>? genres;
  final List<String>? playlists;
  final Widget? noResultMessage, noResultIcon;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) => switch (localAudioView) {
    LocalAudioView.titles => TitlesView(
      constraints: constraints,
      audios: titles,
      noResultMessage: noResultMessage,
      noResultIcon: noResultIcon,
    ),
    LocalAudioView.artists => ArtistsView(
      artists: artists,
      noResultMessage: noResultMessage,
      noResultIcon: noResultIcon,
    ),
    LocalAudioView.albums => AlbumsView(
      albumIDs: albumIDs,
      noResultMessage: noResultMessage,
      noResultIcon: noResultIcon,
    ),
    LocalAudioView.genres => GenresView(
      genres: genres,
      noResultMessage: noResultMessage,
      noResultIcon: noResultIcon,
    ),
    LocalAudioView.playlists => PlaylistsView(playlists: playlists ?? []),
  };
}
