import 'package:flutter/material.dart';
import '../../utils.dart';

class PlayerTrack extends StatelessWidget {
  const PlayerTrack({
    super.key,
    this.color,
    this.duration,
    this.position,
    required this.setPosition,
    required this.seek,
    this.superNarrow = false,
  });

  final Color? color;
  final Duration? duration;
  final Duration? position;
  final void Function(Duration?) setPosition;
  final Future<void> Function() seek;
  final bool superNarrow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    bool sliderActive = duration != null &&
        position != null &&
        duration!.inSeconds > position!.inSeconds;

    const textStyle = TextStyle(fontSize: 12);
    final slider = SliderTheme(
      data: theme.sliderTheme.copyWith(
        thumbColor: Colors.white,
        thumbShape: const RoundSliderThumbShape(
          elevation: 0,
          enabledThumbRadius: 0,
          disabledThumbRadius: 0,
          pressedElevation: 0,
        ),
        minThumbSeparation: 0,
        trackShape: superNarrow ? const RectangularSliderTrackShape() : null,
        trackHeight: superNarrow ? 4 : 2,
        inactiveTrackColor: color != null
            ? theme.colorScheme.onSurface.withOpacity(0.35)
            : theme.colorScheme.primary.withOpacity(0.5),
        activeTrackColor: color != null
            ? theme.colorScheme.onSurface.withOpacity(0.8)
            : theme.colorScheme.primary,
        overlayColor: color != null
            ? theme.colorScheme.onSurface
            : theme.colorScheme.primary,
        overlayShape: RoundSliderThumbShape(
          elevation: 3,
          enabledThumbRadius: superNarrow ? 0 : 5.0,
          disabledThumbRadius: superNarrow ? 0 : 5.0,
        ),
      ),
      child: RepaintBoundary(
        child: Slider(
          min: 0,
          max: sliderActive ? duration!.inSeconds.toDouble() : 1.0,
          value: sliderActive ? position!.inSeconds.toDouble() : 0,
          onChanged: sliderActive
              ? (v) async {
                  setPosition(Duration(seconds: v.toInt()));
                  await seek();
                }
              : null,
        ),
      ),
    );

    if (superNarrow) {
      return SizedBox(width: 1000, child: slider);
    }

    return Row(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RepaintBoundary(
              child: Text(
                formatTime(position ?? Duration.zero),
                style: textStyle,
              ),
            ),
          ],
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: superNarrow ? 0 : 3),
            child: slider,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RepaintBoundary(
              child: Text(
                formatTime(duration ?? Duration.zero),
                style: textStyle,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
