import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:yaru/constants.dart';

import '../../../common.dart';
import '../../../get.dart';
import '../../../l10n.dart';
import '../player_model.dart';
import 'full_height_player_top_controls.dart';
import 'player_main_controls.dart';
import 'player_view.dart';

class FullHeightVideoPlayer extends StatelessWidget with WatchItMixin {
  const FullHeightVideoPlayer({super.key, required this.playerViewMode});

  final PlayerViewMode playerViewMode;

  @override
  Widget build(BuildContext context) {
    const baseColor = Colors.white;

    final audio = watchPropertyValue((PlayerModel m) => m.audio);
    final playerModel = getIt<PlayerModel>();
    final isOnline = watchPropertyValue((PlayerModel m) => m.isOnline);
    final active = audio?.path != null || isOnline;

    final controls = FullHeightPlayerTopControls(
      iconColor: baseColor,
      playerViewMode: playerViewMode,
      padding: EdgeInsets.zero,
    );

    final mediaKitTheme = MaterialVideoControlsThemeData(
      seekBarThumbColor: baseColor,
      seekBarColor: baseColor.withOpacity(0.3),
      seekBarPositionColor: baseColor.withOpacity(0.9),
      seekBarBufferColor: baseColor.withOpacity(0.6),
      buttonBarButtonColor: baseColor,
      primaryButtonBar: [
        SizedBox(
          width: 300,
          child: PlayerMainControls(
            active: active,
            playPrevious: playerModel.playNext,
            playNext: playerModel.playNext,
            iconColor: baseColor,
          ),
        ),
      ],
      seekBarMargin: const EdgeInsets.all(kYaruPagePadding),
      bottomButtonBarMargin: const EdgeInsets.only(
        right: kYaruPagePadding,
        bottom: 25,
      ),
      bottomButtonBar: [
        const Spacer(),
        controls,
        Tooltip(
          message: context.l10n.leaveFullScreen,
          child: MaterialFullscreenButton(
            icon: Icon(
              Iconz().fullScreenExit,
              color: baseColor,
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
        bottomButtonBar: [
          const Spacer(),
          controls,
          Tooltip(
            message: context.l10n.fullScreen,
            child: MaterialFullscreenButton(
              icon: Icon(
                Iconz().fullScreen,
                color: baseColor,
              ),
            ),
          ),
        ],
      ),
      child: RepaintBoundary(
        child: Video(
          controller: getIt<PlayerModel>().controller,
          controls: (state) => MaterialVideoControls(state),
        ),
      ),
    );
  }
}
