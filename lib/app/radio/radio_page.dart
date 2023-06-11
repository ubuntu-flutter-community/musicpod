import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_page.dart';
import 'package:musicpod/app/common/country_popup.dart';
import 'package:musicpod/app/common/offline_page.dart';
import 'package:musicpod/app/connectivity_notifier.dart';
import 'package:musicpod/app/radio/radio_model.dart';
import 'package:musicpod/app/radio/radio_search_field.dart';
import 'package:musicpod/app/radio/tag_popup.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:musicpod/service/radio_service.dart';
import 'package:provider/provider.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

class RadioPage extends StatefulWidget {
  const RadioPage({super.key, this.showWindowControls = true});

  final bool showWindowControls;

  static Widget create(BuildContext context, [bool showWindowControls = true]) {
    return ChangeNotifierProvider(
      create: (_) => RadioModel(getService<RadioService>()),
      child: RadioPage(
        showWindowControls: showWindowControls,
      ),
    );
  }

  @override
  State<RadioPage> createState() => _RadioPageState();
}

class _RadioPageState extends State<RadioPage> {
  @override
  void initState() {
    super.initState();
    final countryCode = WidgetsBinding
        .instance.platformDispatcher.locale.countryCode
        ?.toLowerCase();
    context.read<RadioModel>().init(countryCode);
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = context.select((ConnectivityNotifier c) => c.isOnline);
    final stations = context.select((RadioModel m) => m.stations);
    final search = context.read<RadioModel>().search;
    final searchQuery = context.select((RadioModel m) => m.searchQuery);
    final setSearchQuery = context.read<RadioModel>().setSearchQuery;
    final country = context.select((RadioModel m) => m.country);
    final setCountry = context.read<RadioModel>().setCountry;
    final loadStationsByCountry =
        context.read<RadioModel>().loadStationsByCountry;
    final tag = context.select((RadioModel m) => m.tag);
    final setTag = context.read<RadioModel>().setTag;
    final tags = context.select((RadioModel m) => m.tags);
    final loadStationsByTag = context.read<RadioModel>().loadStationsByTag;

    final textStyle = Theme.of(context)
        .textTheme
        .bodyLarge
        ?.copyWith(fontWeight: FontWeight.w100);

    return isOnline
        ? AudioPage(
            showWindowControls: widget.showWindowControls,
            noResultMessage: context.l10n.noStationFound,
            title: RadioSearchField(
              text: searchQuery,
              onSubmitted: (value) {
                setSearchQuery(value);
                search(value);
              },
            ),
            titleLabel: context.l10n.station,
            artistLabel: context.l10n.quality,
            albumLabel: context.l10n.tags,
            audioPageType: AudioPageType.radio,
            placeTrailer: false,
            showTrack: false,
            editableName: false,
            deletable: false,
            controlPageButton: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 8,
                ),
                Text(
                  '${context.l10n.country}:',
                  style: textStyle,
                ),
                const SizedBox(
                  width: 5,
                ),
                CountryPopup(
                  value: country,
                  onSelected: (country) {
                    setCountry(country);
                    loadStationsByCountry();
                  },
                ),
                const SizedBox(
                  width: 15,
                ),
                Text(
                  '${context.l10n.tag}:',
                  style: textStyle,
                ),
                const SizedBox(
                  width: 5,
                ),
                TagPopup(
                  value: tag,
                  onSelected: (tag) {
                    setTag(tag);
                    loadStationsByTag();
                  },
                  tags: tags,
                )
              ],
            ),
            audios: stations,
            pageId: context.l10n.radio,
            pageTitleWidget: Text(
              searchQuery?.isEmpty == false
                  ? ' ${context.l10n.search}: $searchQuery'
                  : '',
              style: textStyle,
            ),
            placePlayAllButton: false,
          )
        : const OfflinePage();
  }
}
