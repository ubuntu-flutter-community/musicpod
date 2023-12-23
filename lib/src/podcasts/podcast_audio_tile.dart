import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../l10n.dart';
import '../../theme.dart';
import '../../utils.dart';
import 'avatar_with_progress.dart';
import 'download_button.dart';

const _kGap = 20.0;

class PodcastAudioTile extends StatelessWidget {
  const PodcastAudioTile({
    super.key,
    required this.audio,
    required this.isPlayerPlaying,
    required this.selected,
    required this.pause,
    required this.resume,
    required this.play,
    required this.lastPosition,
    this.isExpanded = false,
    this.removeUpdate,
    required this.safeLastPosition,
    this.isOnline = true,
    required this.addPodcast,
    this.insertIntoQueue,
  });

  final Audio audio;
  final bool isPlayerPlaying;
  final bool selected;
  final void Function() pause;
  final Future<void> Function() resume;
  final Future<void> Function({Duration? newPosition, Audio? newAudio}) play;
  final void Function()? removeUpdate;
  final void Function() safeLastPosition;
  final void Function()? addPodcast;
  final void Function()? insertIntoQueue;

  final Duration? lastPosition;
  final bool isExpanded;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    if (!isOnline && audio.path == null) {
      return const SizedBox.shrink();
    }

    final date = audio.year == null
        ? ''
        : '${DateFormat.yMMMEd(Platform.localeName).format(DateTime.fromMillisecondsSinceEpoch(audio.year!))} | ';
    final duration = formatTime(
      audio.durationMs != null
          ? Duration(milliseconds: audio.durationMs!.toInt())
          : Duration.zero,
    );

    final narrow = context.m.size.width < 600;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: narrow ? 550 : double.infinity),
      child: YaruExpandable(
        expandIcon: const SizedBox.shrink(),
        isExpanded: isExpanded,
        gapHeight: 0,
        header: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Padding(
            padding: const EdgeInsets.only(
              top: 15,
              bottom: 10,
              left: 19,
              right: 20,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AvatarWithProgress(
                  selected: selected,
                  lastPosition: lastPosition,
                  audio: audio,
                  isPlayerPlaying: isPlayerPlaying,
                  pause: pause,
                  resume: resume,
                  safeLastPosition: safeLastPosition,
                  play: play,
                  removeUpdate: removeUpdate,
                ),
                const SizedBox(
                  width: _kGap,
                ),
                Expanded(
                  child: _Right(
                    narrow: narrow,
                    selected: selected,
                    audio: audio,
                    date: date,
                    duration: duration,
                    addPodcast: addPodcast,
                    insertIntoQueue: insertIntoQueue,
                  ),
                ),
              ],
            ),
          ),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: _Bottom(
            narrow: narrow,
            selected: selected,
            audio: audio,
            lastPosition: lastPosition,
          ),
        ),
      ),
    );
  }
}

class _Right extends StatelessWidget {
  const _Right({
    required this.audio,
    required this.selected,
    required this.date,
    required this.duration,
    required this.addPodcast,
    this.insertIntoQueue,
    this.narrow = false,
  });

  final Audio audio;
  final String date;
  final String duration;
  final bool selected;
  final void Function()? addPodcast;
  final void Function()? insertIntoQueue;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final textStyle = TextStyle(
      color: theme.colorScheme.onSurface,
      fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
      fontSize: 16,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          audio.title ?? '',
          style: textStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(
          width: narrow ? double.infinity : 280,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  '$date$duration',
                  style: theme.textTheme.labelMedium,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: kTinyButtonSize,
                    width: kTinyButtonSize,
                    child: ShareButton(
                      active: true,
                      audio: audio,
                      iconSize: kTinyButtonIconSize,
                    ),
                  ),
                  SizedBox(
                    height: kTinyButtonSize,
                    width: kTinyButtonSize,
                    child: DownloadButton.create(
                      context: context,
                      iconSize: kTinyButtonIconSize,
                      audio: audio,
                      addPodcast: addPodcast,
                    ),
                  ),
                  _ViewMoreButton(
                    insertIntoQueue: insertIntoQueue,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ViewMoreButton extends StatelessWidget {
  const _ViewMoreButton({
    required this.insertIntoQueue,
  });

  final void Function()? insertIntoQueue;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kTinyButtonSize,
      width: kTinyButtonSize,
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kTinyButtonSize),
        ),
        child: PopupMenuButton(
          splashRadius: 100,
          tooltip: context.l10n.moreOptions,
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                onTap: insertIntoQueue,
                child: Text(context.l10n.insertIntoQueue),
              ),
            ];
          },
          child: Icon(
            Iconz().viewMore,
            size: kTinyButtonIconSize,
            color: context.t.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _Bottom extends StatelessWidget {
  const _Bottom({
    required this.selected,
    required this.audio,
    required this.lastPosition,
    this.narrow = false,
  });

  final bool selected;
  final Audio audio;
  final Duration? lastPosition;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: narrow ? 480 : 600),
      child: Padding(
        padding: EdgeInsets.only(left: _kGap + podcastProgressSize + 15),
        child: _Description(
          description: audio.description,
          title: audio.title,
          selected: selected,
        ),
      ),
    );
  }
}

class _Description extends StatelessWidget {
  const _Description({
    required this.description,
    required this.title,
    required this.selected,
  });

  final String? description;
  final String? title;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        showDialog(
          context: context,
          builder: (c) {
            return SimpleDialog(
              titlePadding: yaruStyled
                  ? EdgeInsets.zero
                  : const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
              title: yaruStyled
                  ? YaruDialogTitleBar(
                      backgroundColor: theme.dialogBackgroundColor,
                      border: BorderSide.none,
                      title: Text(title ?? ''),
                    )
                  : Text(title ?? ''),
              contentPadding: EdgeInsets.only(
                top: yaruStyled ? 0 : 20,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              children: [
                SizedBox(
                  height: 400,
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
        color: theme.colorScheme.onSurface.scale(lightness: -0.2),
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
