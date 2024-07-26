import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:watch_it/watch_it.dart';

import '../../app/app_model.dart';
import '../../common/view/common_widgets.dart';
import '../../common/view/country_auto_complete.dart';
import '../../common/view/language_autocomplete.dart';
import '../../common/view/offline_page.dart';
import '../../constants.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../player/player_model.dart';
import '../radio_model.dart';
import 'radio_control_panel.dart';
import 'radio_search.dart';
import 'radio_search_page.dart';
import 'tag_auto_complete.dart';

class RadioDiscoverPage extends StatelessWidget with WatchItMixin {
  const RadioDiscoverPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isOnline = watchPropertyValue((PlayerModel m) => m.isOnline);
    if (!isOnline) {
      return const OfflinePage();
    }

    final model = di<RadioModel>();
    final libraryModel = di<LibraryModel>();
    final searchQuery = watchPropertyValue((RadioModel m) => m.searchQuery);

    watchPropertyValue((LibraryModel m) => m.favRadioTagsLength);
    watchPropertyValue((LibraryModel m) => m.favCountriesLength);
    watchPropertyValue((LibraryModel m) => m.favLanguagesLength);

    final radioSearch = watchPropertyValue(
      (AppModel m) => RadioSearch.values[m.radioindex],
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
          onSelected: (v) => model.setTag(v),
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

    return Scaffold(
      appBar: HeaderBar(
        adaptive: true,
        title: SizedBox(
          width: kSearchBarWidth,
          child: input,
        ),
        actions: [
          Padding(
            padding: appBarActionSpacing,
            child: SearchButton(
              active: true,
              onPressed: () {
                di<AppModel>().setLockSpace(false);
                di<LibraryModel>().pop(popStack: false);
              },
            ),
          ),
        ],
      ),
      body: Column(
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
    );
  }
}
