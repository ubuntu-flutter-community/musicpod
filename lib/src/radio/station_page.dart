import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';

import '../../app.dart';
import '../../build_context_x.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../globals.dart';
import '../../l10n.dart';
import '../../library.dart';
import '../../player.dart';
import '../../radio.dart';
import '../../theme.dart';
import '../../theme_data_x.dart';
import 'radio_fall_back_icon.dart';
import 'radio_history_list.dart';

class StationPage extends ConsumerWidget {
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        color: context.t.isLight ? kCardColorLight : kCardColorDark,
        height: sideBarImageSize,
        width: sideBarImageSize,
        child: SafeNetworkImage(
          fallBackIcon: SideBarFallBackImage(
            child: selected
                ? Icon(Iconz().starFilled)
                : Icon(
                    Iconz().star,
                  ),
          ),
          errorIcon: SideBarFallBackImage(
            child: selected
                ? Icon(Iconz().imageMissingFilled)
                : Icon(
                    Iconz().imageMissing,
                  ),
          ),
          fit: BoxFit.fitHeight,
          url: imageUrl,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appModel = ref.read(appModelProvider);
    final isOnline =
        ref.watch(appModelProvider.select((value) => value.isOnline));
    if (!isOnline) return const OfflinePage();

    final radioModel = ref.read(radioModelProvider);
    final tags = station.album?.isNotEmpty == false
        ? null
        : <String>[
            for (final tag in station.album?.split(',') ?? <String>[]) tag,
          ];
    const size = fullHeightPlayerImageSize - 20;

    final showWindowControls =
        ref.watch(appModelProvider.select((m) => m.showWindowControls));
    final playerModel = ref.read(playerModelProvider);
    final libraryModel = ref.read(libraryModelProvider);
    final isStarred = station.url == null
        ? false
        : libraryModel.isStarredStation(station.url!);
    ref.watch(libraryModelProvider.select((m) => m.starredStations.length));
    final isAudioStation = ref.watch(
      playerModelProvider.select((v) => v.audio == station),
    );
    final isPlaying = ref.watch(playerModelProvider.select((v) => v.isPlaying));

    final body = Column(
      children: [
        AudioPageHeader(
          padding: const EdgeInsets.only(
            left: kYaruPagePadding,
            bottom: kYaruPagePadding,
          ),
          height: kMaxAudioPageHeaderHeight,
          title: name,
          subTitle: '',
          label: '',
          image: SafeNetworkImage(
            fallBackIcon: RadioFallBackIcon(
              iconSize: size / 2,
              station: station,
            ),
            url: station.imageUrl,
            fit: BoxFit.scaleDown,
            width: size,
            height: size,
          ),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AudioPageHeaderTitle(title: station.title ?? ''),
              const SizedBox(
                height: 5,
              ),
              AudioPageHeaderSubTitle(
                label: context.l10n.station,
                subTitle: station.artist,
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: _createTagBar(
                  tags: tags,
                  radioModel: radioModel,
                  libraryModel: libraryModel,
                  appModel: appModel,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: kAudioControlPanelPadding,
          child: AudioPageControlPanel(
            audios: {station},
            controlButton: Padding(
              padding: const EdgeInsets.only(left: 5),
              child: IconButton(
                tooltip: isStarred
                    ? context.l10n.removeFromCollection
                    : context.l10n.addToCollection,
                onPressed: station.url == null
                    ? null
                    : isStarred
                        ? () => unStarStation(station.url!)
                        : () => starStation(station.url!),
                icon: Iconz().getAnimatedStar(
                  isStarred,
                ),
              ),
            ),
            icon: isPlaying && isAudioStation ? Iconz().pause : Iconz().play,
            onTap: station.url == null
                ? null
                : () {
                    if (isPlaying) {
                      if (isAudioStation) {
                        playerModel.pause();
                      } else {
                        playerModel.startPlaylist(
                          audios: {station},
                          listName: station.url!,
                        );
                      }
                    } else {
                      if (isAudioStation) {
                        playerModel.resume();
                      } else {
                        playerModel.startPlaylist(
                          audios: {station},
                          listName: station.url!,
                        );
                      }
                    }
                  },
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Expanded(
          child: RadioHistoryList(
            filter: station.title,
            emptyMessage: const SizedBox.shrink(),
            emptyIcon: const SizedBox.shrink(),
            padding: radioHistoryListPadding,
          ),
        ),
      ],
    );

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
      body: body,
    );
  }

  Widget _createTagBar({
    required List<String>? tags,
    required RadioModel radioModel,
    required LibraryModel libraryModel,
    required AppModel appModel,
  }) {
    if (tags == null || tags.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(right: kYaruPagePadding),
      child: YaruChoiceChipBar(
        goNextIcon: Padding(
          padding:
              appleStyled ? const EdgeInsets.only(left: 3) : EdgeInsets.zero,
          child: Icon(Iconz().goNext),
        ),
        goPreviousIcon: Padding(
          padding:
              appleStyled ? const EdgeInsets.only(right: 3) : EdgeInsets.zero,
          child: Icon(Iconz().goBack),
        ),
        chipHeight: chipHeight,
        yaruChoiceChipBarStyle: YaruChoiceChipBarStyle.wrap,
        labels: tags.map((e) => Text(e)).toList(),
        isSelected: tags.map((e) => false).toList(),
        clearOnSelect: false,
        onSelected: (index) {
          radioModel
              .init(
                countryCode: appModel.countryCode,
                index: libraryModel.radioindex,
              )
              .then(
                (_) => navigatorKey.currentState?.push(
                  MaterialPageRoute(
                    builder: (context) {
                      return RadioSearchPage(
                        radioSearch: RadioSearch.tag,
                        searchQuery: tags[index],
                      );
                    },
                  ),
                ),
              );
        },
      ),
    );
  }
}
