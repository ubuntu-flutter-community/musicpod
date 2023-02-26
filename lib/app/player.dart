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
      child: SizedBox(
        height: 120,
        child: Row(
          children: [
            if (model.metaData?.picture != null)
              Image.memory(
                model.metaData!.picture!.data,
                width: 120.0,
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: kYaruPagePadding,
                  vertical: 10,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const YaruIconButton(icon: Icon(YaruIcons.shuffle)),
                          const YaruIconButton(
                            icon: Icon(YaruIcons.skip_backward),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: YaruIconButton(
                              onPressed: () async {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((timeStamp) async {
                                  if (context.mounted) {
                                    if (model.isPlaying) {
                                      await model.pause();
                                    } else {
                                      await model.play();
                                    }
                                  }
                                });
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
                          YaruIconButton(
                            icon: const Icon(YaruIcons.repeat),
                            isSelected: model.repeatSingle == true,
                            onPressed: model.repeatSingle == null
                                ? null
                                : () =>
                                    model.repeatSingle = !model.repeatSingle!,
                          )
                        ],
                      ),
                    ),
                    if (model.audio != null &&
                        model.audio!.audioType != AudioType.radio &&
                        model.duration != null &&
                        model.position != null &&
                        model.duration!.inSeconds > model.position!.inSeconds)
                      Expanded(
                        child: Row(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(formatTime(model.position!)),
                              ],
                            ),
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: SliderTheme(
                                  data: theme.sliderTheme.copyWith(
                                    thumbColor: Colors.white,
                                    thumbShape: const RoundSliderThumbShape(
                                      elevation: 4,
                                    ),
                                    inactiveTrackColor:
                                        theme.primaryColor.withOpacity(0.3),
                                  ),
                                  child: Slider(
                                    min: 0,
                                    max: model.duration?.inSeconds.toDouble() ??
                                        1.0,
                                    value:
                                        model.position?.inSeconds.toDouble() ??
                                            0,
                                    onChanged: (v) async {
                                      model.position =
                                          Duration(seconds: v.toInt());
                                      await model.seek();
                                      await model.resume();
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(formatTime(model.duration!)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    if (model.metaData != null)
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              model.metaData?.title ?? '',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Text(' - '),
                            Text(model.metaData?.artist ?? ''),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
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
