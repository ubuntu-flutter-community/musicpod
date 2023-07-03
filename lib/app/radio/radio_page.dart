import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_card.dart';
import 'package:musicpod/app/common/constants.dart';
import 'package:musicpod/app/common/country_popup.dart';
import 'package:musicpod/app/common/offline_page.dart';
import 'package:musicpod/app/common/safe_network_image.dart';
import 'package:musicpod/app/common/search_field.dart';
import 'package:musicpod/app/library_model.dart';
import 'package:musicpod/app/local_audio/album_view.dart';
import 'package:musicpod/app/player/player_model.dart';
import 'package:musicpod/app/radio/radio_model.dart';
import 'package:musicpod/app/radio/station_page.dart';
import 'package:musicpod/app/radio/tag_popup.dart';
import 'package:musicpod/service/radio_service.dart';
import 'package:provider/provider.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class RadioPage extends StatefulWidget {
  const RadioPage({
    super.key,
    this.showWindowControls = true,
    this.onTextTap,
    required this.isOnline,
  });

  final bool showWindowControls;
  final void Function(String text)? onTextTap;
  final bool isOnline;

  static Widget create({
    required BuildContext context,
    bool showWindowControls = true,
    required bool isOnline,
  }) {
    return ChangeNotifierProvider(
      create: (_) => RadioModel(getService<RadioService>()),
      child: RadioPage(
        showWindowControls: showWindowControls,
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

    final controlPanel = SizedBox(
      height: kHeaderBarItemHeight,
      child: Row(
        mainAxisSize: MainAxisSize.max,
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
          style: widget.showWindowControls
              ? YaruTitleBarStyle.normal
              : YaruTitleBarStyle.undecorated,
          titleSpacing: 0,
          leading: Center(
            child: SizedBox(
              height: kHeaderBarItemHeight,
              width: kHeaderBarItemHeight,
              child: YaruIconButton(
                isSelected: searchActive,
                selectedIcon: Icon(
                  YaruIcons.search,
                  size: 16,
                  color: theme.colorScheme.onSurface,
                ),
                icon: const Icon(
                  YaruIcons.search,
                  size: 16,
                ),
                onPressed: () => setSearchActive(!searchActive),
              ),
            ),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (searchActive)
                Expanded(
                  child: SearchField(
                    onSearchActive: () => setSearchActive(false),
                    text: searchQuery,
                    onSubmitted: (value) {
                      setSearchQuery(value);
                      search(name: value);
                    },
                  ),
                ),
              controlPanel
            ],
          ),
        ),
        body: GridView.builder(
          padding: kPodcastGridPadding,
          gridDelegate: kImageGridDelegate,
          itemCount: stationsCount,
          itemBuilder: (context, index) {
            final station = stations?.elementAt(index);
            return AudioCard(
              bottom: AudioCardBottom(text: station?.title ?? ''),
              onPlay: () => play(newAudio: station),
              onTap: station == null
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            final starred = isStarredStation(
                              station.title ?? station.toString(),
                            );
                            return StationPage(
                              showWindowControls: widget.showWindowControls,
                              onTextTap: widget.onTextTap,
                              station: station,
                              name: station.title ?? station.toString(),
                              unStarStation: (s) => unstarStation(
                                station.title ?? station.toString(),
                              ),
                              starStation: (s) => starStation(
                                station.title!,
                                {station},
                              ),
                              onPlay: (audio) => play(newAudio: station),
                              isStarred: starred,
                            );
                          },
                        ),
                      );
                    },
              image: SizedBox.expand(
                child: SafeNetworkImage(
                  fit: BoxFit.cover,
                  fallBackIcon: const RadioFallBackIcon(),
                  url: station?.imageUrl,
                ),
              ),
            );
          },
        ),
      );
    }
  }
}

class RadioFallBackIcon extends StatelessWidget {
  const RadioFallBackIcon({
    super.key,
    this.iconSize,
  });

  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            theme.primaryColor.withOpacity(0.3),
            theme.primaryColor.withOpacity(0.7)
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Icon(
          YaruIcons.radio,
          size: iconSize ?? 70,
          color: contrastColor(theme.colorScheme.background).withOpacity(0.5),
        ),
      ),
    );
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
