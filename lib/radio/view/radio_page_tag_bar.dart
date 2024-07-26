import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../app/app_model.dart';
import '../../common/data/audio.dart';
import '../../common/view/tapable_text.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/theme_data_x.dart';
import '../../library/library_model.dart';
import '../radio_model.dart';
import 'radio_search.dart';
import 'radio_search_page.dart';

class RadioPageTagBar extends StatelessWidget {
  const RadioPageTagBar({super.key, required this.station});

  final Audio station;

  @override
  Widget build(BuildContext context) {
    final style = context.t.pageHeaderDescription;
    final tags = station.album?.isNotEmpty == false
        ? null
        : <String>[
            for (final tag in station.album?.split(',') ?? <String>[]) tag,
          ];
    if (tags == null || tags.isEmpty) return const SizedBox.shrink();

    final radioModel = di<RadioModel>();
    final libraryModel = di<LibraryModel>();
    final appModel = di<AppModel>();

    return SingleChildScrollView(
      child: Wrap(
        alignment: WrapAlignment.center,
        runAlignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: tags
            .mapIndexed(
              (i, e) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TapAbleText(
                    style: style,
                    wrapInFlexible: false,
                    onTap: () {
                      radioModel
                          .init(
                            countryCode: appModel.countryCode,
                            index: appModel.radioindex,
                          )
                          .then(
                            (_) => libraryModel.push(
                              builder: (_) => RadioSearchPage(
                                radioSearch: RadioSearch.tag,
                                searchQuery: e,
                              ),
                              pageId: e,
                            ),
                          );
                    },
                    text: e.length > 20 ? e.substring(0, 19) : e,
                  ),
                  if (i != tags.length - 1) const Text(' · '),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
