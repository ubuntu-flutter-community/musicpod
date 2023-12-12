import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../app.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../player.dart';
import '../../utils.dart';
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
      readSetting(kLastFav).then(
        (value) => context.read<RadioModel>().init(
              isOnline: widget.isOnline,
              countryCode: widget.countryCode,
              lastFav: value == null ? null : value as String,
            ),
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
          init: () => readSetting(kLastFav).then(
            (value) => context.read<RadioModel>().init(
                  isOnline: widget.isOnline,
                  countryCode: widget.countryCode,
                  lastFav: value == null ? null : value as String,
                ),
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
                init: () => readSetting(kLastFav).then(
                  (value) => context.read<RadioModel>().init(
                        isOnline: widget.isOnline,
                        countryCode: widget.countryCode,
                        lastFav: value == null ? null : value as String,
                      ),
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
            height: 10,
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
    final theme = Theme.of(context);
    final light = theme.brightness == Brightness.light;
    final fallBackColor = light ? theme.dividerColor : Colors.black38;
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            getColor(
              station?.title ?? station?.album ?? '',
              fallBackColor,
            ).withOpacity(0.5),
            getColor(
              station?.title ?? station?.album ?? '',
              fallBackColor,
            ).withOpacity(0.9),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Icon(
          Iconz().radio,
          size: iconSize ?? 70,
          color: contrastColor(
            getColor(
              station?.title ?? station?.album ?? '',
              fallBackColor,
            ),
          ).withOpacity(0.7),
        ),
      ),
    );
  }
}

Color getColor(String name, Color fallBackColor) {
  if (name.toLowerCase().contains('lofi') ||
      name.toLowerCase().contains('lounge') ||
      name.toLowerCase().contains('chill')) {
    return Colors.purple;
  } else if (name.toLowerCase().contains('rap') ||
      name.toLowerCase().contains('hip-hop') ||
      name.toLowerCase().contains('hop') ||
      name.toLowerCase().contains('jam') ||
      name.toLowerCase().contains('soul') ||
      name.toLowerCase().contains('rnb') ||
      name.toLowerCase().contains('deutschrap')) {
    return Colors.black87;
  } else if (name.toLowerCase().contains('xmas') ||
      name.toLowerCase().contains('christmas') ||
      name.toLowerCase().contains('weihnacht')) {
    return Colors.limeAccent;
  } else if (name.toLowerCase().contains('pop') ||
      name.toLowerCase().contains('charts')) {
    return Colors.greenAccent;
  } else if (name.toLowerCase().contains('house')) {
    return Colors.white38;
  } else if (name.toLowerCase().contains('techno')) {
    return Colors.pink;
  } else if (name.toLowerCase().contains('metal') ||
      name.toLowerCase().contains('punk')) {
    return Colors.yellow;
  } else if (name.toLowerCase().contains('rock')) {
    return Colors.blue;
  } else if (name.toLowerCase().contains('classic') ||
      name.toLowerCase().contains('klassik')) {
    return Colors.amber;
  } else if (name.toLowerCase().contains('arab') ||
      name.toLowerCase().contains('orient') ||
      name.toLowerCase().contains('schlager') ||
      name.toLowerCase().contains('volk') ||
      name.toLowerCase().contains('deutsch') ||
      name.toLowerCase().contains('islam')) {
    return Colors.brown;
  } else {
    return fallBackColor;
  }
}

class RadioPageIcon extends StatelessWidget {
  const RadioPageIcon({
    super.key,
    required this.isPlaying,
    required this.selected,
  });

  final bool isPlaying, selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (isPlaying) {
      return Icon(
        Iconz().play,
        color: theme.colorScheme.primary,
      );
    }

    return selected ? Icon(Iconz().radioFilled) : Icon(Iconz().radio);
  }
}
