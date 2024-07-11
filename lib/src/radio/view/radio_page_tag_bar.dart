import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../app/app_model.dart';
import '../../common/tapable_text.dart';
import '../../data/audio.dart';
import '../../globals.dart';
import '../../library/library_model.dart';
import '../radio_model.dart';
import 'radio_search.dart';
import 'radio_search_page.dart';

class RadioPageTagBar extends StatelessWidget {
  const RadioPageTagBar({super.key, required this.station});

  final Audio station;

  @override
  Widget build(BuildContext context) {
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
      padding: const EdgeInsets.only(top: 5, left: 2),
      child: Wrap(
        spacing: 5,
        runSpacing: 5,
        children: tags
            .mapIndexed(
              (i, e) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TapAbleText(
                    wrapInFlexible: false,
                    onTap: () {
                      radioModel
                          .init(
                            countryCode: appModel.countryCode,
                            index: libraryModel.radioindex,
                          )
                          .then(
                            (_) => navigatorKey.currentState?.push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return RadioSearchPage(
                                    radioSearch: RadioSearch.tag,
                                    searchQuery: e,
                                  );
                                },
                              ),
                            ),
                          );
                    },
                    text: e,
                  ),
                  if (i != tags.length - 1) const Text(','),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
