import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_page.dart';
import 'package:musicpod/app/common/safe_network_image.dart';
import 'package:musicpod/app/library_model.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class PodcastPage extends StatelessWidget {
  const PodcastPage({
    super.key,
    this.onTextTap,
    this.imageUrl,
    required this.pageId,
    this.audios,
    this.subscribed = true,
    required this.removePodcast,
    required this.addPodcast,
    required this.title,
    required this.removePodcastUpdate,
  });

  static Widget createIcon({
    required BuildContext context,
    String? imageUrl,
    required bool isOnline,
  }) {
    if (!isOnline) {
      return const Icon(YaruIcons.network_offline);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: SizedBox(
        width: kYaruIconSize,
        height: kYaruIconSize,
        child: SafeNetworkImage(
          url: imageUrl,
          fit: BoxFit.fitHeight,
          filterQuality: FilterQuality.medium,
          fallBackIcon: const Icon(
            YaruIcons.rss,
          ),
          errorIcon: const Icon(
            YaruIcons.rss,
          ),
        ),
      ),
    );
  }

  static Widget createTitle({
    required BuildContext context,
    required String title,
    required update,
  }) {
    return Badge(
      alignment: Alignment.centerRight,
      isLabelVisible: update,
      label: Text(context.l10n.newEpisode),
      child: Text(title),
    );
  }

  final void Function(String feedUrl) removePodcast;
  final void Function(String feedUrl, Set<Audio> audios) addPodcast;
  final void Function(String feedUrl) removePodcastUpdate;
  final void Function({
    required String text,
    required AudioType audioType,
  })? onTextTap;
  final String? imageUrl;
  final String pageId;
  final String title;
  final Set<Audio>? audios;
  final bool subscribed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final genre = audios?.firstWhereOrNull((e) => e.genre != null)?.genre;

    context.select((LibraryModel m) => m.lastPositions?.length);

    return AudioPage(
      removeUpdate: removePodcastUpdate,
      showAudioTileHeader: false,
      onTextTap: onTextTap,
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
      headerLabel: genre ?? context.l10n.podcast,
      headerTitle: title,
      headerSubtile: audios?.firstOrNull?.artist,
      headerDescription: audios?.firstOrNull?.albumArtist,
      audios: audios,
      pageId: pageId,
      title: Text(title),
      controlPanelButton: IconButton(
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
