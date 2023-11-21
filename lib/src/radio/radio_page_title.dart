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
    required this.discoverFirst,
  });

  final String? searchQuery;
  final Future<void> Function({String? name, String? tag}) search;
  final void Function(Tag? value) setTag;
  final void Function(String? value) setSearchQuery;
  final void Function(bool) setSearchActive;
  final bool searchActive;
  final bool discoverFirst;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return searchActive
            ? SearchingBar(
                key: ValueKey(searchQuery),
                text: searchQuery,
                onClear: () {
                  setTag(null);
                  setSearchActive(false);
                  setSearchQuery(null);
                  search();
                },
                onSubmitted: (value) {
                  DefaultTabController.of(context).index = 1;
                  setSearchQuery(value);
                  search(name: value);
                },
              )
            : SizedBox(
                width: kSearchBarWidth,
                child: TabsBar(
                  tabs: discoverFirst
                      ? [
                          Tab(text: context.l10n.discover),
                          Tab(text: context.l10n.library),
                        ]
                      : [
                          Tab(text: context.l10n.library),
                          Tab(text: context.l10n.discover),
                        ],
                ),
              );
      },
    );
  }
}
