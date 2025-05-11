import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';
import 'package:radio_browser_api/radio_browser_api.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app/view/routing_manager.dart';
import '../../common/data/audio_type.dart';
import '../../common/page_ids.dart';
import '../../common/view/no_search_result_page.dart';
import '../../common/view/round_image_container.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../search/search_model.dart';
import '../../search/search_type.dart';
import 'open_radio_discover_page_button.dart';

class FavoriteRadioTagsGrid extends StatelessWidget with WatchItMixin {
  const FavoriteRadioTagsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final favTagsLength =
        watchPropertyValue((LibraryModel m) => m.favRadioTags.length);
    final favTags = watchPropertyValue((LibraryModel m) => m.favRadioTags);

    if (favTagsLength == 0) {
      return SliverNoSearchResultPage(
        message: Column(
          children: [
            Text(context.l10n.noStarredTags),
            const SizedBox(
              height: kLargestSpace,
            ),
            const OpenRadioSearchButton(),
          ],
        ),
        icon: const AnimatedEmoji(AnimatedEmojis.glowingStar),
      );
    }

    return SliverGrid.builder(
      gridDelegate: kDiskGridDelegate,
      itemCount: favTagsLength,
      itemBuilder: (context, index) {
        final text = favTags.elementAt(index);
        final color = getAlphabetColor(text).scale(saturation: -0.2);
        final textColor = contrastColor(color);
        final tag = favTags.elementAt(index);
        return YaruSelectableContainer(
          selected: false,
          onTap: () {
            di<RoutingManager>().push(pageId: PageIDs.searchPage);
            di<SearchModel>()
              ..setSearchType(SearchType.radioTag)
              ..setTag(Tag(name: tag.toLowerCase(), stationCount: 1))
              ..setAudioType(AudioType.radio)
              ..search();
          },
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
                  backgroundColor: color,
                ),
              ),
              RoundImageContainerVignette(
                text: text,
                backgroundColor: Colors.transparent,
                textColor: textColor,
              ),
            ],
          ),
        );
      },
    );
  }
}
