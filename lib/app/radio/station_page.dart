import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_card.dart';
import 'package:musicpod/app/common/audio_page_control_panel.dart';
import 'package:musicpod/app/common/audio_page_header.dart';
import 'package:musicpod/app/common/constants.dart';
import 'package:musicpod/app/common/safe_network_image.dart';
import 'package:musicpod/app/local_audio/album_view.dart';
import 'package:musicpod/app/radio/radio_page.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class StationPage extends StatelessWidget {
  const StationPage({
    super.key,
    required this.station,
    this.onPlay,
    required this.name,
    required this.unStarStation,
    required this.starStation,
    this.onTextTap,
    required this.isStarred,
    required this.showWindowControls,
  });

  final Audio station;
  final String name;
  final void Function(Audio? audio)? onPlay;
  final void Function(String station) unStarStation;
  final void Function(String station) starStation;
  final bool isStarred;
  final bool showWindowControls;

  final void Function(String text)? onTextTap;

  static Widget createIcon({
    required BuildContext context,
    required String? imageUrl,
    required bool selected,
    required bool isOnline,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: SizedBox(
        height: kSideBarIconSize,
        width: kSideBarIconSize,
        child: isOnline
            ? SafeNetworkImage(
                fallBackIcon: selected
                    ? const Icon(
                        YaruIcons.star_filled,
                      )
                    : const Icon(
                        YaruIcons.star,
                      ),
                errorIcon: selected
                    ? const Icon(
                        YaruIcons.star_filled,
                      )
                    : const Icon(
                        YaruIcons.star,
                      ),
                fit: BoxFit.fitHeight,
                url: imageUrl,
                filterQuality: FilterQuality.medium,
              )
            : const Icon(YaruIcons.network_offline),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tags = <String>[
      for (final tag in station.album?.split(',') ?? <String>[]) tag
    ];
    const size = 350.0;
    return YaruDetailPage(
      backgroundColor: theme.brightness == Brightness.dark
          ? kBackgroundDark
          : kBackGroundLight,
      appBar: YaruWindowTitleBar(
        style: showWindowControls
            ? YaruTitleBarStyle.normal
            : YaruTitleBarStyle.undecorated,
        title: Text(name.replaceAll('_', '')),
        leading: Navigator.canPop(context)
            ? const YaruBackButton(
                style: YaruBackButtonStyle.rounded,
              )
            : const SizedBox(
                width: 40,
              ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: size,
                  width: size,
                  child: AudioCard(
                    bottom: station.imageUrl == null
                        ? AudioCardBottom(text: name)
                        : null,
                    onTap: () => onPlay?.call(station),
                    onPlay: () => onPlay?.call(station),
                    image: SizedBox(
                      height: size,
                      width: size,
                      child: SafeNetworkImage(
                        fallBackIcon: RadioFallBackIcon(
                          iconSize: size / 2,
                          station: station,
                        ),
                        url: station.imageUrl,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: size * 0.95,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: theme.primaryColor,
                            child: IconButton(
                              onPressed: isStarred
                                  ? () => unStarStation(name)
                                  : () => starStation(name),
                              icon: Icon(
                                isStarred
                                    ? YaruIcons.star_filled
                                    : YaruIcons.star,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(
                              station.title?.replaceAll('_', '') ?? '',
                              style: theme.textTheme.headlineSmall,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      YaruChoiceChipBar(
                        yaruChoiceChipBarStyle: YaruChoiceChipBarStyle.stack,
                        labels: tags.map((e) => Text(e)).toList(),
                        isSelected: tags.map((e) => false).toList(),
                        onSelected: (index) {
                          onTextTap?.call(tags[index]);
                          if (Navigator.canPop(context)) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SimpleStationPage extends StatelessWidget {
  const SimpleStationPage({
    super.key,
    required this.station,
    this.onPlay,
    required this.name,
    required this.unStarStation,
    required this.starStation,
    this.onTextTap,
    required this.isStarred,
    required this.showWindowControls,
  });

  final Audio station;
  final String name;
  final void Function(Audio? audio)? onPlay;
  final void Function(String station) unStarStation;
  final void Function(String station) starStation;
  final bool isStarred;
  final bool showWindowControls;

  final void Function(String text)? onTextTap;

  static Widget createIcon({
    required BuildContext context,
    required Audio station,
    required bool selected,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: SizedBox(
        height: kSideBarIconSize,
        width: kSideBarIconSize,
        child: SafeNetworkImage(
          fallBackIcon: selected
              ? const Icon(
                  YaruIcons.star_filled,
                )
              : const Icon(
                  YaruIcons.star,
                ),
          errorIcon: selected
              ? const Icon(
                  YaruIcons.star_filled,
                )
              : const Icon(
                  YaruIcons.star,
                ),
          fit: BoxFit.fitHeight,
          url: station.imageUrl,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final tags = <String>[
      for (final tag in station.album?.split(',') ?? <String>[]) tag
    ];
    var yaruChoiceChipBar = YaruChoiceChipBar(
      yaruChoiceChipBarStyle: YaruChoiceChipBarStyle.wrap,
      labels: tags.map((e) => Text(e)).toList(),
      isSelected: tags.map((e) => false).toList(),
      onSelected: (index) {
        onTextTap?.call(tags[index]);
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      },
    );

    return YaruDetailPage(
      appBar: YaruWindowTitleBar(
        title: Text(name),
        style: showWindowControls
            ? YaruTitleBarStyle.normal
            : YaruTitleBarStyle.undecorated,
      ),
      body: Column(
        children: [
          AudioPageHeader(
            title: name,
            label: context.l10n.station,
            subTitle: station.artist,
            image: SizedBox(
              width: 200,
              height: 200,
              child: SafeNetworkImage(
                url: station.imageUrl,
                fit: BoxFit.fitWidth,
                fallBackIcon: RadioFallBackIcon(station: station),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 30),
            child: AudioPageControlPanel(
              audios: {station},
              pinButton: YaruIconButton(
                icon: Icon(
                  isStarred ? YaruIcons.star_filled : YaruIcons.star,
                  color: theme.primaryColor,
                ),
                onPressed: () =>
                    isStarred ? unStarStation(name) : starStation(name),
              ),
              listName: name,
              isPlaying: true,
              editableName: false,
              startPlaylist: (audios, listName) => onPlay?.call(station),
              pause: () => onPlay?.call(station),
              resume: () {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25),
            child: Row(
              children: [
                Text(
                  context.l10n.tags,
                  style: const TextStyle(
                    fontWeight: FontWeight.w100,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 10, bottom: 20),
            child: Divider(
              height: 0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: yaruChoiceChipBar,
            ),
          )
        ],
      ),
    );
  }
}
