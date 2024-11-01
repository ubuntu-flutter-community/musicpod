import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../local_audio/local_audio_service.dart';
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
    final localSearchResult =
        watchPropertyValue((SearchModel m) => m.localSearchResult);
    final searchQuery = watchPropertyValue((SearchModel m) => m.searchQuery);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: YaruChoiceChipBar(
        yaruChoiceChipBarStyle: YaruChoiceChipBarStyle.stack,
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
        isSelected: searchTypes.map((e) => e == searchType).toList(),
      ),
    );
  }

  String getChipText({
    required SearchType searchType,
    required BuildContext context,
    required LocalSearchResult? localSearchResult,
    required String? searchQuery,
  }) =>
      '${searchType.localize(context.l10n)}${searchQuery == null || searchQuery.isEmpty ? '' : switch (searchType) {
          SearchType.localTitle =>
            ' (${localSearchResult?.titles?.length ?? '0'})',
          SearchType.localAlbum =>
            ' (${localSearchResult?.albums?.length ?? '0'})',
          SearchType.localArtist =>
            ' (${localSearchResult?.artists?.length ?? '0'})',
          SearchType.localGenreName =>
            ' (${localSearchResult?.genres?.length ?? '0'})',
          SearchType.localPlaylists =>
            ' (${localSearchResult?.playlists?.length ?? '0'})',
          _ => ''
        }}';
}
