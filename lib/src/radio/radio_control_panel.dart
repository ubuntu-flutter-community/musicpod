import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../l10n.dart';
import 'radio_model.dart';
import 'radio_search.dart';

class RadioControlPanel extends StatelessWidget {
  const RadioControlPanel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final model = context.read<RadioModel>();

    final radioSearch = context.select((RadioModel m) => m.radioSearch);
    final setRadioSearch = model.setRadioSearch;
    return Padding(
      padding: const EdgeInsets.only(left: 30),
      child: YaruChoiceChipBar(
        yaruChoiceChipBarStyle: YaruChoiceChipBarStyle.wrap,
        clearOnSelect: false,
        selectedFirst: false,
        labels: RadioSearch.values
            .map((e) => Text(e.localize(context.l10n)))
            .toList(),
        isSelected: RadioSearch.values.map((e) => e == radioSearch).toList(),
        onSelected: (index) => setRadioSearch(RadioSearch.values[index]),
      ),
    );

    // return SingleChildScrollView(
    //   padding: const EdgeInsets.symmetric(horizontal: 20),
    //   scrollDirection: Axis.horizontal,
    //   child: Row(
    //     children: [
    //       CountryPopup(
    //         value: tag != null ? null : country,
    //         onSelected: (country) {
    //           setCountry(country);
    //           loadStationsByCountry();
    //           setTag(null);
    //         },
    //         countries: sortedCountries,
    //       ),
    //       const SizedBox(
    //         width: 10,
    //       ),
    //       TagPopup(
    //         value: tag,
    //         addFav: (tag) {
    //           if (tag?.name == null) return;
    //           addFavTag(tag!.name);
    //         },
    //         removeFav: (tag) {
    //           if (tag?.name == null) return;
    //           removeFavTag(tag!.name);
    //         },
    //         favs: favTags,
    //         onSelected: (tag) {
    //           setTag(tag);
    //           if (tag != null) {
    //             loadStationsByTag();
    //           } else {
    //             setSearchQuery(null);
    //             search();
    //           }
    //           if (tag?.name.isNotEmpty == true) {
    //             setLastFav(tag!.name);
    //           }
    //         },
    //         tags: [
    //           ...[...?tags].where((e) => favTags.contains(e.name) == true),
    //           ...[...?tags].where((e) => favTags.contains(e.name) == false),
    //         ],
    //       ),
    //     ],
    //   ),
    // );
  }
}
