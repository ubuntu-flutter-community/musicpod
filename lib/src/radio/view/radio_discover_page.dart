import 'package:flutter/material.dart';

import 'package:podcast_search/podcast_search.dart';
import 'package:yaru/yaru.dart';

import '../../../common.dart';
import '../../../constants.dart';
import '../../../get.dart';
import '../../../globals.dart';
import '../../../l10n.dart';
import '../../../radio.dart';
import '../../common/language_autocomplete.dart';
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

    watchPropertyValue((LibraryModel m) => m.favRadioTagsLength);
    watchPropertyValue((LibraryModel m) => m.favCountriesLength);
    watchPropertyValue((LibraryModel m) => m.favLanguagesLength);

    final radioSearch = watchPropertyValue(
      (LibraryModel m) => RadioSearch.values[m.radioindex],
    );

    final country = watchPropertyValue((RadioModel m) => m.country);
    final tag = watchPropertyValue((RadioModel m) => m.tag);
    final language = watchPropertyValue((RadioModel m) => m.language);
    watchPropertyValue((LibraryModel m) => m.favLanguagesLength);
    final favLanguageCodes =
        watchPropertyValue((LibraryModel m) => m.favLanguageCodes);

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
            libraryModel.addFavCountryCode(v!.code);
          },
          removeFav: (v) {
            if (country?.code == null) return;
            libraryModel.removeFavCountryCode(v!.code);
          },
          favs: libraryModel.favCountryCodes,
        ),
      RadioSearch.tag => TagAutoComplete(
          value: tag,
          addFav: (tag) {
            if (tag?.name == null) return;
            libraryModel.addFavRadioTag(tag!.name);
          },
          removeFav: (tag) {
            if (tag?.name == null) return;
            libraryModel.removeRadioFavTag(tag!.name);
          },
          favs: libraryModel.favRadioTags,
          onSelected: (v) {
            model.setTag(v);
            libraryModel.setLastRadioTag(v?.name);
          },
          tags: [
            ...[
              ...?model.tags,
            ].where(
              (e) => libraryModel.favRadioTags.contains(e.name) == true,
            ),
            ...[...?model.tags].where(
              (e) => libraryModel.favRadioTags.contains(e.name) == false,
            ),
          ],
        ),
      RadioSearch.language => LanguageAutoComplete(
          value: language,
          onSelected: (language) {
            model.setLanguage(language);
            libraryModel.setLastLanguage(language?.isoCode);
          },
          favs: favLanguageCodes,
          addFav: (language) {
            if (language?.isoCode == null) return;
            libraryModel.addFavLanguageCode(language!.isoCode);
          },
          removeFav: (language) {
            if (language?.isoCode == null) return;
            libraryModel.removeFavLanguageCode(language!.isoCode);
          },
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
            const RadioControlPanel(),
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
