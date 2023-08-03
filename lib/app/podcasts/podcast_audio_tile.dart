import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/utils.dart';
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
      fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
    );

    // , ${audio.year != null ? DateFormat.MMMEd(
    //             WidgetsBinding.instance.platformDispatcher.locale.countryCode,
    //           ).format(DateTime.fromMillisecondsSinceEpoch(audio.year!)) : ''}

    return YaruExpandable(
      isExpanded: isExpanded,
      gapHeight: 0,
      header: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Padding(
          padding: const EdgeInsets.only(
            top: 15,
            bottom: 10,
            right: 5,
            left: 5,
          ),
          child: Text(
            audio.title ?? '',
            style: textStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  width: 10,
                ),
                if (audio.year != null)
                  Text(
                    '${DateFormat.MMMEd(
                      WidgetsBinding
                          .instance.platformDispatcher.locale.countryCode,
                    ).format(DateTime.fromMillisecondsSinceEpoch(audio.year!))}, ',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w100,
                      color: theme.hintColor,
                    ),
                  ),
                Text(
                  formatTime(
                    audio.durationMs != null
                        ? Duration(milliseconds: audio.durationMs!.toInt())
                        : Duration.zero,
                  ),
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w100,
                    color: theme.hintColor,
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: RepaintBoundary(
                      child: _AudioProgress(
                        lastPosition: lastPosition,
                        duration: audio.durationMs == null
                            ? null
                            : Duration(milliseconds: audio.durationMs!.toInt()),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
              ],
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 15, left: 5),
          child: _Description(
            description: audio.description,
            title: audio.title,
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
  });

  final Duration? lastPosition;
  final Duration? duration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool sliderActive = duration != null &&
        lastPosition != null &&
        duration!.inSeconds > lastPosition!.inSeconds;
    return SliderTheme(
      data: theme.sliderTheme.copyWith(
        thumbColor: Colors.white,
        thumbShape: const RoundSliderThumbShape(
          elevation: 0,
          enabledThumbRadius: 0,
          disabledThumbRadius: 0,
        ),
        trackHeight: 1,
        overlayShape: const RoundSliderThumbShape(
          elevation: 0,
          enabledThumbRadius: 0,
          disabledThumbRadius: 0,
        ),
      ),
      child: Slider(
        min: 0,
        max: sliderActive ? duration!.inSeconds.toDouble() : 1.0,
        value: sliderActive ? lastPosition!.inSeconds.toDouble() : 0,
        onChanged: (value) {},
      ),
    );
  }
}
