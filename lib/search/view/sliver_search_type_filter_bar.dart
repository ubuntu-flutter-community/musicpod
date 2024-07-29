import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../radio/radio_model.dart';
import '../../radio/view/radio_reconnect_button.dart';
import '../search_model.dart';

class SliverSearchTypeFilterBar extends StatelessWidget with WatchItMixin {
  const SliverSearchTypeFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final searchModel = di<SearchModel>();
    final searchType = watchPropertyValue((SearchModel m) => m.searchType);
    final searchTypes = watchPropertyValue((SearchModel m) => m.searchTypes);
    final connectedHost = watchPropertyValue((RadioModel m) => m.connectedHost);

    return SliverAppBar(
      shape: const RoundedRectangleBorder(side: BorderSide.none),
      elevation: 0,
      backgroundColor: context.t.scaffoldBackgroundColor,
      automaticallyImplyLeading: false,
      pinned: true,
      centerTitle: true,
      titleSpacing: 0,
      title: SingleChildScrollView(
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
                chipHeight: chipHeight,
                clearOnSelect: false,
                selectedFirst: false,
                onSelected: (i) {
                  searchModel.setSearchType(searchTypes.elementAt(i));
                  searchModel.search();
                },
                labels: searchTypes
                    .map((e) => Text(e.localize(context.l10n)))
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
      ),
      stretch: true,
      onStretchTrigger: () async {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
          if (context.mounted) {
            return searchModel.search();
          }
        });
      },
    );
  }
}
