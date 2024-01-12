import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:provider/provider.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../app.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../globals.dart';
import '../../radio.dart';
import '../library/library_model.dart';
import 'country_auto_complete.dart';
import 'radio_control_panel.dart';
import 'radio_search.dart';
import 'radio_search_page.dart';

class RadioDiscoverPage extends StatefulWidget {
  const RadioDiscoverPage({
    super.key,
  });

  @override
  State<RadioDiscoverPage> createState() => _RadioDiscoverPageState();
}

class _RadioDiscoverPageState extends State<RadioDiscoverPage> {
  @override
  void initState() {
    super.initState();

    final model = context.read<RadioModel>();

    switch (model.radioSearch) {
      case RadioSearch.country:
        model.setSearchQuery(model.country?.name);
        break;
      case RadioSearch.tag:
        model.setSearchQuery(model.tag?.name);

      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    final showWindowControls =
        context.select((AppModel a) => a.showWindowControls);
    final model = context.read<RadioModel>();
    final libraryModel = context.read<LibraryModel>();
    final searchQuery = context.select((RadioModel m) => m.searchQuery);
    final setSearchQuery = model.setSearchQuery;

    context.select((LibraryModel m) => m.favTagsLength);

    final radioSearch = context.select((RadioModel m) => m.radioSearch);

    final country = context.select((RadioModel m) => m.country);
    final setCountry = model.setCountry;
    final tag = context.select((RadioModel m) => m.tag);

    final Widget input = switch (radioSearch) {
      RadioSearch.country => CountryAutoComplete(
          countries: Country.values,
          onSelected: (country) {
            setCountry(country);
            setSearchQuery(country?.name);
          },
          value: country,
          addFav: (v) {},
          removeFav: (v) {},
        ),
      RadioSearch.tag => TagAutoComplete(
          value: tag,
          addFav: (tag) {
            if (tag?.name == null) return;
            libraryModel.addFavTag(tag!.name);
          },
          removeFav: (tag) {
            if (tag?.name == null) return;
            libraryModel.removeFavTag(tag!.name);
          },
          favs: libraryModel.favTags,
          onSelected: (tag) {
            setSearchQuery(tag?.name);
            model.setTag(tag);
          },
          tags: [
            ...[
              ...?model.tags,
            ].where(
              (e) => libraryModel.favTags.contains(e.name) == true,
            ),
            ...[...?model.tags].where(
              (e) => libraryModel.favTags.contains(e.name) == false,
            ),
          ],
        ),
      _ => SearchingBar(
          key: ValueKey(searchQuery),
          text: searchQuery,
          onClear: () {
            setSearchQuery(null);
          },
          onSubmitted: setSearchQuery,
        ),
    };

    return Scaffold(
      appBar: HeaderBar(
        style: showWindowControls
            ? YaruTitleBarStyle.normal
            : YaruTitleBarStyle.undecorated,
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
      body: Column(
        children: [
          const Row(
            children: [
              RadioControlPanel(),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Expanded(
            child: searchQuery?.isNotEmpty == true
                ? RadioSearchPage(
                    key: ValueKey(
                      searchQuery.toString() +
                          tag.toString() +
                          radioSearch.toString(),
                    ),
                    includeHeader: false,
                    radioSearch: radioSearch,
                    searchQuery: searchQuery,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
