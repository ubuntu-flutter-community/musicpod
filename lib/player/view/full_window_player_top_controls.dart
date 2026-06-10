import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../app/app_manager.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/icons.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/taget_platform_x.dart';
import '../player_manager.dart';
import 'playback_rate_button.dart';
import 'player_pause_timer_button.dart';
import 'volume_popup.dart';

class FullWindowPlayerTopControls extends StatelessWidget with WatchItMixin {
  const FullWindowPlayerTopControls({
    super.key,
    required this.iconColor,
    this.padding,
    this.video = false,
  });

  final Color iconColor;
  final EdgeInsetsGeometry? padding;
  final bool video;

  @override
  Widget build(BuildContext context) {
    final audio = watchPropertyValue((PlayerManager m) => m.audio);

    final isFullScreen = isFullscreen(context);

    return Padding(
      padding: padding ?? playerTopControlsPadding,
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: 5.0,
        children: [
          if (audio?.audioType == AudioType.podcast && video)
            PlaybackRateButton(color: iconColor),
          if (video && !isMobile) VolumeSliderPopup(color: iconColor),
          if (video) PlayerPauseTimerButton(iconColor: iconColor),
          if (!isMobile && !isFullScreen)
            IconButton(
              tooltip: context.l10n.leaveFullWindow,
              icon: Icon(Iconz.fullWindowExit, color: iconColor),
              onPressed: () => di<AppManager>().setFullWindowMode(false),
            ),
        ],
      ),
    );
  }
}
