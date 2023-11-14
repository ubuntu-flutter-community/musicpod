import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../player.dart';
import '../l10n/l10n.dart';

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
    required this.size,
    this.mpvMetaData,
  });

  final Audio? audio;
  final MpvMetaData? mpvMetaData;
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

  final Size size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final activeControls = audio?.path != null || isOnline;

    final title = InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => onTitleTap(
        audio: audio,
        title: mpvMetaData?.icyTitle,
        context: context,
        onTextTap: (audioType, text) =>
            onTextTap(audioType: audioType, text: text),
      ),
      child: Text(
        mpvMetaData?.icyTitle.isNotEmpty == true
            ? mpvMetaData!.icyTitle
            : (audio?.title?.isNotEmpty == true ? audio!.title! : ''),
        style: TextStyle(
          fontWeight: mediumTextWeight,
          fontSize: 30,
          color: theme.colorScheme.onSurface,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );

    final artist = InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => onArtistTap(
        audio: audio,
        artist: mpvMetaData?.icyName,
        context: context,
        onTextTap: (audioType, text) =>
            onTextTap(audioType: audioType, text: text),
      ),
      child: Text(
        mpvMetaData?.icyName.isNotEmpty == true
            ? mpvMetaData!.icyName
            : (audio?.artist ?? ''),
        style: TextStyle(
          fontWeight: smallTextFontWeight,
          fontSize: 20,
          color: theme.colorScheme.onSurface,
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

    final iconColor = isVideo ? Colors.white : theme.colorScheme.onSurface;
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
          SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 35,
              right: 35,
              top: size.height / 5.2,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _FullHeightPlayerImage(
                    size: size,
                    audio: audio,
                    isOnline: isOnline,
                  ),
                  const SizedBox(
                    height: kYaruPagePadding,
                  ),
                  if (audio != null)
                    FittedBox(
                      child: title,
                    ),
                  artist,
                  const SizedBox(
                    height: kYaruPagePadding,
                  ),
                  SizedBox(
                    height: kYaruPagePadding,
                    width: 400,
                    child: sliderAndTime,
                  ),
                  const SizedBox(
                    height: kYaruPagePadding,
                  ),
                  controls,
                ],
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(kYaruPagePadding),
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: 7.0,
            children: [
              LikeIconButton(
                audio: audio,
                liked: liked,
                isStarredStation: isStarredStation,
                removeStarredStation: removeStarredStation,
                addStarredStation: addStarredStation,
                removeLikedAudio: removeLikedAudio,
                addLikedAudio: addLikedAudio,
                color: iconColor,
              ),
              ShareButton(
                audio: audio,
                active: activeControls,
                color: iconColor,
              ),
              VolumeSliderPopup(
                volume: volume,
                setVolume: setVolume,
                color: iconColor,
              ),
              IconButton(
                icon: Icon(
                  playerViewMode == PlayerViewMode.fullWindow
                      ? Iconz().fullScreenExit
                      : Iconz().fullScreen,
                  color: iconColor,
                ),
                onPressed: () => setFullScreen(
                  playerViewMode == PlayerViewMode.fullWindow ? false : true,
                ),
              ),
            ],
          ),
        ),
        if (nextAudio?.title != null && nextAudio?.artist != null && !isVideo)
          Positioned(
            left: 10,
            bottom: 10,
            child: size.width > 600
                ? _UpNextBubble(
                    key: ObjectKey(queue),
                    isUpNextExpanded: isUpNextExpanded,
                    setUpNextExpanded: setUpNextExpanded,
                    queue: queue,
                    audio: audio,
                    nextAudio: nextAudio,
                  )
                : QueuePopup(
                    audio: audio,
                    queue: queue,
                  ),
          ),
      ],
    );

    return Column(
      children: [
        if (!isMobile)
          HeaderBar(
            foregroundColor: isVideo == true ? Colors.white : null,
            backgroundColor:
                isVideo == true ? Colors.black : Colors.transparent,
          ),
        Expanded(
          child: Padding(
            padding:
                isMobile ? const EdgeInsets.only(top: 40) : EdgeInsets.zero,
            child: stack,
          ),
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
    required this.size,
  });

  final Audio? audio;
  final bool isOnline;
  final Size size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    IconData iconData;
    if (audio?.audioType == AudioType.radio) {
      iconData = Iconz().radio;
    } else if (audio?.audioType == AudioType.podcast) {
      iconData = Iconz().podcast;
    } else {
      iconData = Iconz().musicNote;
    }

    Widget image;
    if (audio?.pictureData != null) {
      image = Image.memory(
        audio!.pictureData!,
        height: size.height,
        fit: BoxFit.fitWidth,
      );
    } else {
      if (!isOnline) {
        image = Icon(
          iconData,
          size: fullHeightPlayerImageSize * 0.7,
          color: theme.hintColor,
        );
      } else if (audio?.imageUrl != null || audio?.albumArtUrl != null) {
        image = SafeNetworkImage(
          url: audio?.imageUrl ?? audio?.albumArtUrl,
          filterQuality: FilterQuality.medium,
          fit: BoxFit.cover,
          fallBackIcon: Icon(
            iconData,
            size: fullHeightPlayerImageSize * 0.7,
            color: theme.hintColor,
          ),
          height: size.width,
          width: size.width,
        );
      } else {
        image = Icon(
          iconData,
          size: fullHeightPlayerImageSize * 0.7,
          color: theme.hintColor.withOpacity(0.4),
        );
      }
    }

    return SizedBox(
      height: fullHeightPlayerImageSize,
      width: fullHeightPlayerImageSize,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: image,
      ),
    );
  }
}
