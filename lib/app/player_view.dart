import 'package:flutter/material.dart';
import 'package:musicpod/app/common/safe_network_image.dart';
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
  Widget build(BuildContext context) {
    final audio = context.select((PlayerModel m) => m.audio);
    final nextAudio = context.select((PlayerModel m) => m.nextAudio);
    final queue = context.select((PlayerModel m) => m.queue);
    final repeatSingle = context.select((PlayerModel m) => m.repeatSingle);
    final setRepeatSingle = context.read<PlayerModel>().setRepeatSingle;
    final shuffle = context.select((PlayerModel m) => m.shuffle);
    final setShuffle = context.read<PlayerModel>().setShuffle;
    final position = context.select((PlayerModel m) => m.position);
    final setPosition = context.read<PlayerModel>().setPosition;
    final duration = context.select((PlayerModel m) => m.duration);
    final color = context.select((PlayerModel m) => m.color);

    final isUpNextExpanded =
        context.select((PlayerModel m) => m.isUpNextExpanded);
    final setUpNextExpanded = context.read<PlayerModel>().setUpNextExpanded;
    final isPlaying = context.select((PlayerModel m) => m.isPlaying);
    final fullScreen = context.select((PlayerModel m) => m.fullScreen);
    final setFullScreen = context.read<PlayerModel>().setFullScreen;
    final playPrevious = context.read<PlayerModel>().playPrevious;
    final playNext = context.read<PlayerModel>().playNext;
    final seek = context.read<PlayerModel>().seek;
    final pause = context.read<PlayerModel>().pause;
    final playOrPause = context.read<PlayerModel>().playOrPause;

    final liked =
        audio == null ? false : context.read<PlaylistModel>().liked(audio);
    final theme = Theme.of(context);
    final isFullScreen = widget.expandHeight || fullScreen == true;
    final width = MediaQuery.of(context).size.width;
    final removeLikedAudio = context.read<PlaylistModel>().removeLikedAudio;
    final addLikedAudio = context.read<PlaylistModel>().addLikedAudio;

    final fullScreenButton = YaruIconButton(
      icon: Icon(
        isFullScreen && !widget.expandHeight
            ? YaruIcons.fullscreen_exit
            : YaruIcons.fullscreen,
        color: theme.colorScheme.onSurface,
      ),
      onPressed: () => setFullScreen(!(fullScreen ?? false)),
    );

    final controls = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        YaruIconButton(
          onPressed: audio == null || audio.audioType == AudioType.radio
              ? null
              : () => liked ? removeLikedAudio(audio) : addLikedAudio(audio),
          icon: liked
              ? const Icon(YaruIcons.heart_filled)
              : const Icon(YaruIcons.heart),
        ),
        YaruIconButton(
          onPressed: audio?.website == null
              ? null
              : () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: TextButton(
                        child: Text(
                          'Copied to clipboard: ${audio?.website}',
                        ),
                        onPressed: () => launchUrl(Uri.parse(audio!.website!)),
                      ),
                    ),
                  ),
          icon: const Icon(YaruIcons.share),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: YaruIconButton(
            onPressed: () => playPrevious(),
            icon: const Icon(YaruIcons.skip_backward),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: YaruIconButton(
            onPressed: audio == null
                ? null
                : () {
                    if (isPlaying) {
                      pause();
                    } else {
                      playOrPause();
                    }
                  },
            icon: Icon(
              isPlaying ? YaruIcons.media_pause : YaruIcons.media_play,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: YaruIconButton(
            onPressed: () => playNext(),
            icon: const Icon(YaruIcons.skip_forward),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: YaruIconButton(
            icon: Icon(
              YaruIcons.repeat_single,
              color: theme.colorScheme.onSurface,
            ),
            isSelected: repeatSingle == true,
            onPressed: () => setRepeatSingle(!(repeatSingle)),
          ),
        ),
        YaruIconButton(
          icon: Icon(
            YaruIcons.shuffle,
            color: theme.colorScheme.onSurface,
          ),
          isSelected: shuffle,
          onPressed: () => setShuffle(!(shuffle)),
        )
      ],
    );

    final title = Text(
      audio?.title?.isNotEmpty == true ? audio!.title! : 'unknown',
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
      audio?.artist ?? '',
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

    bool sliderActive = duration != null &&
        position != null &&
        duration.inSeconds > position.inSeconds;

    final sliderAndTime = Row(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(formatTime(position ?? Duration.zero)),
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
                inactiveTrackColor: color != null
                    ? theme.colorScheme.onSurface.withOpacity(0.35)
                    : theme.primaryColor.withOpacity(0.5),
                activeTrackColor: color != null
                    ? theme.colorScheme.onSurface.withOpacity(0.8)
                    : theme.primaryColor,
                overlayColor: color?.withOpacity(0.3) ??
                    theme.primaryColor.withOpacity(0.5),
              ),
              child: Slider(
                min: 0,
                max: sliderActive ? duration.inSeconds.toDouble() : 1.0,
                value: sliderActive ? position.inSeconds.toDouble() : 0,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(formatTime(duration ?? Duration.zero)),
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
                      if (audio?.pictureData != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            child: Image.memory(
                              audio!.pictureData!,
                              height: 400.0,
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        )
                      else if (audio?.imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            height: 400,
                            child: SafeNetworkImage(
                              url: audio!.imageUrl!,
                              filterQuality: FilterQuality.medium,
                              fit: BoxFit.cover,
                              fallBackIcon: Icon(
                                YaruIcons.music_note,
                                size: 200,
                                color: theme.hintColor,
                              ),
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
                      if (audio != null)
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
          if (nextAudio?.title != null && nextAudio?.artist != null)
            Positioned(
              left: 10,
              bottom: 10,
              child: SizedBox(
                height: isUpNextExpanded ? 180 : 60,
                width: 250,
                child: YaruBanner(
                  onTap: () => setUpNextExpanded(!isUpNextExpanded),
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
                      if (isUpNextExpanded &&
                          queue?.isNotEmpty == true &&
                          audio != null)
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.only(bottom: 10),
                            children: [
                              for (final audio in queue!)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                    right: 10,
                                  ),
                                  child: Text(
                                    '${audio.title ?? ''} • ${audio.artist ?? ''}',
                                    style:
                                        theme.textTheme.labelMedium?.copyWith(
                                      color: theme.colorScheme.onSurface,
                                      fontWeight: audio == audio
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
                            '${nextAudio!.title!} • ${nextAudio.artist!}',
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
          Positioned(top: 12, right: 20, child: fullScreenButton),
          Row(
            children: [
              if (audio?.pictureData != null)
                AnimatedContainer(
                  height: 120,
                  width: 120,
                  duration: const Duration(milliseconds: 300),
                  child: Image.memory(
                    filterQuality: FilterQuality.medium,
                    fit: BoxFit.cover,
                    audio!.pictureData!,
                    height: 120.0,
                  ),
                )
              else if (audio?.imageUrl != null)
                SizedBox(
                  height: 120,
                  width: 120,
                  child: SafeNetworkImage(
                    url: audio!.imageUrl!,
                    filterQuality: FilterQuality.medium,
                    fit: BoxFit.cover,
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
