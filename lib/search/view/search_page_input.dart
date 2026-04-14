import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:podcast_search/podcast_search.dart';

import '../../common/data/audio_type.dart';
import '../../common/view/country_auto_complete.dart';
import '../../common/view/language_autocomplete.dart';
import '../../common/view/modals.dart';
import '../../common/view/search_input.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/taget_platform_x.dart';
import '../../l10n/l10n.dart';
import '../../podcasts/data/podcast_genre.dart';
import '../../radio/radio_model.dart';
import '../../radio/view/tag_auto_complete.dart';
import '../../settings/settings_model.dart';
import '../search_model.dart';
import '../search_type.dart';
import 'audio_type_filter_button.dart';
import 'podcast_search_attribute_popup_button.dart';
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
      height: getInputHeight(),
      child: Theme(
        data: context.theme.copyWith(
          listTileTheme: context.theme.listTileTheme.copyWith(
            shape: const RoundedRectangleBorder(),
          ),
        ),
        child: switch (searchType) {
          SearchType.radioCountry => const CountryAutoCompleteWithSuffix(),
          SearchType.radioTag => const TagAutoCompleteWithSuffix(),
          SearchType.radioLanguage => const LanguageAutoCompleteWithSuffix(),
          _ => SearchInput(
            autoFocus: !isMobile,
            text: searchQuery,
            hintText: audioType.localizedSearchHint(context.l10n),
            onChanged: (v) async {
              searchModel.setSearchQuery(v);
              if (v.isEmpty) {
                searchModel.setPodcastGenre(PodcastGenre.all);
              }
              await searchModel.search();
            },
            suffixIcon: AudioTypeFilterButton(
              mode: OverlayMode.platformModalMode,
            ),
            prefixIcon: audioType == AudioType.podcast
                ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const PodcastSearchInputPrefix(),
                      PodcastSearchAttributePopupButton(),
                    ],
                  )
                : null,
          ),
        },
      ),
    );
  }
}

class CountryAutoCompleteWithSuffix extends StatelessWidget with WatchItMixin {
  const CountryAutoCompleteWithSuffix({super.key});

  @override
  Widget build(BuildContext context) {
    final searchModel = di<SearchModel>();
    final country = watchPropertyValue((SearchModel m) => m.country);
    watchPropertyValue((SettingsModel m) => m.favoriteCountryCodeLength);
    final favCountryCodes = watchPropertyValue(
      (SettingsModel m) => m.favoriteCountryCode,
    );

    return CountryAutoComplete(
      suffixIcon: AudioTypeFilterButton(mode: OverlayMode.platformModalMode),
      countries: [
        ...[
          ...Country.values,
        ].where((e) => favCountryCodes.contains(e.code) == true),
        ...[
          ...Country.values,
        ].where((e) => favCountryCodes.contains(e.code) == false),
      ]..remove(Country.none),
      onSelected: (c) async {
        searchModel.setCountry(c);
        if (c?.code != null) {
          di<SettingsModel>().setLastCountryCode(c!.code);
        }
        await searchModel.search();
      },
      value: country,
      addFav: (v) {
        if (country?.code == null) return;
        di<SettingsModel>().addFavoriteCountryCode(v!.code);
      },
      removeFav: (v) {
        if (country?.code == null) return;
        di<SettingsModel>().removeFavoriteCountryCode(v!.code);
      },
      favs: favCountryCodes,
    );
  }
}

class TagAutoCompleteWithSuffix extends StatelessWidget with WatchItMixin {
  const TagAutoCompleteWithSuffix({super.key});

  @override
  Widget build(BuildContext context) {
    final radioManager = di<RadioManager>();
    final model = di<SearchModel>();
    final tag = watchPropertyValue((SearchModel m) => m.tag);
    watchPropertyValue((RadioManager m) => m.favRadioTags);
    return TagAutoComplete(
      suffixIcon: AudioTypeFilterButton(mode: OverlayMode.platformModalMode),
      value: tag,
      addFav: (tag) {
        if (tag?.name == null) return;
        radioManager.addFavRadioTag(tag!.name);
      },
      removeFav: (tag) {
        if (tag?.name == null) return;
        radioManager.removeRadioFavTag(tag!.name);
      },
      favs: radioManager.favRadioTags,
      onSelected: (v) {
        model.setTag(v);
        model.search();
      },
      tags: [
        ...[
          ...?model.tags,
        ].where((e) => radioManager.favRadioTags.contains(e.name) == true),
        ...[
          ...?model.tags,
        ].where((e) => radioManager.favRadioTags.contains(e.name) == false),
      ],
    );
  }
}

class LanguageAutoCompleteWithSuffix extends StatelessWidget with WatchItMixin {
  const LanguageAutoCompleteWithSuffix({super.key});

  @override
  Widget build(BuildContext context) {
    final language = watchPropertyValue((SearchModel m) => m.language);
    watchPropertyValue((SettingsModel m) => m.favoriteLanguageCodeLength);
    final favLanguageCodes = watchPropertyValue(
      (SettingsModel m) => m.favoriteLanguageCode,
    );
    return LanguageAutoComplete(
      suffixIcon: AudioTypeFilterButton(mode: OverlayMode.platformModalMode),
      value: language,
      onSelected: (language) {
        di<SearchModel>()
          ..setLanguage(language)
          ..search();
        if (language?.isoCode != null) {
          di<SettingsModel>().setLastLanguageCode(language!.isoCode);
        }
      },
      favs: favLanguageCodes,
      addFav: (language) {
        if (language?.isoCode == null) return;
        di<SettingsModel>().addFavoriteLanguageCode(language!.isoCode);
      },
      removeFav: (language) {
        if (language?.isoCode == null) return;
        di<SettingsModel>().removeFavoriteLanguageCode(language!.isoCode);
      },
    );
  }
}
