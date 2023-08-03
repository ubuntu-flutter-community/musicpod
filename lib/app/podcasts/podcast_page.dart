import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_page.dart';
import 'package:musicpod/constants.dart';
import 'package:musicpod/app/common/safe_network_image.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class PodcastPage extends StatelessWidget {
  const PodcastPage({
    super.key,
    this.onAlbumTap,
    this.onArtistTap,
    this.imageUrl,
    required this.pageId,
    this.audios,
    this.subscribed = true,
    required this.removePodcast,
    required this.addPodcast,
  });

  static Widget createIcon({
    required BuildContext context,
    String? imageUrl,
    required bool isOnline,
    required bool enabled,
  }) {
    var clipRRect = isOnline
        ? ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: SizedBox(
              width: kSideBarIconSize,
              height: kSideBarIconSize,
              child: isOnline
                  ? SafeNetworkImage(
                      url: imageUrl,
                      fit: BoxFit.fitHeight,
                      filterQuality: FilterQuality.medium,
                      fallBackIcon: const Icon(
                        YaruIcons.rss,
                        size: kSideBarIconSize,
                      ),
                      errorIcon: const Icon(
                        YaruIcons.rss,
                        size: kSideBarIconSize,
                      ),
                    )
                  : const Icon(YaruIcons.network_offline),
            ),
          )
        : const Icon(
            YaruIcons.network_offline,
          );
    return enabled
        ? clipRRect
        : Opacity(
            opacity: 0.5,
            child: clipRRect,
          );
  }

  static Widget createTitle({
    required bool enabled,
    required String title,
  }) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Text(title),
    );
  }

  final void Function(String name) removePodcast;
  final void Function(String name, Set<Audio> audios) addPodcast;
  final void Function(String)? onAlbumTap;
  final void Function(String)? onArtistTap;
  final String? imageUrl;
  final String pageId;
  final Set<Audio>? audios;
  final bool subscribed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AudioPage(
      showAudioTileHeader: false,
      sort: false,
      onAlbumTap: onAlbumTap,
      onArtistTap: onArtistTap,
      audioPageType: AudioPageType.podcast,
      image: imageUrl == null
          ? null
          : SafeNetworkImage(
              fallBackIcon: Icon(
                YaruIcons.podcast,
                size: 80,
                color: Theme.of(context).hintColor,
              ),
              errorIcon: Icon(
                YaruIcons.podcast,
                size: 80,
                color: Theme.of(context).hintColor,
              ),
              url: imageUrl,
              fit: BoxFit.fitWidth,
              filterQuality: FilterQuality.medium,
            ),
      pageLabel: context.l10n.podcast,
      pageTitle: pageId,
      pageSubtile: audios?.firstOrNull?.artist,
      audios: audios,
      pageId: pageId,
      showTrack: false,
      editableName: false,
      deletable: false,
      controlPageButton: YaruIconButton(
        icon: Icon(
          YaruIcons.rss,
          color: subscribed ? theme.primaryColor : theme.colorScheme.onSurface,
        ),
        onPressed: () {
          if (subscribed) {
            removePodcast(pageId);
          } else if (audios?.isNotEmpty == true) {
            addPodcast(pageId, audios!);
          }
        },
      ),
    );
  }
}
