import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:radio_browser_api/radio_browser_api.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../app.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../globals.dart';
import '../../radio.dart';
import '../library/library_model.dart';
import 'radio_control_panel.dart';
import 'radio_search.dart';
import 'radio_search_page.dart';

class RadioDiscoverPage extends StatelessWidget {
  const RadioDiscoverPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final showWindowControls =
        context.select((AppModel a) => a.showWindowControls);
    final model = context.read<RadioModel>();
    final libraryModel = context.read<LibraryModel>();
    final searchQuery = context.select((RadioModel m) => m.searchQuery);
    final setSearchQuery = model.setSearchQuery;

    context.select((LibraryModel m) => m.favTagsLength);

    final radioSearch = context.select((RadioModel m) => m.radioSearch);

    return Scaffold(
      appBar: HeaderBar(
        style: showWindowControls
            ? YaruTitleBarStyle.normal
            : YaruTitleBarStyle.undecorated,
        leading: const NavBackButton(),
        title: SizedBox(
          width: kSearchBarWidth,
          child: radioSearch == RadioSearch.tag && model.searchQuery != null
              ? TagPopup(
                  value: Tag(name: model.searchQuery!, stationCount: 1),
                  addFav: (tag) {
                    if (tag?.name == null) return;
                    libraryModel.addFavTag(tag!.name);
                  },
                  removeFav: (tag) {
                    if (tag?.name == null) return;
                    libraryModel.removeFavTag(tag!.name);
                  },
                  favs: libraryModel.favTags,
                  onSelected: (tag) {
                    setSearchQuery(tag?.name);
                  },
                  tags: [
                    ...[
                      ...?model.tags,
                    ].where(
                      (e) => libraryModel.favTags.contains(e.name) == true,
                    ),
                    ...[...?model.tags].where(
                      (e) => libraryModel.favTags.contains(e.name) == false,
                    ),
                  ],
                )
              : SearchingBar(
                  key: ValueKey(searchQuery),
                  text: searchQuery,
                  onClear: () {
                    setSearchQuery(null);
                  },
                  onSubmitted: setSearchQuery,
                ),
        ),
        actions: [
          Padding(
            padding: appBarActionSpacing,
            child: SearchButton(
              active: true,
              onPressed: () => navigatorKey.currentState?.maybePop(),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const Row(
            children: [
              RadioControlPanel(),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Expanded(
            child: searchQuery?.isNotEmpty == true
                ? RadioSearchPage(
                    key: ValueKey(
                      searchQuery.toString() + radioSearch.toString(),
                    ),
                    includeHeader: false,
                    radioSearch: radioSearch,
                    searchQuery: searchQuery,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
