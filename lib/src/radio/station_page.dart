import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'radio_fall_back_icon.dart';
import 'radio_history_list.dart';

class StationPage extends ConsumerWidget {
  const StationPage({
    super.key,
    required this.station,
  });

  final Audio station;

  static Widget createIcon({
    required BuildContext context,
    required String? imageUrl,
    required bool selected,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        color: context.t.cardColor,
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
    final isOnline =
        ref.watch(appModelProvider.select((value) => value.isOnline));
    if (!isOnline) return const OfflinePage();

    final tags = station.album?.isNotEmpty == false
        ? null
        : <String>[
            for (final tag in station.album?.split(',') ?? <String>[]) tag,
          ];
    const size = fullHeightPlayerImageSize - 20;

    final showWindowControls =
        ref.watch(appModelProvider.select((m) => m.showWindowControls));
    final playerModel = ref.read(playerModelProvider);

    ref.watch(libraryModelProvider.select((m) => m.starredStations.length));
    final isAudioStation = ref.watch(
      playerModelProvider.select((v) => v.audio == station),
    );
    final isPlaying = ref.watch(playerModelProvider.select((v) => v.isPlaying));

    final body = AdaptiveContainer(
      child: Column(
        children: [
          AudioPageHeader(
            padding: const EdgeInsets.only(
              left: kYaruPagePadding,
              bottom: kYaruPagePadding,
            ),
            title: station.title ?? station.url ?? '',
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
                if (tags != null)
                  Expanded(
                    child: _RadioPageTagBar(tags),
                  ),
              ],
            ),
          ),
          Padding(
            padding: kAudioControlPanelPadding,
            child: AudioPageControlPanel(
              audios: {station},
              controlButton: _RadioPageControlButton(station: station),
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
      ),
    );

    return YaruDetailPage(
      appBar: HeaderBar(
        style: showWindowControls
            ? YaruTitleBarStyle.normal
            : YaruTitleBarStyle.undecorated,
        title: Text(station.title ?? station.url ?? ''),
        leading: Navigator.canPop(context)
            ? const NavBackButton()
            : const SizedBox.shrink(),
      ),
      body: body,
    );
  }
}

class _RadioPageTagBar extends StatelessWidget {
  const _RadioPageTagBar(this.tags);

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return const SizedBox.shrink();

    return Consumer(
      builder: (context, ref, _) {
        final radioModel = ref.read(radioModelProvider);
        final libraryModel = ref.read(libraryModelProvider);
        final appModel = ref.read(appModelProvider);
        return SingleChildScrollView(
          padding: const EdgeInsets.only(right: kYaruPagePadding),
          child: YaruChoiceChipBar(
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
      },
    );
  }
}

class _RadioPageControlButton extends StatelessWidget {
  const _RadioPageControlButton({
    required this.station,
  });

  final Audio station;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final libraryModel = ref.read(libraryModelProvider);
        final isStarred = libraryModel.isStarredStation(station.url!);

        return Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: libraryModel.isStarredStation(station.url!)
                    ? context.l10n.removeFromCollection
                    : context.l10n.addToCollection,
                onPressed: station.url == null
                    ? null
                    : isStarred
                        ? () => libraryModel.unStarStation(station.url!)
                        : () => libraryModel
                            .addStarredStation(station.url!, {station}),
                icon: Iconz().getAnimatedStar(
                  isStarred,
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              IconButton(
                tooltip: context.l10n.copyToClipBoard,
                onPressed: () {
                  final text = ref.read(libraryModelProvider).radioHistoryList;
                  Clipboard.setData(
                    ClipboardData(
                      text: text,
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: CopyClipboardContent(
                        text: text,
                        showActions: false,
                      ),
                    ),
                  );
                },
                icon: Icon(Iconz().copy),
              ),
            ],
          ),
        );
      },
    );
  }
}
