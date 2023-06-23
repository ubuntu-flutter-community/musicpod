import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_card.dart';
import 'package:musicpod/app/common/constants.dart';
import 'package:musicpod/app/common/safe_network_image.dart';
import 'package:musicpod/app/local_audio/album_view.dart';
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
    this.onTextTap,
  });

  final Audio station;
  final String name;
  final void Function(Audio? audio)? onPlay;
  final void Function(String station) unStarStation;
  final void Function(String text)? onTextTap;

  static Widget createIcon({
    required BuildContext context,
    required Audio station,
    required bool selected,
  }) {
    return station.imageUrl == null
        ? (selected
            ? const Icon(YaruIcons.star_filled)
            : const Icon(YaruIcons.star))
        : ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: SizedBox(
              height: 23,
              child: SafeNetworkImage(
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
    return YaruDetailPage(
      backgroundColor: theme.brightness == Brightness.dark
          ? kBackgroundDark
          : kBackGroundLight,
      appBar: YaruWindowTitleBar(
        title: Text(name),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 400,
                  width: 400,
                  child: AudioCard(
                    bottom: station.imageUrl == null
                        ? AudioCardBottom(text: name)
                        : null,
                    onTap: () => onPlay?.call(station),
                    onPlay: () => onPlay?.call(station),
                    image: SizedBox(
                      height: 400,
                      width: 400,
                      child: SafeNetworkImage(
                        fallBackIcon: Icon(
                          YaruIcons.radio,
                          color: theme.hintColor,
                          size: 200,
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
                  width: 380,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: theme.primaryColor,
                            child: IconButton(
                              onPressed: () => unStarStation(name),
                              icon: Icon(
                                YaruIcons.star_filled,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            station.title ?? '',
                            style: theme.textTheme.headlineSmall,
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
                        onSelected: (index) => onTextTap?.call(tags[index]),
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
