import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:provider/provider.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../app.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../globals.dart';
import '../../radio.dart';
import '../library/library_model.dart';
import 'country_auto_complete.dart';
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

    context.select((LibraryModel m) => m.favTagsLength);
    context.select((LibraryModel m) => m.favCountriesLength);

    final radioSearch =
        context.select((LibraryModel m) => RadioSearch.values[m.radioindex]);

    final country = context.select((RadioModel m) => m.country);
    final tag = context.select((RadioModel m) => m.tag);

    final Widget input = switch (radioSearch) {
      RadioSearch.country => CountryAutoComplete(
          countries: [
            ...[
              ...Country.values,
            ].where(
              (e) => libraryModel.favCountryCodes.contains(e.code) == true,
            ),
            ...[...Country.values].where(
              (e) => libraryModel.favCountryCodes.contains(e.code) == false,
            ),
          ]..remove(Country.none),
          onSelected: model.setCountry,
          value: country,
          addFav: (v) {
            if (country?.code == null) return;
            libraryModel.addFavCountry(v!.code);
          },
          removeFav: (v) {
            if (country?.code == null) return;
            libraryModel.removeFavCountry(v!.code);
          },
          favs: libraryModel.favCountryCodes,
        ),
      RadioSearch.tag => TagAutoComplete(
          value: tag,
          addFav: (tag) {
            if (tag?.name == null) return;
            libraryModel.addFavTag(tag!.name);
          },
          removeFav: (tag) {
            if (tag?.name == null) return;
            libraryModel.removeFavTag(tag!.name);
          },
          favs: libraryModel.favTags,
          onSelected: model.setTag,
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
        ),
      _ => SearchingBar(
          key: ValueKey(searchQuery),
          text: searchQuery,
          onClear: () {
            model.setSearchQuery(null);
          },
          onSubmitted: model.setSearchQuery,
        ),
    };

    return Scaffold(
      appBar: HeaderBar(
        style: showWindowControls
            ? YaruTitleBarStyle.normal
            : YaruTitleBarStyle.undecorated,
        leading: const NavBackButton(),
        title: SizedBox(
          width: kSearchBarWidth,
          child: input,
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
                      searchQuery.toString() +
                          tag.toString() +
                          country.toString() +
                          radioSearch.toString(),
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
