import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../data.dart';
import '../../theme.dart';
import '../l10n/l10n.dart';

class PodcastsControlPanel extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = context.t;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 10,
        runSpacing: 20,
        children: [
          LimitPopup(
            buttonStyle: createPopupStyle(theme),
            value: limit,
            onSelected: (value) {
              setLimit(value);
              search(searchQuery: searchQuery);
            },
          ),
          CountryPopup(
            buttonStyle: createPopupStyle(theme),
            onSelected: (value) {
              setCountry(value);
              search(searchQuery: searchQuery);
            },
            value: country,
            countries: sortedCountries,
          ),
          YaruPopupMenuButton<PodcastGenre>(
            style: createPopupStyle(theme),
            icon: const DropDownArrow(),
            onSelected: (value) {
              setPodcastGenre(value);
              search(searchQuery: searchQuery);
            },
            initialValue: podcastGenre,
            child: Text(
              podcastGenre.localize(context.l10n),
              style: textStyle,
            ),
            itemBuilder: (context) {
              return [
                for (final genre in sortedGenres)
                  PopupMenuItem(
                    value: genre,
                    child: Text(genre.localize(context.l10n)),
                  ),
              ];
            },
          ),
        ],
      ),
    );
  }
}
