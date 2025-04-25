import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app/view/routing_manager.dart';
import '../../common/view/no_search_result_page.dart';
import '../../common/view/round_image_container.dart';
import '../../common/view/sliver_fill_remaining_progress.dart';
import '../../common/view/ui_constants.dart';
import 'genre_page.dart';

class GenresView extends StatelessWidget {
  const GenresView({
    super.key,
    this.genres,
    this.noResultMessage,
    this.noResultIcon,
  });

  final List<String>? genres;
  final Widget? noResultMessage, noResultIcon;

  @override
  Widget build(BuildContext context) {
    if (genres == null) {
      return const SliverFillRemainingProgress();
    }

    if (genres!.isEmpty) {
      return SliverNoSearchResultPage(
        icon: noResultIcon,
        message: noResultMessage,
      );
    }
    return SliverGrid.builder(
      itemCount: genres!.length,
      gridDelegate: kDiskGridDelegate,
      itemBuilder: (context, index) {
        final text = genres!.elementAt(index);
        return YaruSelectableContainer(
          selected: false,
          onTap: () => di<RoutingManager>().push(
            builder: (_) => GenrePage(
              genre: text,
            ),
            pageId: text,
          ),
          borderRadius: BorderRadius.circular(300),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: RoundImageContainer(
                  images: [],
                  fallBackText: text,
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
