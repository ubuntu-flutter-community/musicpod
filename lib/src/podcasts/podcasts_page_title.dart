import 'package:flutter/material.dart';

import '../../common.dart';
import '../../constants.dart';
import '../../l10n.dart';

class PodcastsPageTitle extends StatelessWidget {
  const PodcastsPageTitle({
    super.key,
    required this.searchQuery,
    required this.setSearchQuery,
    required this.search,
  });

  final String? searchQuery;
  final void Function(String? value) setSearchQuery;
  final void Function({String? searchQuery}) search;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return SizedBox(
          width: kSearchBarWidth,
          child: SearchingBar(
            hintText: '${context.l10n.search}: ${context.l10n.podcasts}',
            key: ValueKey(searchQuery),
            text: searchQuery,
            onClear: () {
              setSearchQuery('');
              search();
            },
            onSubmitted: (value) {
              setSearchQuery(value);

              if (value?.isEmpty == true) {
                search();
              } else {
                search(searchQuery: value);
              }
            },
          ),
        );
      },
    );
  }
}
