import '../../common.dart';
import '../../constants.dart';
import '../l10n/l10n.dart';
import 'package:flutter/material.dart';

class PodcastsPageTitle extends StatelessWidget {
  const PodcastsPageTitle({
    super.key,
    required this.searchActive,
    required this.searchQuery,
    required this.setSearchActive,
    required this.setSearchQuery,
    required this.search,
    required this.onIndexSelected,
  });

  final bool searchActive;
  final String? searchQuery;
  final void Function(bool value) setSearchActive;
  final void Function(String? value) setSearchQuery;
  final void Function({String? searchQuery}) search;
  final void Function(int? index) onIndexSelected;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return searchActive
            ? SizedBox(
                width: kSearchBarWidth,
                child: SearchingBar(
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
              )
            : SizedBox(
                width: kSearchBarWidth,
                child: TabsBar(
                  onTap: (i) {
                    if (i == 0) {
                      setSearchActive(false);
                      setSearchQuery(null);
                    }
                    onIndexSelected(i);
                  },
                  tabs: [
                    Tab(
                      text: context.l10n.collection,
                    ),
                    Tab(text: context.l10n.discover),
                  ],
                ),
              );
      },
    );
  }
}
