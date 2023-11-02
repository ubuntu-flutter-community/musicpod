import 'package:flutter/material.dart';
import 'package:musicpod/app/app_model.dart';
import 'package:musicpod/app/common/audio_card.dart';
import 'package:musicpod/constants.dart';
import 'package:musicpod/app/common/country_popup.dart';
import 'package:musicpod/app/common/limit_popup.dart';
import 'package:musicpod/app/common/no_search_result_page.dart';
import 'package:musicpod/app/common/offline_page.dart';
import 'package:musicpod/app/common/safe_network_image.dart';
import 'package:musicpod/app/library_model.dart';
import 'package:musicpod/app/local_audio/album_view.dart';
import 'package:musicpod/app/player/player_model.dart';
import 'package:musicpod/app/radio/radio_model.dart';
import 'package:musicpod/app/radio/station_page.dart';
import 'package:musicpod/app/radio/tag_popup.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

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

    context.read<RadioModel>().init(widget.countryCode);
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

    final searchActive = context.select((RadioModel m) => m.searchActive);
    final setSearchActive = model.setSearchActive;

    final theme = Theme.of(context);

    final showWindowControls =
        context.select((AppModel a) => a.showWindowControls);

    final controlPanel = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        height: kYaruTitleBarItemHeight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            LimitPopup(
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
              value: country,
              onSelected: (country) {
                setCountry(country);
                loadStationsByCountry();
              },
              countries: sortedCountries,
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
              },
              tags: tags,
            ),
          ],
        ),
      ),
    );

    if (!widget.isOnline) {
      return const OfflinePage();
    } else {
      Widget body;
      if (connected == false) {
        body = _ReconnectPage(
          text: 'Not connected to any radiobrowser server.',
          init: () => model.init(widget.countryCode),
        );
      } else {
        if (stations == null) {
          body = GridView(
            gridDelegate: kImageGridDelegate,
            padding: kPodcastGridPadding,
            children: List.generate(limit, (index) => Audio())
                .map((e) => const AudioCard())
                .toList(),
          );
        } else {
          if (stationsCount == 0) {
            if (statusCode != '200') {
              body = _ReconnectPage(
                text: statusCode,
                init: () => model.init(widget.countryCode),
              );
            } else {
              body = NoSearchResultPage(
                message: Text(context.l10n.noStationFound),
              );
            }
          } else {
            body = GridView.builder(
              padding: kPodcastGridPadding,
              gridDelegate: kImageGridDelegate,
              itemCount: stationsCount,
              itemBuilder: (context, index) {
                final station = stations.elementAt(index);
                final onTextTap = widget.onTextTap;
                return _StationCard(
                  station: station,
                  play: play,
                  isStarredStation: isStarredStation,
                  showWindowControls: showWindowControls,
                  onTextTap: onTextTap,
                  unstarStation: unstarStation,
                  starStation: starStation,
                );
              },
            );
          }
        }
      }

      return YaruDetailPage(
        appBar: YaruWindowTitleBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          border: BorderSide.none,
          style: showWindowControls
              ? YaruTitleBarStyle.normal
              : YaruTitleBarStyle.undecorated,
          titleSpacing: 0,
          leading: Navigator.of(context).canPop()
              ? const YaruBackButton(
                  style: YaruBackButtonStyle.rounded,
                )
              : const SizedBox.shrink(),
          title: Padding(
            padding: const EdgeInsets.only(right: 40),
            child: YaruSearchTitleField(
              key: ValueKey(searchQuery),
              text: searchQuery,
              alignment: Alignment.center,
              width: kSearchBarWidth,
              title: controlPanel,
              searchActive: searchActive,
              onSearchActive: () => setSearchActive(!searchActive),
              onClear: () {
                setTag(null);
                setSearchActive(false);
                setSearchQuery(null);
                search();
              },
              onSubmitted: (value) {
                setSearchQuery(value);
                search(name: value);
              },
            ),
          ),
        ),
        body: body,
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
            icon: const Icon(YaruIcons.refresh),
          ),
        ],
      ),
    );
  }
}

class _StationCard extends StatelessWidget {
  const _StationCard({
    required this.station,
    required this.play,
    required this.isStarredStation,
    required this.showWindowControls,
    required this.onTextTap,
    required this.unstarStation,
    required this.starStation,
  });

  final Audio? station;
  final Future<void> Function({Duration? newPosition, Audio? newAudio}) play;
  final bool Function(String name) isStarredStation;
  final bool showWindowControls;
  final void Function(String text)? onTextTap;
  final void Function(String name) unstarStation;
  final void Function(String name, Set<Audio> audios) starStation;

  @override
  Widget build(BuildContext context) {
    return AudioCard(
      bottom: AudioCardBottom(text: station?.title?.replaceAll('_', '') ?? ''),
      onPlay: () => play(newAudio: station),
      onTap: station == null ? null : () => onTap(context, station!),
      image: SizedBox.expand(
        child: SafeNetworkImage(
          fallBackIcon: RadioFallBackIcon(
            station: station,
          ),
          errorIcon: RadioFallBackIcon(station: station),
          url: station?.imageUrl,
        ),
      ),
    );
  }

  void onTap(BuildContext context, Audio station) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          final starred = isStarredStation(
            station.title ?? station.toString(),
          );
          return StationPage(
            onTextTap: (v) {
              onTextTap?.call(v);
              Navigator.of(context).maybePop();
            },
            station: station,
            name: station.title ?? station.toString(),
            unStarStation: (s) => unstarStation(
              station.title ?? station.toString(),
            ),
            starStation: (s) => starStation(
              station.title ?? station.toString(),
              {station},
            ),
            play: play,
            isStarred: starred,
          );
        },
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
          YaruIcons.radio,
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
        YaruIcons.media_play,
        color: theme.primaryColor,
      );
    }

    return selected
        ? const Icon(YaruIcons.radio_filled)
        : const Icon(YaruIcons.radio);
  }
}
