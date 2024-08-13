import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/country_auto_complete.dart';
import '../../common/view/language_autocomplete.dart';
import '../../common/view/search_input.dart';
import '../../common/view/theme.dart';
import '../../constants.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../radio/view/tag_auto_complete.dart';
import '../search_model.dart';
import '../search_type.dart';
import 'audio_type_filter_button.dart';

class SearchPageInput extends StatelessWidget with WatchItMixin {
  const SearchPageInput({super.key});

  @override
  Widget build(BuildContext context) {
    final searchModel = di<SearchModel>();
    final searchQuery = watchPropertyValue((SearchModel m) => m.searchQuery);
    final searchType = watchPropertyValue((SearchModel m) => m.searchType);
    return SizedBox(
      width: kSearchBarWidth,
      height: inputHeight,
      child: switch (searchType) {
        SearchType.radioCountry => const CountryAutoCompleteWithSuffix(),
        SearchType.radioTag => const TagAutoCompleteWithSuffix(),
        SearchType.radioLanguage => const LanguageAutoCompleteWithSuffix(),
        _ => SearchInput(
            text: searchQuery,
            key: ValueKey(searchType.name),
            hintText: context.l10n.search,
            onChanged: (v) async {
              searchModel.setSearchQuery(v);
              await searchModel.search();
            },
            suffixIcon: const AudioTypeFilterButton(),
          ),
      },
    );
  }
}

class CountryAutoCompleteWithSuffix extends StatelessWidget with WatchItMixin {
  const CountryAutoCompleteWithSuffix({super.key});

  @override
  Widget build(BuildContext context) {
    final libraryModel = di<LibraryModel>();
    final searchModel = di<SearchModel>();
    final country = watchPropertyValue((SearchModel m) => m.country);
    watchPropertyValue((LibraryModel m) => m.favCountriesLength);
    final favCountryCodes =
        watchPropertyValue((LibraryModel m) => m.favCountryCodes);

    return CountryAutoComplete(
      suffixIcon: const AudioTypeFilterButton(),
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
      onSelected: (c) async {
        searchModel.setCountry(c);
        if (c?.code != null) {
          libraryModel.setLastCountryCode(c!.code);
        }
        await searchModel.search();
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
      favs: favCountryCodes,
    );
  }
}

class TagAutoCompleteWithSuffix extends StatelessWidget with WatchItMixin {
  const TagAutoCompleteWithSuffix({super.key});

  @override
  Widget build(BuildContext context) {
    final libraryModel = di<LibraryModel>();
    final model = di<SearchModel>();
    final tag = watchPropertyValue((SearchModel m) => m.tag);
    watchPropertyValue((LibraryModel m) => m.favRadioTags);
    return TagAutoComplete(
      suffixIcon: const AudioTypeFilterButton(),
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
        model.search();
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
    );
  }
}

class LanguageAutoCompleteWithSuffix extends StatelessWidget with WatchItMixin {
  const LanguageAutoCompleteWithSuffix({super.key});

  @override
  Widget build(BuildContext context) {
    final libraryModel = di<LibraryModel>();
    final model = di<SearchModel>();
    final language = watchPropertyValue((SearchModel m) => m.language);
    watchPropertyValue((LibraryModel m) => m.favLanguagesLength);
    final favLanguageCodes =
        watchPropertyValue((LibraryModel m) => m.favLanguageCodes);
    return LanguageAutoComplete(
      suffixIcon: const AudioTypeFilterButton(),
      value: language,
      onSelected: (language) {
        model.setLanguage(language);
        model.search();
        if (language?.isoCode != null) {
          libraryModel.setLastLanguage(language!.isoCode);
        }
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
    );
  }
}
