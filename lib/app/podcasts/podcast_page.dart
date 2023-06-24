import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_page.dart';
import 'package:musicpod/app/common/safe_network_image.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class PodcastPage extends StatelessWidget {
  const PodcastPage({
    super.key,
    this.onControlButtonPressed,
    this.onAlbumTap,
    this.onArtistTap,
    this.imageUrl,
    required this.pageId,
    required this.showWindowControls,
    this.audios,
  });

  static Widget createIcon(BuildContext context, String? imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: SizedBox(
        width: 23,
        child: SafeNetworkImage(
          url: imageUrl,
          fit: BoxFit.fitHeight,
          filterQuality: FilterQuality.medium,
          fallBackIcon: Icon(
            YaruIcons.rss,
            color: Theme.of(context).hintColor,
          ),
        ),
      ),
    );
  }

  final void Function()? onControlButtonPressed;
  final void Function(String)? onAlbumTap;
  final void Function(String)? onArtistTap;
  final String? imageUrl;
  final String pageId;
  final bool showWindowControls;
  final Set<Audio>? audios;

  @override
  Widget build(BuildContext context) {
    return AudioPage(
      sort: false,
      onAlbumTap: onAlbumTap,
      onArtistTap: onArtistTap,
      audioPageType: AudioPageType.podcast,
      image: imageUrl == null
          ? null
          : SafeNetworkImage(
              fallBackIcon: SizedBox(
                width: 200,
                child: Center(
                  child: Icon(
                    YaruIcons.music_note,
                    size: 80,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ),
              url: imageUrl,
              fit: BoxFit.fitWidth,
              filterQuality: FilterQuality.medium,
            ),
      pageLabel: context.l10n.podcast,
      pageTitle: pageId,
      showWindowControls: showWindowControls,
      audios: audios,
      pageId: pageId,
      showTrack: false,
      editableName: false,
      deletable: false,
      controlPageButton: YaruIconButton(
        icon: Icon(
          YaruIcons.rss,
          color: Theme.of(context).primaryColor,
        ),
        onPressed: onControlButtonPressed,
      ),
    );
  }
}
