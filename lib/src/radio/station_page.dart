import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../app.dart';
import '../../build_context_x.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../globals.dart';
import '../../library.dart';
import '../../player.dart';
import '../../theme.dart';
import '../../theme_data_x.dart';
import 'radio_fall_back_icon.dart';
import 'radio_search.dart';
import 'radio_search_page.dart';

class StationPage extends StatelessWidget {
  const StationPage({
    super.key,
    required this.station,
    required this.name,
    required this.unStarStation,
    required this.starStation,
  });

  final Audio station;
  final String name;
  final void Function(String station) unStarStation;
  final void Function(String station) starStation;

  static Widget createIcon({
    required BuildContext context,
    required String? imageUrl,
    required bool selected,
  }) {
    final icon = selected
        ? Icon(
            Iconz().starFilled,
            size: sideBarImageSize,
          )
        : Icon(
            Iconz().star,
            size: sideBarImageSize,
          );

    if (imageUrl == null) {
      return SideBarFallBackImage(
        child: selected ? Icon(Iconz().starFilled) : Icon(Iconz().star),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Container(
        color: kCardColorNeutral,
        height: sideBarImageSize,
        width: sideBarImageSize,
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
    final theme = context.t;
    final tags = station.album?.isNotEmpty == false
        ? null
        : <String>[
            for (final tag in station.album?.split(',') ?? <String>[]) tag,
          ];
    const size = fullHeightPlayerImageSize - 20;

    final showWindowControls =
        context.select((AppModel a) => a.showWindowControls);
    final startPlaylist = context.read<PlayerModel>().startPlaylist;
    final libraryModel = context.read<LibraryModel>();
    final isStarred = station.url == null
        ? false
        : libraryModel.isStarredStation(station.url!);
    context.select((LibraryModel m) => m.starredStations.length);

    return YaruDetailPage(
      appBar: HeaderBar(
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
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Center(
            child: SizedBox(
              width: size,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 5,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Tooltip(
                            message:
                                station.title?.replaceAll('_', '').trim() ?? '',
                            child: Text(
                              station.title?.replaceAll('_', '').trim() ?? '',
                              style: theme.textTheme.bodyLarge,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: station.url == null
                              ? null
                              : isStarred
                                  ? () => unStarStation(station.url!)
                                  : () => starStation(station.url!),
                          icon: Iconz().getAnimatedStar(
                            isStarred,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AudioCard(
                    color: theme.isLight ? theme.dividerColor : kCardColorDark,
                    height: size,
                    width: size,
                    onTap: () => startPlaylist(
                      listName: station.toShortPath(),
                      audios: {station},
                    ),
                    onPlay: () => startPlaylist(
                      listName: station.toShortPath(),
                      audios: {station},
                    ),
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
                        width: size,
                        height: size,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 15,
                        left: 5,
                        right: 5,
                      ),
                      child: (tags?.isNotEmpty == true)
                          ? YaruChoiceChipBar(
                              goNextIcon: Padding(
                                padding: appleStyled
                                    ? const EdgeInsets.only(left: 3)
                                    : EdgeInsets.zero,
                                child: Icon(Iconz().goNext),
                              ),
                              goPreviousIcon: Padding(
                                padding: appleStyled
                                    ? const EdgeInsets.only(right: 3)
                                    : EdgeInsets.zero,
                                child: Icon(Iconz().goBack),
                              ),
                              chipHeight: chipHeight,
                              yaruChoiceChipBarStyle:
                                  YaruChoiceChipBarStyle.stack,
                              shrinkWrap: false,
                              labels: tags!.map((e) => Text(e)).toList(),
                              isSelected: tags.map((e) => false).toList(),
                              onSelected: (index) {
                                navigatorKey.currentState?.push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return RadioSearchPage(
                                        radioSearch: RadioSearch.tag,
                                        searchQuery: tags[index],
                                      );
                                    },
                                  ),
                                );
                              },
                            )
                          : SizedBox(
                              height: chipHeight,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
