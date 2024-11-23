import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:radio_browser_api/radio_browser_api.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/data/audio.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/tapable_text.dart';
import '../../constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/theme_data_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../search/search_model.dart';
import '../../search/search_type.dart';

class RadioPageTagBar extends StatelessWidget {
  const RadioPageTagBar({super.key, required this.station});

  final Audio station;

  @override
  Widget build(BuildContext context) {
    final style = context.theme.pageHeaderDescription;
    final tags = station.tags;
    if (tags == null || tags.isEmpty) return const SizedBox.shrink();

    final childOrFullBar = SingleChildScrollView(
      child: Wrap(
        alignment: WrapAlignment.center,
        runAlignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: tapAbleTags(context: context, tags: tags, style: style),
      ),
    );

    if (tags.length > 20) {
      return YaruExpandable(
        expandIconPadding: const EdgeInsets.only(left: 10),
        header: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Tooltip(
            message: context.l10n.radioTagDisclaimerSubTitle,
            child: Text(
              '${context.l10n.radioTagDisclaimerTitle} ${context.l10n.radioTagDisclaimerSubTitle} ',
              style: style,
              textAlign: TextAlign.justify,
              maxLines: 2,
            ),
          ),
        ),
        child: childOrFullBar,
      );
    }

    return childOrFullBar;
  }

  List<Widget> tapAbleTags({
    required BuildContext context,
    required List<String> tags,
    required TextStyle? style,
    int? limit,
  }) {
    return tags
        .take(limit ?? tags.length)
        .mapIndexed(
          (i, e) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TapAbleText(
                style: style,
                wrapInFlexible: false,
                onTap: () {
                  di<LibraryModel>().push(pageId: kSearchPageId);
                  di<SearchModel>()
                    ..setTag(Tag(name: e, stationCount: 1))
                    ..setAudioType(AudioType.radio)
                    ..setSearchType(SearchType.radioTag)
                    ..search();
                },
                text: e.length > 20 ? e.substring(0, 19) : e,
              ),
              if (i != tags.length - 1) const Text(' · '),
            ],
          ),
        )
        .toList();
  }
}
