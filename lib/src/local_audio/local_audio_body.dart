import 'package:flutter/material.dart';

import '../../data.dart';
import 'album_view.dart';
import 'artists_view.dart';
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
    this.noResultIcon,
  });

  final LocalAudioView localAudioView;
  final Set<Audio>? titles;
  final Set<Audio>? artists;
  final Set<Audio>? albums;
  final Widget? noResultMessage, noResultIcon;

  @override
  Widget build(BuildContext context) {
    return switch (localAudioView) {
      LocalAudioView.titles => TitlesView(
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
          albums: albums,
          noResultMessage: noResultMessage,
          noResultIcon: noResultIcon,
        ),
    };
  }
}
