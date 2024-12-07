import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/data/audio_type.dart';
import '../../common/data/podcast_genre.dart';
import '../../common/view/country_auto_complete.dart';
import '../../common/view/language_autocomplete.dart';
import '../../common/view/modals.dart';
import '../../common/view/search_input.dart';
import '../../common/view/theme.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../radio/view/tag_auto_complete.dart';
import '../search_model.dart';
import '../search_type.dart';
import 'audio_type_filter_button.dart';
import 'podcast_search_input_prefix.dart';

class SearchPageInput extends StatelessWidget with WatchItMixin {
  const SearchPageInput({super.key});

  @override
  Widget build(BuildContext context) {
    final searchModel = di<SearchModel>();
    final searchQuery = watchPropertyValue((SearchModel m) => m.searchQuery);
    final searchType = watchPropertyValue((SearchModel m) => m.searchType);
    final audioType = watchPropertyValue((SearchModel m) => m.audioType);
    return SizedBox(
      width: searchBarWidth,
      height: inputHeight,
      child: switch (searchType) {
        SearchType.radioCountry => const CountryAutoCompleteWithSuffix(),
        SearchType.radioTag => const TagAutoCompleteWithSuffix(),
        SearchType.radioLanguage => const LanguageAutoCompleteWithSuffix(),
        _ => SearchInput(
            text: searchQuery,
            hintText: context.l10n.search,
            onChanged: (v) async {
              searchModel.setSearchQuery(v);
              if (v.isEmpty) {
                searchModel.setPodcastGenre(PodcastGenre.all);
              }
              await searchModel.search();
            },
            suffixIcon:
                AudioTypeFilterButton(mode: OverlayMode.platformModalMode),
            prefixIcon: audioType == AudioType.podcast
                ? const PodcastSearchInputPrefix()
                : null,
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
      suffixIcon: AudioTypeFilterButton(mode: OverlayMode.platformModalMode),
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
      suffixIcon: AudioTypeFilterButton(mode: OverlayMode.platformModalMode),
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
      suffixIcon: AudioTypeFilterButton(mode: OverlayMode.platformModalMode),
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
