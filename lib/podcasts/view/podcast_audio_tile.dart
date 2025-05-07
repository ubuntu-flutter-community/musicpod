import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/data/audio.dart';
import '../../common/view/icons.dart';
import '../../common/view/share_button.dart';
import '../../common/view/snackbars.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/duration_x.dart';
import '../../extensions/int_x.dart';
import '../../extensions/taget_platform_x.dart';
import '../../l10n/l10n.dart';
import '../../player/player_model.dart';
import '../../settings/settings_model.dart';
import 'download_button.dart';
import 'podcast_tile_play_button.dart';

class PodcastAudioTile extends StatelessWidget with WatchItMixin {
  const PodcastAudioTile({
    super.key,
    required this.audio,
    required this.isPlayerPlaying,
    required this.selected,
    required this.startPlaylist,
    this.isExpanded = false,
    this.removeUpdate,
    this.isOnline = true,
    required this.addPodcast,
  });

  final Audio audio;
  final bool isPlayerPlaying;
  final bool selected;

  final void Function()? startPlaylist;
  final void Function()? removeUpdate;
  final void Function()? addPodcast;

  final bool isExpanded;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    if (!isOnline && audio.path == null) {
      return const SizedBox.shrink();
    }

    final date = audio.year.unixTimeToDateString;
    final duration = audio.durationMs != null
        ? Duration(milliseconds: audio.durationMs!.toInt()).formattedTime
        : context.l10n.unknown;
    final label = '$date, ${context.l10n.duration}: $duration';

    final playerModel = di<PlayerModel>();
    final useYaruTheme =
        watchPropertyValue((SettingsModel m) => m.useYaruTheme);
    final smallAvatarButtonRadius = getSmallAvatarButtonRadius(useYaruTheme);

    return YaruExpandable(
      isExpanded: isExpanded,
      expandIconPadding: const EdgeInsets.only(right: 5, bottom: 15),
      gapHeight: 0,
      header: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Padding(
          padding: const EdgeInsets.only(top: 15, bottom: 10, left: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PodcastTilePlayButton(
                selected: selected,
                audio: audio,
                isPlayerPlaying: isPlayerPlaying,
                startPlaylist: startPlaylist,
                removeUpdate: removeUpdate,
              ),
              SizedBox(width: isMobile ? 15 : 25),
              Expanded(
                child: _Center(
                  selected: selected,
                  title: audio.title ?? '',
                  label: label,
                  addPodcast: addPodcast,
                ),
              ),
            ],
          ),
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: isMobile
              ? const EdgeInsets.symmetric(horizontal: 10)
              : EdgeInsets.only(
                  left: (smallAvatarButtonRadius * 2) + 30,
                  right: 60,
                ),
          child: Column(
            children: [
              _Description(
                description: audio.description,
                title: audio.title,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: space(
                      children: [
                        DownloadButton(
                          audio: audio,
                          addPodcast: addPodcast,
                        ),
                        ShareButton(
                          active: true,
                          audio: audio,
                        ),
                        IconButton(
                          tooltip: context.l10n.insertIntoQueue,
                          onPressed: () {
                            final text =
                                '${audio.title != null ? '${audio.album} - ' : ''}${audio.title ?? ''}';
                            playerModel.insertIntoQueue([audio]);
                            showSnackBar(
                              context: context,
                              content:
                                  Text(context.l10n.insertedIntoQueue(text)),
                            );
                          },
                          icon: Icon(Iconz.insertIntoQueue),
                        ),
                        IconButton(
                          tooltip: context.l10n.replayEpisode,
                          onPressed: audio.url == null
                              ? null
                              : () => playerModel
                                ..removeLastPosition(audio.url!)
                                ..setPosition(Duration.zero)
                                ..seek(),
                          icon: Icon(Iconz.replay),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Center extends StatelessWidget {
  const _Center({
    required this.title,
    required this.selected,
    required this.label,
    required this.addPodcast,
  });

  final String title;
  final String label;
  final bool selected;
  final void Function()? addPodcast;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final textStyle = TextStyle(
      color: theme.colorScheme.onSurface,
      fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
      fontSize: 16,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.labelMedium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Description extends StatelessWidget with WatchItMixin {
  const _Description({
    required this.description,
    required this.title,
  });

  final String? description;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final useYaruTheme =
        watchPropertyValue((SettingsModel m) => m.useYaruTheme);
    final theme = context.theme;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        showDialog(
          context: context,
          builder: (c) {
            return SimpleDialog(
              titlePadding: EdgeInsets.zero,
              title: YaruDialogTitleBar(
                backgroundColor: theme.dialogTheme.backgroundColor,
                border: BorderSide.none,
                title: Text(title ?? ''),
              ),
              contentPadding: EdgeInsets.only(
                top: useYaruTheme ? 0 : kLargestSpace,
                left: kLargestSpace,
                right: kLargestSpace,
                bottom: kLargestSpace,
              ),
              children: [
                SizedBox(
                  width: 400,
                  child: _createHtml(
                    color: theme.colorScheme.onSurface,
                    maxLines: 200,
                    paddings: HtmlPaddings.zero,
                  ),
                ),
              ],
            );
          },
        );
      },
      child: _createHtml(
        color: theme.colorScheme.onSurface,
        maxLines: 5,
        paddings: HtmlPaddings.all(5),
      ),
    );
  }

  Widget _createHtml({
    required Color color,
    int? maxLines,
    TextAlign? textAlign,
    HtmlPaddings? paddings,
  }) {
    return Html(
      data: description,
      onAnchorTap: (url, attributes, element) {
        if (url == null) return;
        launchUrl(Uri.parse(url));
      },
      style: {
        'img': Style(display: Display.none),
        'body': Style(
          margin: Margins.zero,
          padding: paddings,
          color: color,
          textOverflow: TextOverflow.ellipsis,
          maxLines: maxLines,
          textAlign: textAlign ?? TextAlign.start,
        ),
      },
    );
  }
}
