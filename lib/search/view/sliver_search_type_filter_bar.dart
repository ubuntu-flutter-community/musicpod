import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/common_control_panel.dart';
import '../../extensions/build_context_x.dart';
import '../../local_audio/local_search_result.dart';
import '../search_manager.dart';
import '../search_type.dart';

class SearchTypeFilterBar extends StatelessWidget with WatchItMixin {
  const SearchTypeFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final searchManager = di<SearchManager>();
    final searchType = watchValue((SearchManager m) => m.searchType);
    final searchTypes = watchValue((SearchManager m) => m.searchTypes);
    final localSearchResult = watchValue(
      (SearchManager m) => m.localSearchResult,
    );
    final searchQuery = watchValue((SearchManager m) => m.searchQuery);

    return CommonControlPanel(
      onSelected: (i) {
        searchManager.setSearchType(searchTypes.elementAt(i));
        searchManager.search(manualFilter: true);
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
            ),
          )
          .toList(),
      isSelected: searchTypes.map((e) => e == searchType).toList(),
    );
  }

  String getChipText({
    required SearchType searchType,
    required BuildContext context,
    required LocalSearchResult? localSearchResult,
    required String? searchQuery,
  }) =>
      '${searchType.localize(context.l10n)}${searchQuery == null || searchQuery.isEmpty ? '' : switch (searchType) {
              SearchType.localTitle => ' (${localSearchResult?.titles?.length ?? '0'})',
              SearchType.localAlbum => ' (${localSearchResult?.albums?.length ?? '0'})',
              SearchType.localArtist => ' (${localSearchResult?.artists?.length ?? '0'})',
              // SearchType.localAlbumArtist =>
              //   ' (${localSearchResult?.albumArtists?.length ?? '0'})',
              SearchType.localGenreName => ' (${localSearchResult?.genres?.length ?? '0'})',
              SearchType.localPlaylists => ' (${localSearchResult?.playlists?.length ?? '0'})',
              _ => '',
            }}';
}
