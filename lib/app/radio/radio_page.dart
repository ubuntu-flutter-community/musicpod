import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_page.dart';
import 'package:musicpod/app/common/offline_page.dart';
import 'package:musicpod/app/connectivity_notifier.dart';
import 'package:musicpod/app/radio/radio_model.dart';
import 'package:musicpod/app/radio/radio_search_field.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:musicpod/service/radio_service.dart';
import 'package:provider/provider.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

class RadioPage extends StatefulWidget {
  const RadioPage({super.key, this.showWindowControls = true});

  final bool showWindowControls;

  static Widget create(BuildContext context, [bool showWindowControls = true]) {
    final countryCode = WidgetsBinding
        .instance.platformDispatcher.locale.countryCode
        ?.toLowerCase();
    return ChangeNotifierProvider(
      create: (_) => RadioModel(getService<RadioService>(), countryCode),
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
    context.read<RadioModel>().init();
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = context.select((ConnectivityNotifier c) => c.isOnline);
    final stations = context.select((RadioModel m) => m.stations);
    final search = context.read<RadioModel>().search;
    final searchQuery = context.select((RadioModel m) => m.searchQuery);
    final setSearchQuery = context.read<RadioModel>().setSearchQuery;

    return isOnline
        ? AudioPage(
            noResultMessage: context.l10n.noStationFound,
            title: RadioSearchField(
              text: searchQuery,
              onSubmitted: (value) {
                setSearchQuery(value);
                search(value);
              },
            ),
            audioPageType: AudioPageType.radio,
            placeTrailer: false,
            showTrack: false,
            editableName: false,
            deletable: false,
            controlPageButton: const SizedBox.shrink(),
            audios: stations,
            pageId: context.l10n.radio,
            pageTitle:
                '${context.l10n.radio}${searchQuery?.isEmpty == false ? ' ${context.l10n.search}: $searchQuery' : ''}',
            placePlayAllButton: false,
          )
        : const OfflinePage();
  }
}
