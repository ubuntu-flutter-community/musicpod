import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:musicpod/app/player/player_model.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/utils.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class PodcastAudioTile extends StatelessWidget {
  const PodcastAudioTile({
    super.key,
    required this.audio,
    required this.isPlayerPlaying,
    required this.selected,
    required this.pause,
    required this.resume,
    required this.startPlaylist,
    required this.play,
    required this.lastPosition,
    this.isExpanded = false,
    this.countryCode,
    this.removeUpdate,
  });

  final Audio audio;
  final bool isPlayerPlaying;
  final bool selected;
  final void Function() pause;
  final Future<void> Function() resume;
  final void Function()? startPlaylist;
  final Future<void> Function({bool bigPlay, Audio? newAudio}) play;
  final void Function()? removeUpdate;

  final Duration? lastPosition;
  final bool isExpanded;
  final String? countryCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = TextStyle(
      color: theme.colorScheme.onSurface,
      fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
      fontSize: 16,
    );

    final date = DateFormat.yMMMEd(Platform.localeName)
        .format(DateTime.fromMillisecondsSinceEpoch(audio.year!));
    final duration = formatTime(
      audio.durationMs != null
          ? Duration(milliseconds: audio.durationMs!.toInt())
          : Duration.zero,
    );

    return YaruExpandable(
      expandIcon: const SizedBox.shrink(),
      isExpanded: isExpanded,
      gapHeight: 0,
      header: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Padding(
          padding: const EdgeInsets.only(
            top: 15,
            bottom: 10,
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.onSurface.withOpacity(0.08),
                child: YaruIconButton(
                  icon: (isPlayerPlaying && selected)
                      ? Icon(
                          YaruIcons.media_pause,
                          color: theme.primaryColor,
                        )
                      : const Icon(YaruIcons.media_play),
                  onPressed: () {
                    if (selected) {
                      if (isPlayerPlaying) {
                        pause();
                      } else {
                        resume();
                      }
                    } else {
                      if (startPlaylist != null) {
                        startPlaylist!();
                      } else {
                        play(newAudio: audio);
                      }
                      removeUpdate?.call();
                    }
                  },
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      audio.title ?? '',
                      style: textStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$date, $duration',
                      style: theme.textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      child: _Bottom(
        selected: selected,
        audio: audio,
        theme: theme,
        lastPosition: lastPosition,
      ),
    );
  }
}

class _Bottom extends StatelessWidget {
  const _Bottom({
    required this.selected,
    required this.audio,
    required this.theme,
    required this.lastPosition,
  });

  final bool selected;
  final Audio audio;
  final ThemeData theme;
  final Duration? lastPosition;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            YaruIconButton(
              onPressed: audio.website == null
                  ? null
                  : () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: TextButton(
                            child: Text(
                              'Copied to clipboard: ${audio.website}',
                            ),
                            onPressed: () =>
                                launchUrl(Uri.parse(audio.website!)),
                          ),
                        ),
                      ),
              icon: const Icon(
                YaruIcons.share,
              ),
            ),
            const YaruIconButton(
              icon: Icon(YaruIcons.download),
              //TODO: implement download
              onPressed: null,
            ),
            const SizedBox(
              width: 5,
            ),
            _AudioProgress(
              selected: selected,
              lastPosition: lastPosition,
              duration: audio.durationMs == null
                  ? null
                  : Duration(milliseconds: audio.durationMs!.toInt()),
            ),
          ],
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: _Description(
            description: audio.description,
            title: audio.title,
            selected: selected,
          ),
        ),
      ],
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
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        showDialog(
          context: context,
          builder: (c) {
            return SimpleDialog(
              titlePadding: EdgeInsets.zero,
              title: YaruDialogTitleBar(
                backgroundColor: theme.dialogBackgroundColor,
                border: BorderSide.none,
                title: Text(title ?? ''),
              ),
              contentPadding: const EdgeInsets.only(
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
                )
              ],
            );
          },
        );
      },
      child: _createHtml(
        color: theme.colorScheme.onSurface.scale(lightness: -0.2),
        maxLines: 5,
        paddings: HtmlPaddings.only(top: 10, left: 5, right: 5, bottom: 10),
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
        )
      },
    );
  }
}

class _AudioProgress extends StatelessWidget {
  const _AudioProgress({
    this.lastPosition,
    this.duration,
    required this.selected,
  });

  final Duration? lastPosition;
  final Duration? duration;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final position = context.select((PlayerModel m) => m.position);

    final pos = lastPosition ?? (selected ? position : Duration.zero);

    bool sliderActive =
        duration != null && pos != null && duration!.inSeconds > pos.inSeconds;

    return RepaintBoundary(
      child: SizedBox(
        width: 25,
        height: 25,
        child: YaruCircularProgressIndicator(
          color: selected ? theme.primaryColor : theme.colorScheme.onSurface,
          value: sliderActive
              ? (pos.inSeconds.toDouble() / duration!.inSeconds.toDouble())
              : 0,
          strokeWidth: 3,
        ),
      ),
    );
  }
}
