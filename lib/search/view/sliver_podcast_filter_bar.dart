import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/data/podcast_genre.dart';
import '../../common/view/common_widgets.dart';
import '../../common/view/country_auto_complete.dart';
import '../../common/view/language_autocomplete.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../library/library_model.dart';
import '../../podcasts/view/podcast_genre_autocomplete.dart';
import '../../settings/settings_model.dart';
import '../search_model.dart';

class SliverPodcastFilterBar extends StatelessWidget with WatchItMixin {
  const SliverPodcastFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final libraryModel = di<LibraryModel>();
    final theme = context.t;
    final searchModel = di<SearchModel>();
    final country = watchPropertyValue((SearchModel m) => m.country);

    void setCountry(Country? country) {
      searchModel.setCountry(country);
      libraryModel.setLastCountryCode(country?.code);
    }

    final podcastGenre = watchPropertyValue((SearchModel m) => m.podcastGenre);
    final sortedGenrez = watchPropertyValue((SearchModel m) => m.sortedGenres);
    final setPodcastGenre = searchModel.setPodcastGenre;
    final usePodcastIndex =
        watchPropertyValue((SettingsModel m) => m.usePodcastIndex);
    watchPropertyValue((LibraryModel m) => m.favLanguagesLength);
    watchPropertyValue((LibraryModel m) => m.favCountriesLength);
    final favLanguageCodes =
        watchPropertyValue((LibraryModel m) => m.favLanguageCodes);

    final sortedGenres = usePodcastIndex
        ? sortedGenrez.where((e) => !e.name.contains('XXXITunesOnly')).toList()
        : sortedGenrez
            .where((e) => !e.name.contains('XXXPodcastIndexOnly'))
            .toList();
    final language = watchPropertyValue((SearchModel m) => m.language);

    final fillColor = theme.chipTheme.selectedColor;

    const width = 150.0;
    final height = chipHeight - 2;
    var outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(100),
      borderSide: yaruStyled
          ? BorderSide.none
          : BorderSide(
              color: theme.colorScheme.outline,
              width: 1.3,
              strokeAlign: 1,
            ),
    );
    final style = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w500,
    );

    return SliverAppBar(
      shape: const RoundedRectangleBorder(side: BorderSide.none),
      elevation: 0,
      backgroundColor: context.t.scaffoldBackgroundColor,
      automaticallyImplyLeading: false,
      pinned: true,
      centerTitle: true,
      titleSpacing: 0,
      stretch: true,
      onStretchTrigger: () async {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
          if (context.mounted) {
            searchModel.incrementPodcastLimit(4);
            return searchModel.search();
          }
        });
      },
      title: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: 380,
          child: Row(
            children: [
              if (usePodcastIndex)
                Expanded(
                  child: LanguageAutoComplete(
                    contentPadding: countryPillPadding,
                    fillColor: language != null
                        ? fillColor
                        : yaruStyled
                            ? theme.dividerColor
                            : null,
                    filled: language != null,
                    border: outlineInputBorder,
                    style: style,
                    isDense: true,
                    width: width,
                    height: height,
                    value: language,
                    favs: favLanguageCodes,
                    addFav: (language) {
                      if (language?.isoCode == null) return;
                      libraryModel.addFavLanguageCode(language!.isoCode);
                    },
                    removeFav: (language) {
                      if (language?.isoCode == null) return;
                      libraryModel.removeFavLanguageCode(language!.isoCode);
                    },
                    onSelected: (language) {
                      searchModel.setLanguage(language);
                      libraryModel.setLastLanguage(language?.isoCode);
                      searchModel.search();
                    },
                  ),
                )
              else
                Expanded(
                  child: CountryAutoComplete(
                    contentPadding: countryPillPadding,
                    fillColor: fillColor,
                    filled: true,
                    border: outlineInputBorder,
                    style: style,
                    isDense: true,
                    width: width,
                    height: height,
                    countries: [
                      ...[
                        ...Country.values,
                      ].where(
                        (e) =>
                            libraryModel.favCountryCodes.contains(e.code) ==
                            true,
                      ),
                      ...[...Country.values].where(
                        (e) =>
                            libraryModel.favCountryCodes.contains(e.code) ==
                            false,
                      ),
                    ]..remove(Country.none),
                    onSelected: (country) {
                      setCountry(country);
                      searchModel.search();
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
                ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: PodcastGenreAutoComplete(
                  contentPadding: countryPillPadding,
                  fillColor: podcastGenre != PodcastGenre.all
                      ? fillColor
                      : yaruStyled
                          ? theme.dividerColor
                          : null,
                  filled: podcastGenre != PodcastGenre.all,
                  border: outlineInputBorder,
                  style: style,
                  isDense: true,
                  width: width,
                  height: height,
                  genres: sortedGenres,
                  onSelected: (podcastGenre) {
                    if (podcastGenre != null) {
                      setPodcastGenre(podcastGenre);
                    }

                    searchModel.search();
                  },
                  value: podcastGenre,
                  addFav: (v) {},
                  removeFav: (v) {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}