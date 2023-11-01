import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:musicpod/app/common/safe_network_image.dart';
import 'package:musicpod/app/globals.dart';
import 'package:musicpod/app/player/full_height_player_controls.dart';
import 'package:musicpod/app/player/player_track.dart';
import 'package:musicpod/app/player/player_view.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class FullHeightPlayer extends StatelessWidget {
  const FullHeightPlayer({
    super.key,
    required this.audio,
    required this.nextAudio,
    required this.queue,
    required this.isUpNextExpanded,
    required this.setUpNextExpanded,
    required this.repeatSingle,
    required this.setRepeatSingle,
    required this.shuffle,
    required this.setShuffle,
    required this.isPlaying,
    required this.playPrevious,
    required this.playNext,
    required this.pause,
    required this.playOrPause,
    required this.liked,
    required this.isStarredStation,
    required this.removeStarredStation,
    required this.addStarredStation,
    required this.removeLikedAudio,
    required this.addLikedAudio,
    this.color,
    this.duration,
    this.position,
    required this.setPosition,
    required this.seek,
    required this.setFullScreen,
    required this.playerViewMode,
    required this.onTextTap,
    required this.volume,
    required this.setVolume,
    required this.videoController,
    required this.isVideo,
    required this.isOnline,
    this.icyTitle,
    this.icyName,
  });

  final Audio? audio;
  final String? icyTitle;
  final String? icyName;
  final Audio? nextAudio;
  final List<Audio> queue;
  final bool isUpNextExpanded;
  final void Function(bool value) setUpNextExpanded;
  final bool repeatSingle;
  final void Function(bool) setRepeatSingle;
  final bool shuffle;
  final void Function(bool) setShuffle;
  final bool isPlaying;
  final Future<void> Function() playPrevious;
  final Future<void> Function() playNext;
  final Future<void> Function() pause;
  final Future<void> Function() playOrPause;
  final bool liked;

  final bool isStarredStation;
  final void Function(String station) removeStarredStation;
  final void Function(String name, Set<Audio> stations) addStarredStation;

  final void Function(Audio audio, bool notify) removeLikedAudio;
  final void Function(Audio audio, bool notify) addLikedAudio;

  final Color? color;
  final Duration? duration;
  final Duration? position;
  final void Function(Duration?) setPosition;
  final Future<void> Function() seek;

  final void Function(bool?) setFullScreen;

  final PlayerViewMode playerViewMode;

  final void Function({required String text, required AudioType audioType})
      onTextTap;

  final double volume;
  final Future<void> Function(double value) setVolume;

  final VideoController videoController;
  final bool isVideo;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final title = InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: audio?.audioType == null ||
              audio?.title == null ||
              audio?.audioType == AudioType.podcast
          ? null
          : () {
              setFullScreen(false);
              navigatorKey.currentState?.maybePop();
              onTextTap(text: audio!.title!, audioType: audio!.audioType!);
            },
      child: Text(
        icyTitle?.isNotEmpty == true
            ? icyTitle!
            : (audio?.title?.isNotEmpty == true ? audio!.title! : ''),
        style: TextStyle(
          fontWeight: FontWeight.w200,
          fontSize: 30,
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );

    final artist = InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: audio?.audioType == null || audio?.artist == null
          ? null
          : () {
              setFullScreen(false);
              navigatorKey.currentState?.maybePop();
              onTextTap(text: audio!.artist!, audioType: audio!.audioType!);
            },
      child: Text(
        icyName?.isNotEmpty == true ? icyName! : (audio?.artist ?? ''),
        style: TextStyle(
          fontWeight: FontWeight.w100,
          fontSize: 20,
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );

    final controls = FullHeightPlayerControls(
      audio: audio,
      setRepeatSingle: setRepeatSingle,
      repeatSingle: repeatSingle,
      shuffle: shuffle,
      setShuffle: setShuffle,
      isPlaying: isPlaying,
      playPrevious: playPrevious,
      playNext: playNext,
      pause: pause,
      playOrPause: playOrPause,
      liked: liked,
      isStarredStation: isStarredStation,
      addStarredStation: addStarredStation,
      removeStarredStation: removeStarredStation,
      addLikedAudio: addLikedAudio,
      removeLikedAudio: removeLikedAudio,
      volume: volume,
      setVolume: setVolume,
      queue: queue,
      isOnline: isOnline,
    );

    final sliderAndTime = PlayerTrack(
      color: color,
      duration: duration,
      position: position,
      setPosition: setPosition,
      seek: seek,
    );

    final stack = Stack(
      alignment: Alignment.topRight,
      children: [
        if (isVideo)
          RepaintBoundary(
            child: Video(
              controller: videoController,
            ),
          )
        else
          Center(
            child: SingleChildScrollView(
              child: SizedBox(
                height: 700,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 40,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        height: 400,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: _FullHeightPlayerImage(
                            audio: audio,
                            isOnline: isOnline,
                          ),
                        ),
                      ),
                      controls,
                      SizedBox(
                        width: 600,
                        height: 20,
                        child: sliderAndTime,
                      ),
                      if (audio != null)
                        FittedBox(
                          child: title,
                        ),
                      artist,
                    ],
                  ),
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(kYaruPagePadding),
          child: IconButton(
            icon: Icon(
              playerViewMode == PlayerViewMode.fullWindow
                  ? YaruIcons.fullscreen_exit
                  : YaruIcons.fullscreen,
              color: isVideo ? Colors.white : theme.colorScheme.onSurface,
            ),
            onPressed: () => setFullScreen(
              playerViewMode == PlayerViewMode.fullWindow ? false : true,
            ),
          ),
        ),
        if (nextAudio?.title != null && nextAudio?.artist != null && !isVideo)
          Positioned(
            left: 10,
            bottom: 10,
            child: _UpNextBubble(
              key: ObjectKey(queue),
              isUpNextExpanded: isUpNextExpanded,
              setUpNextExpanded: setUpNextExpanded,
              queue: queue,
              audio: audio,
              nextAudio: nextAudio,
            ),
          ),
      ],
    );

    return Column(
      children: [
        YaruWindowTitleBar(
          border: BorderSide.none,
          foregroundColor: isVideo == true ? Colors.white : null,
          backgroundColor: isVideo == true ? Colors.black : Colors.transparent,
        ),
        Expanded(
          child: stack,
        ),
      ],
    );
  }
}

