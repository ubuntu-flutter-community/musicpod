import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:musicpod/app/player/player_model.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/utils.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
  });

  final Audio audio;
  final bool isPlayerPlaying;
  final bool selected;
  final void Function() pause;
  final Future<void> Function() resume;
  final void Function()? startPlaylist;
  final Future<void> Function() play;
  final Duration? lastPosition;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = TextStyle(
      color: selected ? theme.colorScheme.onSurface : theme.hintColor,
      fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
      fontSize: 16,
    );

    final date = DateFormat.MMMEd(
      WidgetsBinding.instance.platformDispatcher.locale.countryCode,
    ).format(DateTime.fromMillisecondsSinceEpoch(audio.year!));
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
            right: 2,
            left: 2,
          ),
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
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: selected ? null : theme.hintColor),
              ),
              const SizedBox(
                height: 5,
              ),
            ],
          ),
        ),
      ),
      child: _Bottom(
        isPlayerPlaying: isPlayerPlaying,
        selected: selected,
        pause: pause,
        resume: resume,
        startPlaylist: startPlaylist,
        play: play,
        audio: audio,
        theme: theme,
        lastPosition: lastPosition,
      ),
    );
  }
}

class _Bottom extends StatelessWidget {
  const _Bottom({
    required this.isPlayerPlaying,
    required this.selected,
    required this.pause,
    required this.resume,
    required this.startPlaylist,
    required this.play,
    required this.audio,
    required this.theme,
    required this.lastPosition,
  });

  final bool isPlayerPlaying;
  final bool selected;
  final void Function() pause;
  final Future<void> Function() resume;
  final void Function()? startPlaylist;
  final Future<void> Function() play;
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
            CircleAvatar(
              child: YaruIconButton(
                icon: (isPlayerPlaying && selected)
                    ? const Icon(YaruIcons.media_pause)
                    : const Icon(YaruIcons.media_play),
                onPressed: () {
                  if (isPlayerPlaying && selected) {
                    pause();
                  } else {
                    if (selected) {
                      resume();
                    } else {
                      if (startPlaylist != null) {
                        startPlaylist!();
                      } else {
                        play();
                      }
                    }
                  }
                },
              ),
            ),
            const SizedBox(
              width: 5,
            ),
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
              icon: Icon(
                YaruIcons.share,
                color: selected ? null : theme.hintColor,
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
          child: Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 15, left: 2),
            child: _Description(
              description: audio.description,
              title: audio.title,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 10, bottom: 10, right: 50),
          child: Divider(
            height: 0,
          ),
        )
      ],
    );
  }
}

class _Description extends StatelessWidget {
  const _Description({
    required this.description,
    required this.title,
  });

  final String? description;
  final String? title;

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
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 100),
        child: _createHtml(
          color: theme.hintColor,
          maxLines: 6,
          paddings: HtmlPaddings.only(right: 90),
        ),
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
        'html': Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          textAlign: textAlign ?? TextAlign.start,
        ),
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
          color: selected ? theme.primaryColor : theme.hintColor,
          value: sliderActive
              ? (pos.inSeconds.toDouble() / duration!.inSeconds.toDouble())
              : 0,
          strokeWidth: 3,
        ),
      ),
    );
  }
}
