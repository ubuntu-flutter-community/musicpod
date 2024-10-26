import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../local_audio/local_audio_service.dart';
import '../../radio/radio_model.dart';
import '../../radio/view/radio_reconnect_button.dart';
import '../search_model.dart';
import '../search_type.dart';

class SearchTypeFilterBar extends StatelessWidget with WatchItMixin {
  const SearchTypeFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final searchModel = di<SearchModel>();
    final searchType = watchPropertyValue((SearchModel m) => m.searchType);
    final searchTypes = watchPropertyValue((SearchModel m) => m.searchTypes);
    final connectedHost = watchPropertyValue((RadioModel m) => m.connectedHost);
    final localSearchResult =
        watchPropertyValue((SearchModel m) => m.localSearchResult);
    final searchQuery = watchPropertyValue((SearchModel m) => m.searchQuery);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (connectedHost == null)
            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: RadioReconnectButton(),
            )
          else
            YaruChoiceChipBar(
              yaruChoiceChipBarStyle: YaruChoiceChipBarStyle.wrap,
              chipBackgroundColor: chipColor(theme),
              selectedChipBackgroundColor: chipSelectionColor(theme, false),
              borderColor: chipBorder(theme, false),
              chipHeight: chipHeight,
              clearOnSelect: false,
              selectedFirst: false,
              onSelected: (i) {
                searchModel.setSearchType(searchTypes.elementAt(i));
                searchModel.search(manualFilter: true);
              },
              labels: searchTypes
                  .map(
                    (e) => Text(
                      getChipText(
                        searchType: e,
                        context: context,
                        localSearchResult: localSearchResult,
                        searchQuery: searchQuery,
                      ),
                      style: chipTextStyle(theme),
                    ),
                  )
                  .toList(),
              isSelected: searchTypes.none((e) => e == searchType)
                  ? List.generate(
                      searchTypes.length,
                      (index) => index == 0 ? true : false,
                    )
                  : searchTypes.map((e) => e == searchType).toList(),
            ),
        ],
      ),
    );
  }

  String getChipText({
    required SearchType searchType,
    required BuildContext context,
    required LocalSearchResult? localSearchResult,
    required String? searchQuery,
  }) =>
      '${searchType.localize(context.l10n)} ${searchQuery == null || searchQuery.isEmpty ? '' : switch (searchType) {
          SearchType.localTitle =>
            '(${localSearchResult?.titles?.length ?? '0'})',
          SearchType.localAlbum =>
            '(${localSearchResult?.albums?.length ?? '0'})',
          SearchType.localArtist =>
            '(${localSearchResult?.artists?.length ?? '0'})',
          SearchType.localGenreName =>
            '(${localSearchResult?.genres?.length ?? '0'})',
          SearchType.localPlaylists =>
            '(${localSearchResult?.playlists?.length ?? '0'})',
          _ => ''
        }}';
}
