import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/data/audio.dart';
import '../../common/view/adaptive_container.dart';
import '../../common/view/common_widgets.dart';
import '../../common/view/no_search_result_page.dart';
import '../../common/view/round_image_container.dart';
import '../../constants.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import 'genre_page.dart';

class GenresView extends StatelessWidget {
  const GenresView({
    super.key,
    this.genres,
    this.noResultMessage,
    this.noResultIcon,
  });

  final Set<Audio>? genres;
  final Widget? noResultMessage, noResultIcon;

  @override
  Widget build(BuildContext context) {
    if (genres == null) {
      return const Center(
        child: Progress(),
      );
    }

    if (genres!.isEmpty) {
      return NoSearchResultPage(
        icon: noResultIcon,
        message: noResultMessage,
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.only(top: 15),
          child: GridView.builder(
            itemCount: genres!.length,
            padding: getAdaptiveHorizontalPadding(constraints),
            gridDelegate: kDiskGridDelegate,
            itemBuilder: (context, index) {
              final text =
                  genres!.elementAt(index).genre ?? context.l10n.unknown;

              return YaruSelectableContainer(
                selected: false,
                onTap: () => di<LibraryModel>().push(
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
                        images: const {},
                        fallBackText: text,
                      ),
                    ),
                    ArtistVignette(text: text),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
