import 'package:flutter/material.dart';
import 'package:radio_browser_api/radio_browser_api.dart';

import '../../common.dart';
import '../../constants.dart';
import '../../l10n.dart';

class RadioPageTitle extends StatelessWidget {
  const RadioPageTitle({
    super.key,
    required this.search,
    required this.setTag,
    required this.setSearchQuery,
    required this.setSearchActive,
    required this.searchActive,
    this.searchQuery,
    required this.onIndexSelected,
  });

  final String? searchQuery;
  final Future<void> Function({String? name, String? tag}) search;
  final void Function(Tag? value) setTag;
  final void Function(String? value) setSearchQuery;
  final void Function(bool) setSearchActive;
  final bool searchActive;
  final void Function(int index) onIndexSelected;

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
                    setSearchQuery(null);
                    setTag(null);
                    search(tag: null, name: null);
                  },
                  onSubmitted: (value) {
                    DefaultTabController.of(context).index = 1;

                    setSearchQuery(value);
                    search(name: value);
                  },
                ),
              )
            : SizedBox(
                width: kSearchBarWidth,
                child: TabsBar(
                  onTap: (value) {
                    onIndexSelected.call(value);
                    setSearchActive(false);
                    setSearchQuery(null);
                  },
                  tabs: [
                    Tab(text: context.l10n.collection),
                    Tab(text: context.l10n.discover),
                  ],
                ),
              );
      },
    );
  }
}
