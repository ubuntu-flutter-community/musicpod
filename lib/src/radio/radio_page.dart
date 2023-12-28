import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../app.dart';
import '../../build_context_x.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../player.dart';
import '../../theme.dart';
import '../../theme_data_x.dart';
import '../common/loading_grid.dart';
import '../l10n/l10n.dart';
import '../library/library_model.dart';
import 'radio_control_panel.dart';
import 'radio_lib_page.dart';
import 'radio_model.dart';
import 'radio_page_title.dart';
import 'station_card.dart';

class RadioPage extends StatefulWidget {
  const RadioPage({
    super.key,
    this.onTextTap,
    required this.isOnline,
    this.countryCode,
  });

  final void Function(String text)? onTextTap;
  final bool isOnline;
  final String? countryCode;

  @override
  State<RadioPage> createState() => _RadioPageState();
}

class _RadioPageState extends State<RadioPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<RadioModel>().init(
            countryCode: widget.countryCode,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = context.read<RadioModel>();
    final connected = context.select((RadioModel m) => m.connected);
    final stations = context.select((RadioModel m) => m.stations);
    final statusCode = context.select((RadioModel m) => m.statusCode);
    final stationsCount = context.select((RadioModel m) => m.stations?.length);
    final search = model.search;
    final searchQuery = context.select((RadioModel m) => m.searchQuery);
    final setSearchQuery = model.setSearchQuery;
    final country = context.select((RadioModel m) => m.country);
    final sortedCountries = context.select((RadioModel m) => m.sortedCountries);
    final setCountry = model.setCountry;
    final loadStationsByCountry = model.loadStationsByCountry;
    final tag = context.select((RadioModel m) => m.tag);
    final setTag = model.setTag;
    final tags = context.select((RadioModel m) => m.tags);
    final loadStationsByTag = model.loadStationsByTag;
    final limit = context.select((RadioModel m) => m.limit);
    final setLimit = model.setLimit;

    final play = context.select((PlayerModel m) => m.play);

    final starStation = context.select((LibraryModel m) => m.addStarredStation);
    final unstarStation = context.select((LibraryModel m) => m.unStarStation);
    final isStarredStation = context.read<LibraryModel>().isStarredStation;
    final addFavTag = context.read<LibraryModel>().addFavTag;
    final removeFavTag = context.read<LibraryModel>().removeFavTag;
    final favTags = context.select((LibraryModel m) => m.favTags);
    context.select((LibraryModel m) => m.favTagsLength);
    final setLastFav = context.read<LibraryModel>().setLastFav;

    final radioIndex = context.select((LibraryModel m) => m.radioindex);
    final setRadioIndex = context.read<LibraryModel>().setRadioIndex;

    final searchActive = context.select((RadioModel m) => m.searchActive);
    final setSearchActive = model.setSearchActive;

    final showWindowControls =
        context.select((AppModel a) => a.showWindowControls);

    final controlPanel = RadioControlPanel(
      limit: limit,
      setLimit: setLimit,
      searchQuery: searchQuery,
      tag: tag,
      loadStationsByCountry: loadStationsByCountry,
      loadStationsByTag: loadStationsByTag,
      search: search,
      country: country,
      setCountry: setCountry,
      setTag: setTag,
      sortedCountries: sortedCountries,
      addFavTag: addFavTag,
      removeFavTag: removeFavTag,
      favTags: favTags,
      setSearchQuery: setSearchQuery,
      setLastFav: setLastFav,
      tags: tags,
    );

    if (!widget.isOnline) {
      return const OfflinePage();
    } else {
      Widget discoverGrid;
      if (connected == false) {
        discoverGrid = _ReconnectPage(
          text: 'Not connected to any radiobrowser server.',
          init: () => context.read<RadioModel>().init(
                countryCode: widget.countryCode,
              ),
        );
      } else {
        if (stations == null) {
          discoverGrid = LoadingGrid(limit: limit);
        } else {
          if (stationsCount == 0) {
            if (statusCode != null && statusCode != '200') {
              discoverGrid = _ReconnectPage(
                text: statusCode,
                init: () => context.read<RadioModel>().init(
                      countryCode: widget.countryCode,
                    ),
              );
            } else {
              discoverGrid = NoSearchResultPage(
                message: Text(context.l10n.noStationFound),
              );
            }
          } else {
            discoverGrid = GridView.builder(
              padding: gridPadding,
              gridDelegate: imageGridDelegate,
              itemCount: stationsCount,
              itemBuilder: (context, index) {
                final station = stations.elementAt(index);
                final onTextTap = widget.onTextTap;
                return StationCard(
                  station: station,
                  play: play,
                  isStarredStation: isStarredStation,
                  onTextTap: onTextTap,
                  unstarStation: unstarStation,
                  starStation: starStation,
                );
              },
            );
          }
        }
      }

      final discoverBody = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          controlPanel,
          const SizedBox(
            height: 15,
          ),
          Expanded(child: discoverGrid),
        ],
      );

      final radioLibPage = RadioLibPage(
        isOnline: widget.isOnline,
        play: play,
        isStarredStation: isStarredStation,
        unstarStation: unstarStation,
        starStation: starStation,
      );

      return DefaultTabController(
        initialIndex: radioIndex ?? 1,
        length: 2,
        child: Scaffold(
          appBar: HeaderBar(
            style: showWindowControls
                ? YaruTitleBarStyle.normal
                : YaruTitleBarStyle.undecorated,
            titleSpacing: 0,
            leading: Navigator.of(context).canPop()
                ? NavBackButton(
                    onPressed: () {
                      setSearchActive(false);
                    },
                  )
                : const SizedBox.shrink(),
            actions: [
              Flexible(
                child: Padding(
                  padding: appBarActionSpacing,
                  child: SearchButton(
                    active: searchActive,
                    onPressed: () => setSearchActive(!searchActive),
                  ),
                ),
              ),
            ],
            title: RadioPageTitle(
              onIndexSelected: setRadioIndex,
              searchActive: searchActive,
              setSearchActive: setSearchActive,
              search: search,
              setSearchQuery: setSearchQuery,
              setTag: setTag,
              searchQuery: searchQuery,
            ),
          ),
          body: Padding(
            padding: tabViewPadding,
            child: TabBarView(
              children: [
                radioLibPage,
                discoverBody,
              ],
            ),
          ),
        ),
      );
    }
  }
}

