import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app/view/routing_manager.dart';
import '../../common/view/no_search_result_page.dart';
import '../../common/view/round_image_container.dart';
import '../../common/view/sliver_fill_remaining_progress.dart';
import '../../common/view/ui_constants.dart';
import 'artist_image.dart';
import 'artist_page.dart';

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
        final radius = BorderRadius.circular(300);

        return YaruSelectableContainer(
          key: ValueKey(artistName),
          selected: false,
          onTap: () => di<RoutingManager>().push(
            builder: (_) => ArtistPage(pageId: artistName),
            pageId: artistName,
          ),
          borderRadius: radius,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: ArtistImage(
                  dimension: double.infinity,
                  artist: artistName,
                ),
              ),
              RoundImageContainerVignette(text: artistName),
            ],
          ),
        );
      },
    );
  }
}
