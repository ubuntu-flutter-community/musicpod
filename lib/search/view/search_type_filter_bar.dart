import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../search_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

class SearchTypeFilterBar extends StatelessWidget with WatchItMixin {
  const SearchTypeFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final searchModel = di<SearchModel>();
    final searchType = watchPropertyValue((SearchModel m) => m.searchType);
    final searchTypes = watchPropertyValue((SearchModel m) => m.searchTypes);

    return Material(
      color: context.t.scaffoldBackgroundColor,
      child: YaruChoiceChipBar(
        yaruChoiceChipBarStyle: YaruChoiceChipBarStyle.wrap,
        clearOnSelect: false,
        selectedFirst: false,
        onSelected: (i) {
          searchModel.setSearchType(searchTypes.elementAt(i));
          searchModel.search();
        },
        // TODO: if offline disable podcast and radio labels
        labels: searchTypes.map((e) => Text(e.localize(context.l10n))).toList(),
        isSelected: searchTypes.none((e) => e == searchType)
            ? List.generate(
                searchTypes.length,
                (index) => index == 0 ? true : false,
              )
            : searchTypes.map((e) => e == searchType).toList(),
      ),
    );
  }
}
