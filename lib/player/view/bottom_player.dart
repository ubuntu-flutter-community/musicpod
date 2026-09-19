import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/app_manager.dart';
import '../../common/data/audio.dart';
import '../../common/data/audio_type.dart';
import '../../l10n/app_localizations.dart';
import '../../common/view/icons.dart';
import '../../common/view/share_button.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/platform_x.dart';
import '../../extensions/theme_data_x.dart';
import '../manager/player_manager.dart';
import 'bottom_player_image.dart';
import 'bottom_player_like_and_star_button.dart';
import 'playback_rate_button.dart';
import 'player_main_controls.dart';
import 'player_pause_timer_button.dart';
import 'player_title_and_artist.dart';
import 'player_track.dart';
import 'player_view.dart';
import 'stop_button.dart';
import 'volume_popup.dart';

class BottomPlayer extends StatelessWidget with WatchItMixin {
  const BottomPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final audio = watchPropertyValue((PlayerManager m) => m.audio);
    final isVideo = watchPropertyValue((PlayerManager m) => m.isVideo);
    final fullWindowMode = watchValue((AppManager m) => m.fullWindowMode);

    final active = audio != null;

    final trackAndPlayer = audio == null
        ? <Widget>[]
        : [
            PlayerTrack(active: active, bottomPlayer: true),
            Flexible(
              child: _BottomPlayerRow(
                audio: audio,
                isVideo: isVideo,
                active: active,
                fullWindowMode: fullWindowMode,
                l10n: l10n,
              ),
            ),
          ];

    return AnimatedCrossFade(
      crossFadeState: audio == null || (isVideo && fullWindowMode)
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      firstChild: const SizedBox.shrink(),
      duration: const Duration(milliseconds: 100),
      secondChild: SizedBox(
        height: bottomPlayerDefaultHeight,
        child: Column(
          children: isMobile
              ? trackAndPlayer.reversed.toList()
              : trackAndPlayer,
        ),
      ),
    );
  }
}

class _BottomPlayerRow extends StatefulWidget {
  const _BottomPlayerRow({
    required this.audio,
    required this.isVideo,
    required this.active,
    required this.fullWindowMode,
    required this.l10n,
  });

  final Audio? audio;
  final bool isVideo;
  final bool active;
  final bool fullWindowMode;
  final AppLocalizations l10n;

  @override
  State<_BottomPlayerRow> createState() => _BottomPlayerRowState();
}

class _BottomPlayerRowState extends State<_BottomPlayerRow> {
  bool? _lastCompact;
  ThemeData? _lastTheme;
  Widget? _cachedChild;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth <= kMasterDetailBreakPoint + 110;
        if (_cachedChild != null &&
            _lastCompact == compact &&
            _lastTheme == theme) {
          return _cachedChild!;
        }
        _lastCompact = compact;
        _lastTheme = theme;
        _cachedChild = _buildContent(context, compact);
        return _cachedChild!;
      },
    );
  }

  @override
  void didUpdateWidget(covariant _BottomPlayerRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audio != widget.audio ||
        oldWidget.isVideo != widget.isVideo ||
        oldWidget.active != widget.active ||
        oldWidget.fullWindowMode != widget.fullWindowMode ||
        oldWidget.l10n != widget.l10n) {
      _cachedChild = null;
    }
  }

  Widget _buildContent(BuildContext context, bool compactBottomPlayer) {
    final audio = widget.audio;
    final isVideo = widget.isVideo;
    final active = widget.active;
    final fullWindowMode = widget.fullWindowMode;
    final l10n = widget.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: kLargestSpace),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: BottomPlayerImage(
                audio: audio,
                size: bottomPlayerDefaultHeight - 24,
                isVideo: isVideo,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                const Flexible(
                  flex: 5,
                  child: PlayerTitleAndArtist(
                    playerPosition: PlayerPosition.bottom,
                  ),
                ),
                const SizedBox(width: 10),
                if (!compactBottomPlayer) const BottomPlayerLikeAndStarButton(),
              ],
            ),
          ),
          if (!compactBottomPlayer)
            Expanded(flex: 6, child: PlayerMainControls(active: active)),
          if (!compactBottomPlayer)
            Flexible(
              flex: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  StopButton(active: active),
                  if (audio?.audioType == AudioType.podcast)
                    const PlaybackRateButton(),
                  const PlayerPauseTimerButton(),
                  ShareButton(audio: audio, active: active),
                  if (!isMobile) const VolumeSliderPopup(),

                  IconButton(
                    isSelected: fullWindowMode,
                    color: fullWindowMode
                        ? context.theme.contrastyPrimary
                        : context.colorScheme.onSurface,
                    tooltip: audio == null || !audio.isRadio
                        ? l10n.queue
                        : l10n.hearingHistory,
                    icon: Icon(
                      audio == null || !audio.isRadio
                          ? Iconz.playlist
                          : Iconz.radioHistory,
                    ),
                    onPressed: di<AppManager>().toggleFullWindowMode,
                  ),
                ],
              ),
            )
          else ...[
            StopButton(active: active),
            const SizedBox(width: 10),
            PlayerMainControls(
              active: active,
              avatarPlayButton: false,
              iconColor: context.colorScheme.onSurface,
            ),
          ],
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}
