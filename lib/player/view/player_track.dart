import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/data/audio_type.dart';
import '../../common/view/custom_track_shape.dart';
import '../../common/view/progress.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/duration_x.dart';
import '../manager/buffer_manager.dart';
import '../manager/current_audio_manager.dart';
import '../manager/duration_manager.dart';
import '../manager/play_pause_manager.dart';
import '../manager/position_manager.dart';

class PlayerTrack extends ConsumerWidget {
  const PlayerTrack({super.key, this.bottomPlayer = false, this.active = true});

  final bool bottomPlayer, active;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;

    final mainColor = theme.colorScheme.onSurface;

    final isPlaying = ref.watch(playPauseManagerProvider);

    final position = ref.watch(positionManagerProvider);
    final buffer = ref.watch(bufferManagerProvider);
    final audioType = ref.watch(
      currentAudioManagerProvider.select((a) => a?.audioType),
    );

    final duration = ref.watch(durationManagerProvider);

    final sliderActive =
        active &&
        (duration != null &&
            position != null &&
            duration.inSeconds > position.inSeconds);

    final textStyle = TextStyle(
      fontSize: 12,
      color: !active ? theme.disabledColor : null,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    final thumbShape = RoundSliderThumbShape(
      elevation: 5,
      enabledThumbRadius: bottomPlayer ? 0 : 8.0,
      disabledThumbRadius: bottomPlayer ? 0 : 8.0,
    );

    final bufferActive =
        audioType != AudioType.local &&
        active &&
        buffer != null &&
        position != null &&
        duration != null &&
        buffer.inSeconds >= 0 &&
        buffer.inSeconds <=
            (sliderActive ? duration.inSeconds.toDouble() : 1.0);

    final trackShape = bottomPlayer
        ? const RectangularSliderTrackShape()
        : CustomTrackShape();

    final trackHeight = bottomPlayer ? 4.0 : 5.0;

    final slider =
        (duration?.inSeconds != null && duration!.inSeconds < 10) &&
            audioType == AudioType.radio &&
            isPlaying
        ? Padding(
            padding: bottomPlayer
                ? EdgeInsets.zero
                : const EdgeInsets.only(left: 7, right: 7, top: 3),
            child: LinearProgress(
              value: null,
              trackHeight: trackHeight,
              color: mainColor.withValues(alpha: 0.8),
              backgroundColor: mainColor.withValues(alpha: 0.4),
            ),
          )
        : Padding(
            padding: EdgeInsets.only(top: bottomPlayer ? 0 : 3),
            child: Tooltip(
              preferBelow: false,
              message:
                  '${(position ?? Duration.zero).formattedTime} / ${(duration ?? Duration.zero).formattedTime}',
              child: SliderTheme(
                data: theme.sliderTheme.copyWith(
                  thumbColor: Colors.white,
                  thumbShape: thumbShape,
                  overlayShape: thumbShape,
                  minThumbSeparation: 0,
                  trackShape: trackShape as SliderTrackShape,
                  trackHeight: trackHeight,
                  inactiveTrackColor: mainColor.withValues(alpha: 0.2),
                  activeTrackColor: mainColor.withValues(alpha: 0.85),
                  overlayColor: mainColor,
                  secondaryActiveTrackColor: mainColor.withValues(alpha: 0.25),
                ),
                child: RepaintBoundary(
                  child: Slider(
                    min: 0,
                    max: sliderActive ? duration.inSeconds.toDouble() : 1.0,
                    value: sliderActive ? position.inSeconds.toDouble() : 0,
                    secondaryTrackValue: bufferActive
                        ? buffer.inSeconds.toDouble()
                        : null,
                    onChanged: sliderActive
                        ? (v) => ref
                              .read(positionManagerProvider.notifier)
                              .seek(Duration(seconds: v.toInt()))
                        : null,
                  ),
                ),
              ),
            ),
          );

    if (bottomPlayer) {
      return slider;
    }

    return Row(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RepaintBoundary(
              child: SizedBox(
                width: (position?.inHours != null && position!.inHours > 0)
                    ? 60
                    : 40,
                height: 15,
                child: Text(
                  (position ?? Duration.zero).formattedTime,
                  style: textStyle,
                ),
              ),
            ),
          ],
        ),
        Expanded(child: slider),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RepaintBoundary(
              child: SizedBox(
                width: (duration?.inHours != null && duration!.inHours > 0)
                    ? 60
                    : 40,
                height: 15,
                child: Text(
                  (duration ?? Duration.zero).formattedTime,
                  style: textStyle,
                  textAlign: TextAlign.end,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class PlayerSimpleTrack extends ConsumerWidget {
  const PlayerSimpleTrack({super.key, this.active = true});

  final bool active;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final position = ref.watch(positionManagerProvider);
    final duration = ref.watch(durationManagerProvider);
    final textStyle = TextStyle(
      fontSize: 10,
      color: !active ? theme.disabledColor : null,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    final positionWidth = (position?.inHours != null && position!.inHours > 0)
        ? 48.0
        : 35.0;
    final durationWidth = (duration?.inHours != null && duration!.inHours > 0)
        ? 48.0
        : 35.0;

    const slashWidth = 5.0;

    const height = 13.0;

    return SizedBox(
      width: positionWidth + durationWidth + slashWidth,
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          RepaintBoundary(
            child: SizedBox(
              width: positionWidth,
              height: height,
              child: Text(
                (position ?? Duration.zero).formattedTime,
                style: textStyle,
              ),
            ),
          ),
          SizedBox(
            height: height,
            width: slashWidth,
            child: Text('/', style: textStyle),
          ),
          RepaintBoundary(
            child: SizedBox(
              width: durationWidth,
              height: height,
              child: Text(
                (duration ?? Duration.zero).formattedTime,
                style: textStyle,
                textAlign: TextAlign.end,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
