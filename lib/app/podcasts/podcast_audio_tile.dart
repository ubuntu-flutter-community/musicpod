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
  });

  final Audio audio;
  final bool isPlayerPlaying;
  final bool selected;
  final void Function() pause;
  final Future<void> Function() resume;
  final void Function()? startPlaylist;
  final Future<void> Function() play;
  final Duration? lastPosition;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = TextStyle(
      color: selected ? theme.colorScheme.onSurface : theme.hintColor,
      fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
    );
    return YaruExpandable(
      gapHeight: 0,
      header: Padding(
        padding: const EdgeInsets.only(
          top: 15,
          bottom: 10,
          right: 8,
          left: 8,
        ),
        child: Text(
          audio.title ?? 'unknown',
          style: textStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      collapsedChild: _Bottom(
        isPlayerPlaying: isPlayerPlaying,
        selected: selected,
        pause: pause,
        resume: resume,
        startPlaylist: startPlaylist,
        play: play,
        audio: audio,
        theme: theme,
        lastPosition: lastPosition,
        maxLines: 2,
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
        maxLines: 10,
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
    this.maxLines,
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
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 4,
                ),
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
                    DateFormat.MMMEd(
                      WidgetsBinding
                          .instance.platformDispatcher.locale.countryCode,
                    ).format(DateTime.fromMillisecondsSinceEpoch(audio.year!)),
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w100,
                      color: theme.hintColor,
                    ),
                  ),
                if (audio.durationMs != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Text(
                      formatTime(
                        Duration(milliseconds: audio.durationMs!.toInt()),
                      ),
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w100,
                        color: theme.hintColor,
                      ),
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
          padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 16),
          child: _Description(
            description: audio.description,
            maxLines: maxLines,
          ),
        )
      ],
    );
  }
}

class _Description extends StatelessWidget {
  const _Description({
    required this.description,
    this.maxLines,
  });

  final String? description;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          textAlign: TextAlign.start,
        ),
        'body': Style(
          margin: Margins.zero,
          padding: HtmlPaddings.only(top: 5),
          color: theme.hintColor,
          textOverflow: TextOverflow.ellipsis,
          maxLines: maxLines,
          textAlign: TextAlign.start,
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
