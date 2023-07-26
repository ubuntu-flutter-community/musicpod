import 'package:flutter/material.dart';
import 'package:musicpod/app/app_model.dart';
import 'package:musicpod/app/common/audio_card.dart';
import 'package:musicpod/app/common/constants.dart';
import 'package:musicpod/app/common/country_popup.dart';
import 'package:musicpod/app/common/offline_page.dart';
import 'package:musicpod/app/common/safe_network_image.dart';
import 'package:musicpod/app/library_model.dart';
import 'package:musicpod/app/local_audio/album_view.dart';
import 'package:musicpod/app/player/player_model.dart';
import 'package:musicpod/app/radio/radio_model.dart';
import 'package:musicpod/app/radio/station_page.dart';
import 'package:musicpod/app/radio/tag_popup.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/service/radio_service.dart';
import 'package:provider/provider.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class RadioPage extends StatefulWidget {
  const RadioPage({
    super.key,
    this.onTextTap,
    required this.isOnline,
  });

  final void Function(String text)? onTextTap;
  final bool isOnline;

  static Widget create({
    required BuildContext context,
    required bool isOnline,
  }) {
    return ChangeNotifierProvider(
      create: (_) => RadioModel(getService<RadioService>()),
      child: RadioPage(
        isOnline: isOnline,
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
    final stations = context.select((RadioModel m) => m.stations);
    final stationsCount = context.select((RadioModel m) => m.stations?.length);
    final search = context.read<RadioModel>().search;
    final searchQuery = context.select((RadioModel m) => m.searchQuery);
    final setSearchQuery = context.read<RadioModel>().setSearchQuery;
    final country = context.select((RadioModel m) => m.country);
    final sortedCountries = context.select((RadioModel m) => m.sortedCountries);
    final setCountry = context.read<RadioModel>().setCountry;
    final loadStationsByCountry =
        context.read<RadioModel>().loadStationsByCountry;
    final tag = context.select((RadioModel m) => m.tag);
    final setTag = context.read<RadioModel>().setTag;
    final tags = context.select((RadioModel m) => m.tags);
    final loadStationsByTag = context.read<RadioModel>().loadStationsByTag;

    final play = context.select((PlayerModel m) => m.play);

    final starStation = context.select((LibraryModel m) => m.addStarredStation);
    final unstarStation = context.select((LibraryModel m) => m.unStarStation);
    final isStarredStation = context.read<LibraryModel>().isStarredStation;

    final searchActive = context.select((RadioModel m) => m.searchActive);
    final setSearchActive = context.read<RadioModel>().setSearchActive;

    final theme = Theme.of(context);
    final light = theme.brightness == Brightness.light;

    final showWindowControls =
        context.select((AppModel a) => a.showWindowControls);

    final controlPanel = SizedBox(
      height: kHeaderBarItemHeight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CountryPopup(
            value: country,
            onSelected: (country) {
              setCountry(country);
              loadStationsByCountry();
            },
            countries: sortedCountries,
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
    );

    if (!widget.isOnline) {
      return const OfflinePage();
    } else {
      return YaruDetailPage(
        backgroundColor: light ? kBackGroundLight : kBackgroundDark,
        appBar: YaruWindowTitleBar(
          backgroundColor: Colors.transparent,
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
              width: kSearchBarWidth,
              title: controlPanel,
              searchActive: searchActive,
              onSearchActive: () => setSearchActive(!searchActive),
              onClear: () => setSearchActive(false),
              text: searchQuery,
              onSubmitted: (value) {
                setSearchQuery(value);
                search(name: value);
              },
            ),
          ),
        ),
        body: GridView.builder(
          padding: kPodcastGridPadding,
          gridDelegate: kImageGridDelegate,
          itemCount: stationsCount,
          itemBuilder: (context, index) {
            final station = stations?.elementAt(index);
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
        ),
      );
    }
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
  final Future<void> Function({bool bigPlay, Audio? newAudio}) play;
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
            onTextTap: onTextTap,
            station: station,
            name: station.title ?? station.toString(),
            unStarStation: (s) => unstarStation(
              station.title ?? station.toString(),
            ),
            starStation: (s) => starStation(
              station.title ?? station.toString(),
              {station},
            ),
            onPlay: (audio) => play(newAudio: station),
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
            ).withOpacity(0.9)
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
