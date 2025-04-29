import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app/view/routing_manager.dart';
import '../../common/view/no_search_result_page.dart';
import '../../common/view/round_image_container.dart';
import '../../common/view/sliver_fill_remaining_progress.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import 'artist_page.dart';
import 'artist_round_image_container.dart';

class ArtistsView extends StatelessWidget {
  const ArtistsView({
    super.key,
    this.artists,
    this.noResultMessage,
    this.noResultIcon,
  });

  final List<String>? artists;
  final Widget? noResultMessage, noResultIcon;

  @override
  Widget build(BuildContext context) {
    if (artists == null) {
      return const SliverFillRemainingProgress();
    }

    if (artists!.isEmpty) {
      return SliverNoSearchResultPage(
        icon: noResultIcon,
        message: noResultMessage,
      );
    }

    return SliverGrid.builder(
      itemCount: artists!.length,
      gridDelegate: kDiskGridDelegate,
      itemBuilder: (context, index) {
        final artistName = artists!.elementAt(index);

        final text = artists!.elementAt(index);

        return YaruSelectableContainer(
          selected: false,
          onTap: () => di<RoutingManager>().push(
            builder: (_) => ArtistPage(pageId: artistName),
            pageId: artistName,
          ),
          borderRadius: BorderRadius.circular(300),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: ArtistRoundImageContainer(
                  key: ValueKey(artistName),
                  artist: artistName,
                ),
              ),
              ArtistVignette(text: text),
            ],
          ),
        );
      },
    );
  }
}

class AlbumArtistsView extends StatelessWidget {
  const AlbumArtistsView({
    super.key,
    this.albumArtists,
    this.noResultMessage,
    this.noResultIcon,
  });

  final List<String>? albumArtists;
  final Widget? noResultMessage, noResultIcon;

  @override
  Widget build(BuildContext context) {
    if (albumArtists == null) {
      return const SliverFillRemainingProgress();
    }

    if (albumArtists!.isEmpty) {
      return SliverNoSearchResultPage(
        icon: noResultIcon,
        message: noResultMessage,
      );
    }

    return SliverGrid.builder(
      itemCount: albumArtists!.length,
      gridDelegate: kDiskGridDelegate,
      itemBuilder: (context, index) {
        final artist = albumArtists!.elementAt(index);

        return YaruSelectableContainer(
          selected: false,
          onTap: () => di<RoutingManager>().push(
            builder: (_) => ArtistPage(pageId: artist),
            pageId: artist,
          ),
          borderRadius: BorderRadius.circular(300),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: ArtistRoundImageContainer(
                  artist: artist,
                  height: audioCardDimension,
                  width: audioCardDimension,
                ),
              ),
              ArtistVignette(text: artist),
            ],
          ),
        );
      },
    );
  }
}