class _ReconnectPage extends StatelessWidget {
  const _ReconnectPage({
    required this.text,
    required this.init,
  });

  final String? text;
  final Function() init;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(text ?? ''),
          ),
          OutlinedButton.icon(
            onPressed: init,
            label: const Text('Reconnect to server'),
            icon: Icon(Iconz().refresh),
          ),
        ],
      ),
    );
  }
}

class RadioFallBackIcon extends StatelessWidget {
  const RadioFallBackIcon({
    super.key,
    this.iconSize,
    required this.station,
  });

  final double? iconSize;
  final Audio? station;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final light = theme.isLight;
    final fallBackColor = light ? kCardColorLight : kCardColorDark;
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            getAlphabetColor(
              station?.title ?? station?.album ?? '',
              fallBackColor,
            ).scale(lightness: light ? 0 : -0.4, saturation: -0.5),
            getAlphabetColor(
              station?.title ?? station?.album ?? '',
              fallBackColor,
            ).scale(lightness: light ? -0.1 : -0.2, saturation: -0.5),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Icon(
          Iconz().radio,
          size: iconSize ?? 70,
          color: contrastColor(
            getAlphabetColor(
              station?.title ?? station?.album ?? '',
              fallBackColor,
            ),
          ).withOpacity(0.7),
        ),
      ),
    );
  }
}

class RadioPageIcon extends StatelessWidget {
  const RadioPageIcon({
    super.key,
    required this.selected,
  });

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final audioType = context.select((PlayerModel m) => m.audio?.audioType);

    final theme = context.t;
    if (audioType == AudioType.radio) {
      return Icon(
        Iconz().play,
        color: theme.colorScheme.primary,
      );
    }

    return selected ? Icon(Iconz().radioFilled) : Icon(Iconz().radio);
  }
}