class _UpNextBubble extends StatelessWidget {
  const _UpNextBubble({
    super.key,
    required this.isUpNextExpanded,
    required this.setUpNextExpanded,
    required this.queue,
    required this.audio,
    required this.nextAudio,
  });

  final bool isUpNextExpanded;
  final void Function(bool value) setUpNextExpanded;
  final List<Audio>? queue;
  final Audio? audio;
  final Audio? nextAudio;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
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
            if (isUpNextExpanded && queue?.isNotEmpty == true && audio != null)
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 10),
                  children: [
                    for (final e in queue!)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                          right: 10,
                        ),
                        child: Text(
                          '${e.title ?? ''} • ${e.artist ?? ''}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: e == audio
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
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
                  '${nextAudio!.title!} • ${nextAudio?.artist!}',
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: theme.colorScheme.onSurface),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FullHeightPlayerImage extends StatelessWidget {
  const _FullHeightPlayerImage({
    this.audio,
    required this.isOnline,
  });

  final Audio? audio;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    IconData iconData;
    if (audio?.audioType == AudioType.radio) {
      iconData = YaruIcons.radio;
    } else if (audio?.audioType == AudioType.podcast) {
      iconData = YaruIcons.podcast;
    } else {
      iconData = YaruIcons.music_note;
    }

    Widget image;
    if (audio?.pictureData != null) {
      image = Image.memory(
        audio!.pictureData!,
        height: 400.0,
        fit: BoxFit.fitHeight,
      );
    } else {
      if (!isOnline) {
        image = SizedBox(
          child: Icon(
            iconData,
            size: 200,
            color: theme.hintColor,
          ),
        );
      } else if (audio?.imageUrl != null || audio?.albumArtUrl != null) {
        image = SafeNetworkImage(
          url: audio?.imageUrl ?? audio?.albumArtUrl,
          filterQuality: FilterQuality.medium,
          fit: BoxFit.fitHeight,
          fallBackIcon: Icon(
            iconData,
            size: 200,
            color: theme.hintColor,
          ),
        );
      } else {
        image = SizedBox(
          width: 400,
          height: 400,
          child: Icon(
            iconData,
            size: 300,
            color: theme.hintColor.withOpacity(0.4),
          ),
        );
      }
    }
    return image;
  }
}
