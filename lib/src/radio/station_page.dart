import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../app.dart';
import '../../common.dart';
import '../../data.dart';
import '../common/common_widgets.dart';
import '../common/icons.dart';
import 'radio_page.dart';

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
  final Future<void> Function({Duration? newPosition, Audio? newAudio}) play;
  final void Function(String station) unStarStation;
  final void Function(String station) starStation;
  final bool isStarred;

  final void Function(String text)? onTextTap;

  static Widget createIcon({
    required BuildContext context,
    required String? imageUrl,
    required bool selected,
    required bool isOnline,
  }) {
    if (!isOnline) {
      return Icon(Iconz().offline);
    }

    final icon = selected
        ? Icon(
            Iconz().starFilled,
          )
        : Icon(
            Iconz().starFilled,
          );
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: SizedBox(
        height: iconSize(),
        width: iconSize(),
        child: SafeNetworkImage(
          fallBackIcon: icon,
          errorIcon: icon,
          fit: BoxFit.fitHeight,
          url: imageUrl,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tags = station.album?.isNotEmpty == false
        ? null
        : <String>[
            for (final tag in station.album?.split(',') ?? <String>[]) tag,
          ];
    const size = 350.0;

    final showWindowControls =
        context.select((AppModel a) => a.showWindowControls);

    return YaruDetailPage(
      appBar: YaruWindowTitleBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        border: BorderSide.none,
        style: showWindowControls
            ? YaruTitleBarStyle.normal
            : YaruTitleBarStyle.undecorated,
        title: Text(name.replaceAll('_', '')),
        leading: Navigator.canPop(context)
            ? const NavBackButton()
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
                    height: size,
                    width: size,
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
                        fit: BoxFit.scaleDown,
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
                            radius: Iconz().avatarIconSize,
                            backgroundColor: theme.primaryColor,
                            child: IconButton(
                              onPressed: isStarred
                                  ? () => unStarStation(name)
                                  : () => starStation(name),
                              icon: Iconz().getAnimatedStar(
                                isStarred,
                                theme.colorScheme.onPrimary,
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
                      if (tags?.isNotEmpty == true)
                        YaruChoiceChipBar(
                          yaruChoiceChipBarStyle: YaruChoiceChipBarStyle.stack,
                          labels: tags!.map((e) => Text(e)).toList(),
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
