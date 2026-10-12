import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/view/common_control_panel.dart';
import '../../extensions/build_context_x.dart';
import '../../local_audio/data/local_search_result.dart';
import '../manager/search_manager.dart';
import '../data/search_type.dart';

class SearchTypeFilterBar extends ConsumerWidget {
  const SearchTypeFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchManager = ref.read(searchManagerProvider.notifier);
    final searchType = ref.watch(
      searchManagerProvider.select((s) => s.searchType),
    );
    final searchTypes = ref.watch(
      searchManagerProvider.select((s) => s.searchTypes),
    );
    final localSearchResult = ref.watch(
      searchManagerProvider.select((s) => s.localSearchResult),
    );
    final searchQuery = ref.watch(
      searchManagerProvider.select((s) => s.searchQuery),
    );

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
