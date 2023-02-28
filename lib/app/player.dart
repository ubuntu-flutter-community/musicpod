import 'package:flutter/material.dart';
import 'package:music/app/player_model.dart';
import 'package:music/app/playlists/playlist_model.dart';
import 'package:music/data/audio.dart';
import 'package:music/utils.dart';
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
    final playlistModel = context.watch<PlaylistModel>();
    final liked = playlistModel.likedAudios.contains(model.audio);
    final theme = Theme.of(context);

    final fullScreenButton = Padding(
      padding: const EdgeInsets.all(8.0),
      child: YaruIconButton(
        icon: Icon(
          model.fullScreen == true
              ? YaruIcons.fullscreen_exit
              : YaruIcons.fullscreen,
          color: theme.colorScheme.onSurface,
        ),
        isSelected: model.fullScreen == true,
        onPressed: () => model.fullScreen = !(model.fullScreen ?? false),
      ),
    );

    final controls = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        YaruIconButton(
          onPressed:
              model.audio == null || model.audio!.audioType == AudioType.radio
                  ? null
                  : () => playlistModel.addLikedAudio(model.audio!),
          icon: liked
              ? const Icon(YaruIcons.heart_filled)
              : const Icon(YaruIcons.heart),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 10),
          child: YaruIconButton(icon: Icon(YaruIcons.shuffle)),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: YaruIconButton(
            onPressed: () => model.playPrevious(),
            icon: const Icon(YaruIcons.skip_backward),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: YaruIconButton(
            onPressed: model.audio == null
                ? null
                : () {
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
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: YaruIconButton(
            onPressed: () => model.playNext(),
            icon: const Icon(YaruIcons.skip_forward),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: YaruIconButton(
            icon: Icon(
              YaruIcons.repeat,
              color: theme.colorScheme.onSurface,
            ),
            isSelected: model.repeatSingle == true,
            onPressed: () => model.repeatSingle = !(model.repeatSingle),
          ),
        ),
        YaruIconButton(
          icon: const Icon(YaruIcons.media_stop),
          onPressed: () => model.stop(),
        )
      ],
    );

    final trackText = Wrap(
      direction: model.fullScreen == true ? Axis.vertical : Axis.horizontal,
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: model.fullScreen == true ? 0 : 10,
      runSpacing: 20,
      children: [
        Text(
          model.audio?.metadata?.title ?? model.audio?.name ?? '',
          style: TextStyle(
            fontWeight:
                model.fullScreen == true ? FontWeight.w400 : FontWeight.bold,
            fontSize: model.fullScreen == true ? 45 : 15,
            color: model.fullScreen == true
                ? theme.colorScheme.onSurface.withOpacity(0.7)
                : null,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          model.audio?.metadata?.artist ?? '',
          style: TextStyle(
            fontWeight:
                model.fullScreen == true ? FontWeight.w100 : FontWeight.w400,
            fontSize: model.fullScreen == true ? 25 : 15,
            color: model.fullScreen == true
                ? theme.colorScheme.onSurface.withOpacity(0.7)
                : null,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );

    bool sliderActive() =>
        model.audio != null &&
        model.audio!.audioType != AudioType.radio &&
        model.duration != null &&
        model.position != null &&
        model.duration!.inSeconds > model.position!.inSeconds;

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
                inactiveTrackColor: model.color != null
                    ? theme.colorScheme.onSurface.withOpacity(0.35)
                    : theme.primaryColor.withOpacity(0.5),
                activeTrackColor: model.color != null
                    ? theme.colorScheme.onSurface.withOpacity(0.8)
                    : theme.primaryColor,
                overlayColor: model.color?.withOpacity(0.3) ??
                    theme.primaryColor.withOpacity(0.5),
              ),
              child: Slider(
                min: 0,
                max: sliderActive()
                    ? model.duration?.inSeconds.toDouble() ?? 1.0
                    : 1.0,
                value: sliderActive()
                    ? model.position?.inSeconds.toDouble() ?? 0
                    : 0,
                onChanged: sliderActive()
                    ? (v) async {
                        model.position = Duration(seconds: v.toInt());
                        await model.seek();
                        await model.resume();
                      }
                    : null,
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
                    vertical: 40,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (model.audio?.metadata?.picture != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            model.audio!.metadata!.picture!.data,
                            height: 400.0,
                            fit: BoxFit.fitHeight,
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
          if (model.nextAudio?.metadata?.title != null &&
              model.nextAudio?.metadata?.artist != null)
            Positioned(
              left: 10,
              bottom: 10,
              child: YaruBorderContainer(
                color: theme.cardColor,
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Up next',
                      style: theme.textTheme.labelSmall,
                    ),
                    Text(
                      '${model.nextAudio!.metadata!.artist!} • ${model.nextAudio!.metadata!.title!}',
                      style: theme.textTheme.labelMedium
                          ?.copyWith(color: theme.colorScheme.onSurface),
                    )
                  ],
                ),
              ),
            )
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
                AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  child: Image.memory(
                    filterQuality: FilterQuality.medium,
                    fit: BoxFit.cover,
                    model.audio!.metadata!.picture!.data,
                    height: 120.0,
                  ),
                )
              else
                AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  child: const YaruBorderContainer(
                    width: 120.0,
                    height: 120.0,
                  ),
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
}
