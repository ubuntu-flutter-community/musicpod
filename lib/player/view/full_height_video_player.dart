import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:watch_it/watch_it.dart';

import '../../app_config.dart';
import '../../common/data/audio.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/icons.dart';
import '../../common/view/progress.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/taget_platform_x.dart';
import '../../l10n/l10n.dart';
import '../player_model.dart';
import 'full_height_player_top_controls.dart';
import 'player_main_controls.dart';
import 'player_view.dart';

class FullHeightVideoPlayer extends StatelessWidget {
  const FullHeightVideoPlayer({
    super.key,
    required this.playerPosition,
    this.audio,
    required this.controlsActive,
  });

  final PlayerPosition playerPosition;
  final Audio? audio;
  final bool controlsActive;

  @override
  Widget build(BuildContext context) {
    const baseColor = Colors.white;

    final text = audio?.audioType == AudioType.radio
        ? audio?.title ?? ''
        : '${audio?.title == null ? '' : '${audio!.title}'} - ${audio?.album == null ? '' : '${audio!.album}'} - ${audio?.artist == null ? '' : '${audio!.artist}'}';
    final mediaKitTheme = MaterialVideoControlsThemeData(
      seekBarThumbColor: baseColor,
      seekBarColor: baseColor.withValues(alpha: 0.3),
      seekBarPositionColor: baseColor.withValues(alpha: 0.9),
      seekBarBufferColor: baseColor.withValues(alpha: 0.6),
      buttonBarButtonColor: baseColor,
      controlsHoverDuration: const Duration(seconds: 10),
      seekGesture: true,
      seekOnDoubleTap: true,
      bufferingIndicatorBuilder: (context) =>
          const Center(child: Progress(color: baseColor)),
      primaryButtonBar: [
        SizedBox(
          width: 300,
          child: PlayerMainControls(
            active: controlsActive,
            iconColor: baseColor,
            avatarColor: baseColor.withValues(alpha: 0.1),
          ),
        ),
      ],
      seekBarMargin: const EdgeInsets.all(kLargestSpace),
      topButtonBarMargin: EdgeInsets.only(
        right: kLargestSpace,
        top: isMobile ? 2 * kLargestSpace : 0,
      ),
      topButtonBar: _buildTopButtonBar(
        baseColor: baseColor,
        context: context,
        icon: Iconz.fullScreenExit,
      ),
      bottomButtonBarMargin: const EdgeInsets.all(20),
      bottomButtonBar: [
        Flexible(
          child: Tooltip(
            margin: const EdgeInsets.symmetric(horizontal: kLargestSpace),
            message: text,
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: baseColor),
            ),
          ),
        ),
      ],
      padding: const EdgeInsets.all(20),
    );

    return MaterialVideoControlsTheme(
      key: ValueKey(audio?.url),
      fullscreen: mediaKitTheme,
      normal: mediaKitTheme.copyWith(
        topButtonBar: _buildTopButtonBar(
          baseColor: baseColor,
          context: context,
          icon: Iconz.fullScreen,
        ),
      ),
      child: SimpleFullHeightVideoPlayer(
        controls: (state) => MaterialVideoControls(state),
      ),
    );
  }

  List<Widget> _buildTopButtonBar({
    required Color baseColor,
    required BuildContext context,
    required IconData icon,
  }) => [
    const Spacer(),
    FullHeightPlayerTopControls(
      iconColor: baseColor,
      playerPosition: playerPosition,
      padding: EdgeInsets.zero,
    ),
    if (AppConfig.allowVideoFullScreen)
      Tooltip(
        message: context.l10n.fullScreen,
        child: MaterialFullscreenButton(icon: Icon(icon, color: baseColor)),
      ),
  ];
}

class SimpleFullHeightVideoPlayer extends StatelessWidget {
  const SimpleFullHeightVideoPlayer({super.key, this.controls});

  final Widget Function(VideoState)? controls;

  @override
  Widget build(BuildContext context) => Padding(
    padding: context.isPortrait && isMobile
        ? const EdgeInsets.only(bottom: 40)
        : EdgeInsets.zero,
    child: Video(controller: di<PlayerModel>().controller, controls: controls),
  );
}
