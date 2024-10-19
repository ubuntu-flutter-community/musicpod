import 'dart:io';

import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/constants.dart';

import '../../app/app_model.dart';
import '../../app/connectivity_model.dart';
import '../../common/data/audio.dart';
import '../../common/view/icons.dart';
import '../../common/view/like_icon.dart';
import '../../common/view/share_button.dart';
import '../../common/view/snackbars.dart';
import '../../constants.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../player/player_model.dart';
import 'playback_rate_button.dart';
import 'player_view.dart';
import 'queue_button.dart';
import 'volume_popup.dart';

class FullHeightPlayerTopControls extends StatelessWidget with WatchItMixin {
  const FullHeightPlayerTopControls({
    super.key,
    required this.iconColor,
    required this.playerPosition,
    this.padding,
  });

  final Color iconColor;
  final PlayerPosition playerPosition;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final audio = watchPropertyValue((PlayerModel m) => m.audio);
    final showQueueButton = watchPropertyValue(
      (PlayerModel m) =>
          m.queue.length > 1 || audio?.audioType == AudioType.local,
    );
    final playerToTheRight = context.mediaQuerySize.width > kSideBarThreshHold;
    final fullScreen = watchPropertyValue((AppModel m) => m.fullWindowMode);
    final appModel = di<AppModel>();
    final isOnline = watchPropertyValue((ConnectivityModel m) => m.isOnline);
    final active = audio?.path != null || isOnline;

    return Padding(
      padding: padding ??
          EdgeInsets.only(
            right: kYaruPagePadding,
            top: Platform.isMacOS ? 0 : kYaruPagePadding,
          ),
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: 5.0,
        children: [
          if (watchStream((PlayerModel m) => m.onlineArtError).data != null &&
              audio?.audioType == AudioType.radio)
            IconButton(
              tooltip: context.l10n.onlineArtError,
              onPressed: () => showSnackBar(
                context: context,
                snackBar: SnackBar(content: Text(context.l10n.onlineArtError)),
              ),
              icon: Icon(
                Iconz.warning,
                color: context.theme.colorScheme.onSurface,
              ),
            ),
          if (audio?.audioType != AudioType.podcast)
            switch (audio?.audioType) {
              AudioType.local => LikeIcon(
                  audio: audio,
                  color: context.theme.colorScheme.onSurface,
                ),
              AudioType.radio => RadioLikeIcon(audio: audio),
              _ => const SizedBox.shrink(),
            },
          if (showQueueButton) QueueButton(color: iconColor),
          ShareButton(
            audio: audio,
            active: active,
            color: iconColor,
          ),
          if (audio?.audioType == AudioType.podcast)
            PlaybackRateButton(
              active: active,
              color: iconColor,
            ),
          VolumeSliderPopup(color: iconColor),
          IconButton(
            tooltip: playerPosition == PlayerPosition.fullWindow
                ? context.l10n.leaveFullWindow
                : context.l10n.fullWindow,
            icon: Icon(
              playerPosition == PlayerPosition.fullWindow
                  ? Iconz.fullWindowExit
                  : Iconz.fullWindow,
              color: iconColor,
            ),
            onPressed: () {
              appModel.setFullWindowMode(
                playerPosition == PlayerPosition.fullWindow ? false : true,
              );

              appModel.setShowWindowControls(
                (fullScreen == true && playerToTheRight) ? false : true,
              );
            },
          ),
        ],
      ),
    );
  }
}
