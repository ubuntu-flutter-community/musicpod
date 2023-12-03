import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../globals.dart';
import '../../player.dart';
import 'up_next_bubble.dart';

class FullHeightPlayer extends StatelessWidget {
  const FullHeightPlayer({
    super.key,
    required this.audio,
    required this.nextAudio,
    required this.playPrevious,
    required this.playNext,
    required this.liked,
    required this.isStarredStation,
    required this.removeStarredStation,
    required this.addStarredStation,
    required this.removeLikedAudio,
    required this.addLikedAudio,
    this.color,
    required this.setFullScreen,
    required this.playerViewMode,
    required this.onTextTap,
    required this.videoController,
    required this.isVideo,
    required this.isOnline,
    required this.size,
  });

  final Audio? audio;
  final Audio? nextAudio;
  final Future<void> Function() playPrevious;
  final Future<void> Function() playNext;
  final bool liked;

  final bool isStarredStation;
  final void Function(String station) removeStarredStation;
  final void Function(String name, Set<Audio> stations) addStarredStation;

  final void Function(Audio audio, bool notify) removeLikedAudio;
  final void Function(Audio audio, bool notify) addLikedAudio;

  final Color? color;

  final void Function(bool?) setFullScreen;

  final PlayerViewMode playerViewMode;

  final void Function({required String text, required AudioType audioType})
      onTextTap;

  final VideoController videoController;
  final bool isVideo;
  final bool isOnline;

  final Size size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeControls = audio?.path != null || isOnline;
    final mpvMetaData = context.select((PlayerModel m) => m.mpvMetaData);

    final label = mpvMetaData?.icyTitle.isNotEmpty == true
        ? mpvMetaData!.icyTitle
        : (audio?.title?.isNotEmpty == true ? audio!.title! : '');
    final title = InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => onTitleTap(
        audio: audio,
        text: mpvMetaData?.icyTitle,
        context: context,
        onTextTap: (audioType, text) =>
            onTextTap(audioType: audioType, text: text),
      ),
      child: Tooltip(
        message: label,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: largeTextWeight,
            fontSize: 30,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
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
      playPrevious: playPrevious,
      playNext: playNext,
      isOnline: isOnline,
    );

    const sliderAndTime = PlayerTrack();

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
                  if (audio != null) title,
                  artist,
                  const SizedBox(
                    height: kYaruPagePadding,
                  ),
                  const SizedBox(
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
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: isVideo ? Colors.black.withOpacity(0.6) : null,
            ),
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
                  direction: PopoverDirection.bottom,
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
        ),
        if (nextAudio?.title != null && nextAudio?.artist != null && !isVideo)
          Positioned(
            left: 10,
            bottom: 10,
            child: size.width > 600
                ? UpNextBubble(
                    audio: audio,
                    nextAudio: nextAudio,
                  )
                : QueuePopup(audio: audio),
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
