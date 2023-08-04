import 'package:flutter/material.dart';
import 'package:musicpod/app/app_model.dart';
import 'package:musicpod/app/common/audio_card.dart';
import 'package:musicpod/constants.dart';
import 'package:musicpod/app/common/safe_network_image.dart';
import 'package:musicpod/app/local_audio/album_view.dart';
import 'package:musicpod/app/radio/radio_page.dart';
import 'package:musicpod/data/audio.dart';
import 'package:provider/provider.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class StationPage extends StatelessWidget {
  const StationPage({
    super.key,
    required this.station,
    required this.play,
    required this.name,
    required this.unStarStation,
    required this.starStation,
    this.onTextTap,
    required this.isStarred,
  });

  final Audio station;
  final String name;
  final Future<void> Function({bool bigPlay, Audio? newAudio}) play;
  final void Function(String station) unStarStation;
  final void Function(String station) starStation;
  final bool isStarred;

  final void Function(String text)? onTextTap;

  static Widget createIcon({
    required BuildContext context,
    required String? imageUrl,
    required bool selected,
    required bool isOnline,
    required bool enabled,
  }) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: ClipRRect(
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

    final showWindowControls =
        context.select((AppModel a) => a.showWindowControls);

    return YaruDetailPage(
      backgroundColor: theme.brightness == Brightness.dark
          ? kBackgroundDark
          : kBackGroundLight,
      appBar: YaruWindowTitleBar(
        backgroundColor: Colors.transparent,
        border: BorderSide.none,
        style: showWindowControls
            ? YaruTitleBarStyle.normal
            : YaruTitleBarStyle.undecorated,
        title: Text(name.replaceAll('_', '')),
        leading: Navigator.canPop(context)
            ? const YaruBackButton(
                style: YaruBackButtonStyle.rounded,
              )
            : const SizedBox.shrink(),
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
                    onTap: () => play(newAudio: station),
                    onPlay: () => play(newAudio: station),
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
                              icon: YaruAnimatedIcon(
                                isStarred
                                    ? const YaruAnimatedStarIcon(filled: true)
                                    : const YaruAnimatedStarIcon(filled: false),
                                initialProgress: 1.0,
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
