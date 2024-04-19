import 'package:flutter/material.dart';

import 'package:yaru/yaru.dart';

import '../../../common.dart';
import '../../../constants.dart';
import '../../../data.dart';
import '../../l10n/l10n.dart';
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
        icons: noResultIcon,
        message: noResultMessage,
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: GridView.builder(
        itemCount: genres!.length,
        padding: gridPadding,
        gridDelegate: kDiskGridDelegate,
        itemBuilder: (context, index) {
          final text = genres!.elementAt(index).genre ?? context.l10n.unknown;

          return YaruSelectableContainer(
            selected: false,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return GenrePage(
                    genre: text,
                  );
                },
              ),
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
  }
}
