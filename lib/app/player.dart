import 'package:flutter/material.dart';
import 'package:music/app/player_model.dart';
import 'package:music/data/audio.dart';
import 'package:provider/provider.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class Player extends StatefulWidget {
  const Player({
    super.key,
  });

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) {
        context.read<PlayerModel>().init();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PlayerModel>();
    final theme = Theme.of(context);

    final fullScreenButton = Padding(
      padding: const EdgeInsets.all(8.0),
      child: YaruIconButton(
        icon: Icon(
          model.fullScreen == true
              ? YaruIcons.fullscreen_exit
              : YaruIcons.fullscreen,
        ),
        isSelected: model.fullScreen == true,
        onPressed: () => model.fullScreen = !(model.fullScreen ?? false),
      ),
    );

    final controls = Row(
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
            onPressed: () {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                if (context.mounted) {
                  if (model.isPlaying) {
                    model.pause();
                  } else {
                    model.play();
                  }
                }
              });
            },
            icon: Icon(
              model.isPlaying ? YaruIcons.media_pause : YaruIcons.media_play,
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
              : () => model.repeatSingle = !model.repeatSingle!,
        )
      ],
    );

    final trackText = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          model.audio?.metadata?.title ?? model.audio?.name ?? '',
          style: TextStyle(
            fontWeight:
                model.fullScreen == true ? FontWeight.w100 : FontWeight.bold,
            fontSize: model.fullScreen == true ? 45 : 15,
            color: model.fullScreen == true
                ? theme.colorScheme.onSurface.withOpacity(0.7)
                : null,
          ),
        ),
        Text(
          ' - ${model.audio?.metadata?.artist ?? ''}',
          style: TextStyle(
            fontWeight:
                model.fullScreen == true ? FontWeight.w100 : FontWeight.w400,
            fontSize: model.fullScreen == true ? 45 : 15,
            color: model.fullScreen == true
                ? theme.colorScheme.onSurface.withOpacity(0.7)
                : null,
          ),
        ),
      ],
    );

    final sliderAndTime = Row(
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
                inactiveTrackColor: theme.primaryColor.withOpacity(0.3),
              ),
              child: Slider(
                min: 0,
                max: model.duration?.inSeconds.toDouble() ?? 1.0,
                value: model.position?.inSeconds.toDouble() ?? 0,
                onChanged: (v) async {
                  model.position = Duration(seconds: v.toInt());
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
    );

    if (model.fullScreen == true) {
      return Stack(
        alignment: Alignment.topRight,
        children: [
          Center(
            child: SingleChildScrollView(
              child: SizedBox(
                height: 800,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (model.audio?.metadata?.picture != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            model.audio!.metadata!.picture!.data,
                            width: 400.0,
                          ),
                        ),
                      controls,
                      sliderAndTime,
                      trackText,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(kYaruPagePadding),
            child: fullScreenButton,
          ),
        ],
      );
    }

    return SizedBox(
      height: 120,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          fullScreenButton,
          Row(
            children: [
              if (model.audio?.metadata?.picture != null)
                Image.memory(
                  model.audio!.metadata!.picture!.data,
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
                        child: controls,
                      ),
                      if (model.audio != null &&
                          model.audio!.audioType != AudioType.radio &&
                          model.duration != null &&
                          model.position != null &&
                          model.duration!.inSeconds > model.position!.inSeconds)
                        Expanded(
                          child: sliderAndTime,
                        ),
                      Expanded(
                        child: trackText,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
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
