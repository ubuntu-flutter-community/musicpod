import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:radio_browser_api/radio_browser_api.dart' hide Country;
import '../../common.dart';
import 'tag_popup.dart';

class RadioControlPanel extends StatelessWidget {
  const RadioControlPanel({
    super.key,
    required this.limit,
    required this.setLimit,
    required this.searchQuery,
    required this.tag,
    required this.loadStationsByCountry,
    required this.loadStationsByTag,
    required this.search,
    required this.country,
    required this.setCountry,
    required this.setTag,
    required this.sortedCountries,
    required this.addFavTag,
    required this.removeFavTag,
    required this.favTags,
    required this.setSearchQuery,
    required this.setLastFav,
    required this.tags,
  });

  final int limit;
  final void Function(int? value) setLimit;
  final String? searchQuery;
  final Tag? tag;
  final Future<void> Function() loadStationsByCountry;
  final Future<void> Function() loadStationsByTag;
  final Future<void> Function({String? name, String? tag}) search;
  final Country? country;
  final void Function(Country? value) setCountry;
  final void Function(Tag? value) setTag;
  final List<Country> sortedCountries;
  final void Function(String value) addFavTag;
  final void Function(String value) removeFavTag;
  final Set<String> favTags;
  final void Function(String? value) setSearchQuery;
  final void Function(String? value) setLastFav;
  final List<Tag>? tags;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          LimitPopup(
            limits: const [100, 200, 400, 500],
            value: limit,
            onSelected: (value) {
              setLimit(value);
              if (searchQuery?.isEmpty == true) {
                if (tag == null) {
                  loadStationsByCountry();
                } else {
                  loadStationsByTag();
                }
              } else {
                search(name: searchQuery);
              }
            },
          ),
          CountryPopup(
            value: tag != null ? Country.none : country,
            onSelected: (country) {
              setCountry(country);
              loadStationsByCountry();
              setTag(null);
            },
            countries: sortedCountries,
          ),
          const SizedBox(
            width: 10,
          ),
          TagPopup(
            value: tag,
            addFav: (tag) {
              if (tag?.name == null) return;
              addFavTag(tag!.name);
            },
            removeFav: (tag) {
              if (tag?.name == null) return;
              removeFavTag(tag!.name);
            },
            favs: favTags,
            onSelected: (tag) {
              setTag(tag);
              if (tag != null) {
                loadStationsByTag();
              } else {
                setSearchQuery(null);
                search();
              }
              if (tag?.name.isNotEmpty == true) {
                setLastFav(tag!.name);
              }
            },
            tags: [
              ...[...?tags].where((e) => favTags.contains(e.name) == true),
              ...[...?tags].where((e) => favTags.contains(e.name) == false),
            ],
          ),
        ],
      ),
    );
  }
}
