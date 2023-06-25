import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_card.dart';
import 'package:musicpod/app/common/constants.dart';
import 'package:musicpod/app/common/safe_network_image.dart';
import 'package:musicpod/app/local_audio/album_view.dart';
import 'package:musicpod/app/radio/radio_page.dart';
import 'package:musicpod/data/audio.dart';
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
    required Audio station,
    required bool selected,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: SizedBox(
        height: 23,
        width: 23,
        child: SafeNetworkImage(
          fallBackIcon: selected
              ? const Icon(YaruIcons.star_filled)
              : const Icon(YaruIcons.star),
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
    const size = 350.0;
    return YaruDetailPage(
      backgroundColor: theme.brightness == Brightness.dark
          ? kBackgroundDark
          : kBackGroundLight,
      appBar: YaruWindowTitleBar(
        style: showWindowControls
            ? YaruTitleBarStyle.normal
            : YaruTitleBarStyle.undecorated,
        title: Text(name),
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
                        fallBackIcon: const RadioFallBackIcon(
                          iconSize: size / 2,
                        ),
                        url: station.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
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
                              station.title ?? '',
                              style: theme.textTheme.headlineSmall,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      YaruChoiceChipBar(
                        yaruChoiceChipBarStyle: YaruChoiceChipBarStyle.wrap,
                        labels: tags.map((e) => Text(e)).toList(),
                        isSelected: tags.map((e) => false).toList(),
                        onSelected: (index) {
                          onTextTap?.call(tags[index]);
                          if (Navigator.canPop(context)) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
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
