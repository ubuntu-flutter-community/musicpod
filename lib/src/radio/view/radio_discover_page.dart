import 'package:flutter/material.dart';

import 'package:podcast_search/podcast_search.dart';
import 'package:yaru/yaru.dart';

import '../../../common.dart';
import '../../../constants.dart';
import '../../../get.dart';
import '../../../globals.dart';
import '../../../l10n.dart';
import '../../../radio.dart';
import '../../library/library_model.dart';
import 'radio_control_panel.dart';

class RadioDiscoverPage extends StatelessWidget with WatchItMixin {
  const RadioDiscoverPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final model = getIt<RadioModel>();
    final libraryModel = getIt<LibraryModel>();
    final searchQuery = watchPropertyValue((RadioModel m) => m.searchQuery);

    watchPropertyValue((LibraryModel m) => m.favTagsLength);
    watchPropertyValue((LibraryModel m) => m.favCountriesLength);

    final radioSearch = watchPropertyValue(
      (LibraryModel m) => RadioSearch.values[m.radioindex],
    );

    final country = watchPropertyValue((RadioModel m) => m.country);
    final tag = watchPropertyValue((RadioModel m) => m.tag);

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
          onSelected: (c) {
            model.setCountry(c);
            libraryModel.setLastCountryCode(c?.code);
          },
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
          onSelected: (v) {
            model.setTag(v);
            libraryModel.setLastRadioTag(v?.name);
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
        ),
      _ => SearchingBar(
          hintText: '${context.l10n.search}: ${context.l10n.radio}',
          text: searchQuery,
          onClear: () => model.setSearchQuery(query: null),
          onSubmitted: (v) => model.setSearchQuery(query: v),
        ),
    };

    return YaruDetailPage(
      appBar: HeaderBar(
        adaptive: true,
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
      body: AdaptiveContainer(
        child: Column(
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
              child: RadioSearchPage(
                key: ValueKey(
                  searchQuery.toString() +
                      tag.toString() +
                      country.toString() +
                      radioSearch.toString(),
                ),
                includeHeader: false,
                radioSearch: radioSearch,
                searchQuery: searchQuery,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
