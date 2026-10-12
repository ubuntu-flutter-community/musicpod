import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:yaru/constants.dart';

import '../../common/data/audio_type.dart';
import '../../common/view/country_auto_complete.dart';
import '../../common/view/language_autocomplete.dart';
import '../../common/view/modals.dart';
import '../../common/view/search_input.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/platform_x.dart';
import '../../podcasts/data/podcast_genre.dart';
import '../../radio/manager/radio_fav_tag_manager.dart';
import '../../radio/manager/radio_load_tags_manager.dart';
import '../../radio/view/tag_auto_complete.dart';
import '../../settings/data/shared_preferences_keys.dart';
import '../../settings/manager/settings_manager.dart';
import '../manager/search_manager.dart';
import '../data/search_type.dart';
import 'audio_type_filter_button.dart';
import 'podcast_search_input_prefix.dart';

class SearchPageInput extends StatelessWidget with WatchItMixin {
  const SearchPageInput({super.key});

  @override
  Widget build(BuildContext context) {
    final searchManager = di<SearchManager>();
    final searchQuery = watchValue((SearchManager m) => m.searchQuery);
    final searchType = watchValue((SearchManager m) => m.searchType);
    final audioType = watchValue((SearchManager m) => m.audioType);
    return Consumer(
      builder: (context, ref, _) {
        final yaruTheme =
            ref.watch(settingsBoolManagerProvider(SPKeys.useYaruTheme)) ??
            isLinux;
        return ClipRRect(
          borderRadius: BorderRadius.circular(
            yaruTheme ? kYaruButtonRadius : 100,
          ),
          child: SizedBox(
            width: searchBarWidth,
            height: getInputHeight(),
            child: Theme(
              data: context.theme.copyWith(
                listTileTheme: context.theme.listTileTheme.copyWith(
                  shape: const RoundedRectangleBorder(),
                ),
              ),
              child: switch (searchType) {
                SearchType.radioCountry =>
                  const CountryAutoCompleteWithSuffix(),
                SearchType.radioTag => const TagAutoCompleteWithSuffix(),
                SearchType.radioLanguage =>
                  const LanguageAutoCompleteWithSuffix(),
                _ => SearchInput(
                  autoFocus: !isMobile,
                  text: searchQuery,
                  hintText: audioType.localizedSearchHint(context.l10n),
                  onChanged: (v) {
                    searchManager.setSearchQuery(v);
                    if (v.isEmpty) {
                      searchManager.setPodcastGenre(PodcastGenre.all);
                    }
                    searchManager.search();
                  },
                  suffixIcon: AudioTypeFilterButton(
                    mode: OverlayMode.platformModalMode,
                  ),
                  prefixIcon: audioType == AudioType.podcast
                      ? const PodcastSearchInputPrefix()
                      : null,
                ),
              },
            ),
          ),
        );
      },
    );
  }
}

class CountryAutoCompleteWithSuffix extends StatelessWidget with WatchItMixin {
  const CountryAutoCompleteWithSuffix({super.key});

  @override
  Widget build(BuildContext context) {
    final searchManager = di<SearchManager>();
    final country = watchValue((SearchManager m) => m.country);
    return Consumer(
      builder: (context, ref, _) {
        final favCountryCodes =
            ref.watch(
              settingsStringListManagerProvider(SPKeys.favCountryCodes),
            ) ??
            <String>[];

        return CountryAutoComplete(
          suffixIcon: AudioTypeFilterButton(
            mode: OverlayMode.platformModalMode,
          ),
          countries: [
            ...[
              ...Country.values,
            ].where((e) => favCountryCodes.contains(e.code) == true),
            ...[
              ...Country.values,
            ].where((e) => favCountryCodes.contains(e.code) == false),
          ]..remove(Country.none),
          onSelected: (c) {
            searchManager.setCountry(c);
            if (c?.code != null) {
              ref
                  .read(
                    settingsStringManagerProvider(
                      SPKeys.lastCountryCode,
                    ).notifier,
                  )
                  .set(c!.code);
            }
            searchManager.search();
          },
          value: country,
          addFav: (v) {
            if (v?.code == null) return;
            ref
                .read(
                  settingsStringListManagerProvider(
                    SPKeys.favCountryCodes,
                  ).notifier,
                )
                .addToStringList(v!.code);
          },
          removeFav: (v) {
            if (v?.code == null) return;
            ref
                .read(
                  settingsStringListManagerProvider(
                    SPKeys.favCountryCodes,
                  ).notifier,
                )
                .removeFromStringList(v!.code);
          },
          favs: favCountryCodes.toSet(),
        );
      },
    );
  }
}

class TagAutoCompleteWithSuffix extends StatelessWidget with WatchItMixin {
  const TagAutoCompleteWithSuffix({super.key});

  @override
  Widget build(BuildContext context) {
    final searchManager = di<SearchManager>();
    final tag = watchValue((SearchManager m) => m.tag);
    return Consumer(
      builder: (context, ref, _) {
        final favRadioTags =
            ref.watch(radioFavTagManagerProvider).value ?? {};
        final tags = ref.watch(radioLoadTagsManagerProvider).value ?? [];
        return TagAutoComplete(
          suffixIcon: AudioTypeFilterButton(mode: OverlayMode.platformModalMode),
          value: tag,
          toggleFav: (tag) {
            if (tag?.name == null) return;
            ref
                .read(radioFavTagManagerProvider.notifier)
                .toggleFavRadioTag(tag!.name);
          },
          favs: favRadioTags,
          onSelected: (v) {
            searchManager.setTag(v);
            searchManager.search();
          },
          tags: [
            ...tags.where((e) => favRadioTags.contains(e.name)),
            ...tags.where((e) => !favRadioTags.contains(e.name)),
          ],
        );
      },
    );
  }
}

class LanguageAutoCompleteWithSuffix extends StatelessWidget with WatchItMixin {
  const LanguageAutoCompleteWithSuffix({super.key});

  @override
  Widget build(BuildContext context) {
    final language = watchValue((SearchManager m) => m.language);
    return Consumer(
      builder: (context, ref, _) {
        final favLanguageCodes =
            ref.watch(
              settingsStringListManagerProvider(SPKeys.favLanguageCodes),
            ) ??
            <String>[];

        return LanguageAutoComplete(
          suffixIcon: AudioTypeFilterButton(
            mode: OverlayMode.platformModalMode,
          ),
          value: language,
          onSelected: (language) {
            di<SearchManager>()
              ..setLanguage(language)
              ..search();
            if (language?.isoCode != null) {
              ref
                  .read(
                    settingsStringManagerProvider(
                      SPKeys.lastLanguageCode,
                    ).notifier,
                  )
                  .set(language!.isoCode);
            }
          },
          favs: favLanguageCodes.toSet(),
          addFav: (language) {
            if (language?.isoCode == null) return;
            ref
                .read(
                  settingsStringListManagerProvider(
                    SPKeys.favLanguageCodes,
                  ).notifier,
                )
                .addToStringList(language!.isoCode);
          },
          removeFav: (language) {
            if (language?.isoCode == null) return;
            ref
                .read(
                  settingsStringListManagerProvider(
                    SPKeys.favLanguageCodes,
                  ).notifier,
                )
                .removeFromStringList(language!.isoCode);
          },
        );
      },
    );
  }
}
