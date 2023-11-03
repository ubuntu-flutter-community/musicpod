import 'package:flutter/material.dart';
import 'package:musicpod/utils.dart';

class PlayerTrack extends StatelessWidget {
  const PlayerTrack({
    super.key,
    this.color,
    this.duration,
    this.position,
    required this.setPosition,
    required this.seek,
  });

  final Color? color;
  final Duration? duration;
  final Duration? position;
  final void Function(Duration?) setPosition;
  final Future<void> Function() seek;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    bool sliderActive = duration != null &&
        position != null &&
        duration!.inSeconds > position!.inSeconds;

    const textStyle = TextStyle(fontSize: 12);
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
          child: SizedBox(
            height: 50,
            child: SliderTheme(
              data: theme.sliderTheme.copyWith(
                thumbColor: Colors.white,
                thumbShape: const RoundSliderThumbShape(
                  elevation: 0,
                  enabledThumbRadius: 0,
                  disabledThumbRadius: 0,
                ),
                trackHeight: 2,
                inactiveTrackColor: color != null
                    ? theme.colorScheme.onSurface.withOpacity(0.35)
                    : theme.primaryColor.withOpacity(0.5),
                activeTrackColor: color != null
                    ? theme.colorScheme.onSurface.withOpacity(0.8)
                    : theme.primaryColor,
                overlayColor: color != null
                    ? theme.colorScheme.onSurface
                    : theme.primaryColor,
                overlayShape: const RoundSliderThumbShape(
                  elevation: 3,
                  enabledThumbRadius: 8,
                  disabledThumbRadius: 8,
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
            ),
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
