import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music/app/player_model.dart';
import 'package:music/data/audio.dart';
import 'package:provider/provider.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class Player extends StatelessWidget {
  const Player({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PlayerModel>();
    var theme = Theme.of(context);
    return Material(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 100,
          child: Column(
            children: [
              Expanded(
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
                          if (model.isPlaying) {
                            await model.pause();
                          } else {
                            await model.play();
                          }
                        },
                        icon: Icon(
                          model.isPlaying
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
              if (model.audio != null &&
                  model.audio!.audioType != AudioType.radio)
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(formatTime(model.position)),
                          Text(formatTime(model.duration)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: SliderTheme(
                          data: theme.sliderTheme.copyWith(
                            thumbColor: Colors.white,
                            thumbShape:
                                const RoundSliderThumbShape(elevation: 4),
                            inactiveTrackColor:
                                theme.primaryColor.withOpacity(0.3),
                          ),
                          child: Slider(
                            min: 0,
                            max: model.duration.inSeconds.toDouble(),
                            value: model.position.inSeconds.toDouble(),
                            onChanged: (v) async {
                              model.position = Duration(seconds: v.toInt());
                              await model.seek();
                              await model.resume();
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
