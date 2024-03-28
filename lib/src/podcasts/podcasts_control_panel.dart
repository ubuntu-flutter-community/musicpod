import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podcast_search/podcast_search.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../data.dart';
import '../../library.dart';
import '../../theme.dart';
import 'podcast_genre_autocomplete.dart';

class PodcastsControlPanel extends ConsumerWidget {
  const PodcastsControlPanel({
    super.key,
    required this.limit,
    required this.setLimit,
    required this.search,
    required this.searchQuery,
    required this.setCountry,
    required this.country,
    required this.sortedCountries,
    required this.buttonStyle,
    required this.setPodcastGenre,
    required this.podcastGenre,
    required this.textStyle,
    required this.sortedGenres,
  });

  final int limit;
  final void Function(int? value) setLimit;
  final void Function({String? searchQuery}) search;
  final String? searchQuery;
  final void Function(Country? value) setCountry;
  final Country? country;
  final List<Country> sortedCountries;
  final ButtonStyle buttonStyle;
  final void Function(PodcastGenre value) setPodcastGenre;
  final PodcastGenre podcastGenre;
  final TextStyle? textStyle;
  final List<PodcastGenre> sortedGenres;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryModel = ref.read(libraryModelProvider);
    final theme = context.t;
    final fillColor = theme.chipTheme.selectedColor;
    final contentPadding = yaruStyled
        ? const EdgeInsets.only(
            bottom: 9,
            top: 9,
            right: 15,
            left: 15,
          )
        : const EdgeInsets.only(top: 11, bottom: 11, left: 15, right: 15);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 10,
        runSpacing: 20,
        children: [
          CountryAutoComplete(
            contentPadding: contentPadding,
            fillColor: fillColor,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100),
              borderSide: BorderSide.none,
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            isDense: true,
            width: 150,
            height: chipHeight,
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
            onSelected: (country) {
              setCountry(country);
              setLimit(20);

              search(searchQuery: searchQuery);
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
          PodcastGenreAutoComplete(
            contentPadding: contentPadding,
            fillColor: podcastGenre != PodcastGenre.all ? fillColor : null,
            filled: podcastGenre != PodcastGenre.all,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100),
              borderSide: BorderSide.none,
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            isDense: true,
            width: 150,
            height: chipHeight,
            genres: sortedGenres,
            onSelected: (podcastGenre) {
              if (podcastGenre != null) {
                setPodcastGenre(podcastGenre);

                setLimit(20);
              }

              search(searchQuery: searchQuery);
            },
            value: podcastGenre,

            addFav: (v) {
              // if (country?.code == null) return;
              // libraryModel.addFavCountry(v!.code);
            },
            removeFav: (v) {
              // if (country?.code == null) return;
              // libraryModel.removeFavCountry(v!.code);
            },
            // favs: libraryModel.favCountryCodes,
          ),
        ],
      ),
    );
  }
}
