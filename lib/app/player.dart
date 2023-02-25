import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class Player extends StatelessWidget {
  const Player({
    super.key,
    required this.audioPlayer,
    required this.isPlaying,
    required this.url,
    required this.duration,
    required this.position,
  });

  final AudioPlayer audioPlayer;
  final bool isPlaying;
  final String url;
  final Duration duration;
  final Duration position;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Material(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 100,
          child: Column(
            children: [
              SizedBox(
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const YaruIconButton(
                      icon: Icon(YaruIcons.skip_backward),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: YaruIconButton(
                        onPressed: () async {
                          if (isPlaying) {
                            await audioPlayer.pause();
                          } else {
                            await audioPlayer.play(UrlSource(url));
                          }
                        },
                        icon: Icon(
                          isPlaying
                              ? YaruIcons.media_pause
                              : YaruIcons.media_play,
                        ),
                      ),
                    ),
                    const YaruIconButton(
                      icon: Icon(YaruIcons.skip_forward),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(formatTime(position)),
                        Text(formatTime(duration)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: SliderTheme(
                        data: theme.sliderTheme.copyWith(
                          thumbColor: Colors.white,
                          thumbShape: const RoundSliderThumbShape(elevation: 4),
                          inactiveTrackColor:
                              theme.primaryColor.withOpacity(0.3),
                        ),
                        child: Slider(
                          min: 0,
                          max: duration.inSeconds.toDouble(),
                          value: position.inSeconds.toDouble(),
                          onChanged: (v) async {
                            final position = Duration(seconds: v.toInt());
                            await audioPlayer.seek(position);
                            await audioPlayer.resume();
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return <String>[if (duration.inHours > 0) hours, minutes, seconds]
        .join(':');
  }
}
