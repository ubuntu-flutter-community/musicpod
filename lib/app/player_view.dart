import 'package:flutter/material.dart';
import 'package:musicpod/app/player_model.dart';
import 'package:musicpod/app/playlists/playlist_model.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:musicpod/utils.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class PlayerView extends StatefulWidget {
  const PlayerView({
    super.key,
    this.expandHeight = false,
  });

  final bool expandHeight;

  @override
  State<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> {
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
    final liked = model.audio == null
        ? false
        : context.read<PlaylistModel>().liked(model.audio!);
    final theme = Theme.of(context);
    final isFullScreen = widget.expandHeight || model.fullScreen == true;
    final width = MediaQuery.of(context).size.width;
    final removeLikedAudio = context.read<PlaylistModel>().removeLikedAudio;
    final addLikedAudio = context.read<PlaylistModel>().addLikedAudio;

    final fullScreenButton = Padding(
      padding: const EdgeInsets.all(8.0),
      child: YaruIconButton(
        icon: Icon(
          isFullScreen && !widget.expandHeight
              ? YaruIcons.fullscreen_exit
              : YaruIcons.fullscreen,
          color: theme.colorScheme.onSurface,
        ),
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
                  : () => liked
                      ? removeLikedAudio(model.audio!)
                      : addLikedAudio(model.audio!),
          icon: liked
              ? const Icon(YaruIcons.heart_filled)
              : const Icon(YaruIcons.heart),
        ),
        YaruIconButton(
          onPressed: model.audio?.website == null
              ? null
              : () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: TextButton(
                        child: Text(
                          'Copied to clipboard: ${model.audio?.website}',
                        ),
                        onPressed: () =>
                            launchUrl(Uri.parse(model.audio!.website!)),
                      ),
                    ),
                  ),
          icon: const Icon(YaruIcons.share),
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
                    if (model.isPlaying) {
                      model.pause();
                    } else {
                      model.playOrPause();
                    }
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
          icon: const Icon(YaruIcons.repeat_single),
          onPressed: () {},
        )
      ],
    );

    final title = Text(
      model.audio?.metadata?.title?.isNotEmpty == true
          ? model.audio!.metadata!.title!
          : (model.audio?.name ?? 'unknown'),
      style: TextStyle(
        fontWeight: FontWeight.w200,
        fontSize: isFullScreen ? 45 : 15,
        color:
            isFullScreen ? theme.colorScheme.onSurface.withOpacity(0.7) : null,
      ),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    final artist = Text(
      model.audio?.metadata?.artist ?? '',
      style: TextStyle(
        fontWeight: FontWeight.w100,
        fontSize: isFullScreen ? 25 : 15,
        color:
            isFullScreen ? theme.colorScheme.onSurface.withOpacity(0.7) : null,
      ),
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );

    bool sliderActive = model.duration != null &&
        model.position != null &&
        model.duration!.inSeconds > model.position!.inSeconds;

    final sliderAndTime = Row(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(formatTime(model.position ?? Duration.zero)),
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
                max: sliderActive
                    ? model.duration?.inSeconds.toDouble() ?? 1.0
                    : 1.0,
                value: sliderActive
                    ? model.position?.inSeconds.toDouble() ?? 0
                    : 0,
                onChanged: sliderActive
                    ? (v) async {
                        model.position = Duration(seconds: v.toInt());
                        await model.seek();
                      }
                    : null,
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(formatTime(model.duration ?? Duration.zero)),
          ],
        ),
      ],
    );

    if (isFullScreen) {
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
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            child: Image.memory(
                              model.audio!.metadata!.picture!.data,
                              height: 400.0,
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        )
                      else if (model.audio?.imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: AnimatedContainer(
                            height: 400,
                            duration: const Duration(milliseconds: 300),
                            child: Image.network(
                              filterQuality: FilterQuality.medium,
                              fit: BoxFit.cover,
                              model.audio!.imageUrl!,
                              height: 120.0,
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          width: 400,
                          height: 400,
                          child: Icon(
                            YaruIcons.music_note,
                            size: 300,
                            color: theme.hintColor.withOpacity(0.4),
                          ),
                        ),
                      controls,
                      sliderAndTime,
                      if (model.audio != null)
                        FittedBox(
                          child: title,
                        ),
                      artist,
                      const SizedBox(
                        height: 10,
                      )
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
              child: SizedBox(
                height: model.isUpNextExpanded ? 180 : 60,
                width: 250,
                child: YaruBanner(
                  onTap: () => model.isUpNextExpanded = !model.isUpNextExpanded,
                  color: theme.cardColor,
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                          top: 10,
                          bottom: 5,
                          right: 10,
                        ),
                        child: Text(
                          context.l10n.upNext,
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                      if (model.isUpNextExpanded &&
                          model.queue?.isNotEmpty == true &&
                          model.audio != null)
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.only(bottom: 10),
                            children: [
                              for (final audio in model.queue!)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                    right: 10,
                                  ),
                                  child: Text(
                                    '${audio.metadata?.title ?? ''} • ${audio.metadata?.artist ?? ''}',
                                    style:
                                        theme.textTheme.labelMedium?.copyWith(
                                      color: theme.colorScheme.onSurface,
                                      fontWeight: model.audio == audio
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                            ],
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 10,
                            right: 10,
                          ),
                          child: Text(
                            '${model.nextAudio!.metadata!.title!} • ${model.nextAudio!.metadata!.artist!}',
                            style: theme.textTheme.labelMedium
                                ?.copyWith(color: theme.colorScheme.onSurface),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        )
                    ],
                  ),
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
                  height: 120,
                  width: 120,
                  duration: const Duration(milliseconds: 300),
                  child: Image.memory(
                    filterQuality: FilterQuality.medium,
                    fit: BoxFit.cover,
                    model.audio!.metadata!.picture!.data,
                    height: 120.0,
                  ),
                )
              else if (model.audio?.imageUrl != null)
                AnimatedContainer(
                  height: 120,
                  width: 120,
                  duration: const Duration(milliseconds: 300),
                  child: Image.network(
                    filterQuality: FilterQuality.medium,
                    fit: BoxFit.cover,
                    model.audio!.imageUrl!,
                    height: 120.0,
                  ),
                )
              else
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: Icon(
                          YaruIcons.music_note,
                          size: 80,
                          color: theme.hintColor.withOpacity(0.4),
                        ),
                      ),
                    ),
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
                        height: 45,
                        child: controls,
                      ),
                      Expanded(
                        child: sliderAndTime,
                      ),
                      Expanded(
                        child: SizedBox(
                          width: width * 0.75,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(flex: 1, child: title),
                              const SizedBox(
                                width: 20,
                                child: Text(' ・'),
                              ),
                              Flexible(flex: 1, child: artist),
                            ],
                          ),
                        ),
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
