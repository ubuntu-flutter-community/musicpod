import 'package:flutter/material.dart';

import '../../../build_context_x.dart';
import '../../../common.dart';
import '../../../duration_x.dart';
import '../../../get.dart';
import '../player_model.dart';

class PlayerTrack extends StatelessWidget with WatchItMixin {
  const PlayerTrack({
    super.key,
    this.bottomPlayer = false,
    this.active = true,
  });

  final bool bottomPlayer, active;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;

    final mainColor = theme.colorScheme.onSurface;

    final playerModel = getIt<PlayerModel>();

    final position = watchPropertyValue((PlayerModel m) => m.position);
    final buffer = watchPropertyValue((PlayerModel m) => m.buffer);

    final setPosition = playerModel.setPosition;
    final duration = watchPropertyValue((PlayerModel m) => m.duration);
    final seek = playerModel.seek;

    bool sliderActive = active &&
        (duration != null &&
            position != null &&
            duration.inSeconds > position.inSeconds);

    final textStyle =
        TextStyle(fontSize: 12, color: !active ? theme.disabledColor : null);

    final thumbShape = RoundSliderThumbShape(
      elevation: 5,
      enabledThumbRadius: bottomPlayer ? 0 : 8.0,
      disabledThumbRadius: bottomPlayer ? 0 : 8.0,
    );

    final bufferActive = active &&
        buffer != null &&
        position != null &&
        buffer.inSeconds >= position.inSeconds;
    final secondaryTrackValue =
        bufferActive ? buffer.inSeconds.toDouble() : 0.0;

    final slider = (duration?.inSeconds != null && duration!.inSeconds < 30)
        ? LinearProgress(
            value: null,
            trackHeight: 4.0,
            color: mainColor,
          )
        : Tooltip(
            preferBelow: false,
            message:
                '${(position ?? Duration.zero).formattedTime} / ${(duration ?? Duration.zero).formattedTime}',
            child: SliderTheme(
              data: theme.sliderTheme.copyWith(
                thumbColor: Colors.white,
                thumbShape: thumbShape,
                overlayShape: thumbShape,
                minThumbSeparation: 0,
                trackShape:
                    bottomPlayer ? const RectangularSliderTrackShape() : null,
                trackHeight: bottomPlayer ? 4.0 : 2.0,
                inactiveTrackColor: mainColor.withOpacity(0.2),
                activeTrackColor: mainColor.withOpacity(0.85),
                overlayColor: mainColor,
                secondaryActiveTrackColor: mainColor.withOpacity(0.3),
              ),
              child: RepaintBoundary(
                child: Slider(
                  min: 0,
                  max: sliderActive ? duration.inSeconds.toDouble() : 1.0,
                  value: sliderActive ? position.inSeconds.toDouble() : 0,
                  secondaryTrackValue: secondaryTrackValue,
                  onChanged: sliderActive
                      ? (v) async {
                          setPosition(Duration(seconds: v.toInt()));
                          await seek();
                        }
                      : null,
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
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: bottomPlayer ? 0 : 3),
            child: slider,
          ),
        ),
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
