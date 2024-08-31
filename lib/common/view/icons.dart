import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:yaru/yaru.dart';

import '../../extensions/build_context_x.dart';
import 'theme.dart';

class Iconz {
  static final Iconz _instance = Iconz._internal();
  factory Iconz() => _instance;

  Iconz._internal();

  IconData get menu {
    return yaruStyled
        ? YaruIcons.menu
        : appleStyled
            ? CupertinoIcons.bars
            : Icons.menu_rounded;
  }

  IconData get materialSidebar => Icons.view_sidebar_rounded;

  IconData get sidebar {
    return yaruStyled
        ? YaruIcons.sidebar
        : appleStyled
            ? CupertinoIcons.sidebar_left
            : materialSidebar;
  }

  IconData get updateAvailable {
    return yaruStyled
        ? YaruIcons.update_available
        : appleStyled
            ? CupertinoIcons.arrow_up_circle
            : Icons.arrow_circle_up_rounded;
  }

  IconData get remove {
    return yaruStyled
        ? YaruIcons.minus
        : appleStyled
            ? CupertinoIcons.minus
            : Icons.remove_rounded;
  }

  IconData get check => yaruStyled
      ? YaruIcons.checkmark
      : appleStyled
          ? CupertinoIcons.check_mark
          : Icons.check_rounded;
  IconData get musicNote => yaruStyled
      ? YaruIcons.music_note
      : appleStyled
          ? CupertinoIcons.double_music_note
          : Icons.music_note_rounded;
  IconData get external => yaruStyled
      ? YaruIcons.external_link
      : appleStyled
          ? CupertinoIcons.link
          : Icons.link_rounded;
  IconData get starFilled => yaruStyled
      ? YaruIcons.star_filled
      : appleStyled
          ? CupertinoIcons.star_fill
          : Icons.star_rounded;
  IconData get star => yaruStyled
      ? YaruIcons.star
      : appleStyled
          ? CupertinoIcons.star
          : Icons.star_outline_rounded;
  IconData get offline => yaruStyled
      ? YaruIcons.network_offline
      : appleStyled
          ? CupertinoIcons.wifi_slash
          : Icons.offline_bolt_rounded;
  IconData get cloud => yaruStyled
      ? YaruIcons.cloud
      : appleStyled
          ? CupertinoIcons.cloud
          : Icons.cloud_outlined;
  IconData get pause => yaruStyled
      ? YaruIcons.media_pause
      : appleStyled
          ? CupertinoIcons.pause
          : Icons.pause_rounded;

  IconData get playFilled => yaruStyled
      ? YaruIcons.media_play
      : appleStyled
          ? CupertinoIcons.play_fill
          : Icons.play_arrow_rounded;
  IconData get download => yaruStyled
      ? YaruIcons.download
      : appleStyled
          ? CupertinoIcons.down_arrow
          : Icons.download_outlined;
  IconData get downloadFilled => yaruStyled
      ? YaruIcons.download_filled
      : appleStyled
          ? CupertinoIcons.down_arrow
          : Icons.download_rounded;
  IconData get podcast => yaruStyled
      ? YaruIcons.podcast
      : appleStyled
          ? CupertinoIcons.mic
          : Icons.podcasts_outlined;
  IconData get podcastFilled => yaruStyled
      ? YaruIcons.podcast_filled
      : appleStyled
          ? CupertinoIcons.mic_fill
          : Icons.podcasts_rounded;
  IconData get radio => yaruStyled
      ? YaruIcons.radio
      : appleStyled
          ? CupertinoIcons.antenna_radiowaves_left_right
          : Icons.radio_outlined;
  IconData get radioFilled => yaruStyled
      ? YaruIcons.radio_filled
      : appleStyled
          ? CupertinoIcons.antenna_radiowaves_left_right
          : Icons.radio_rounded;

  IconData get localAudio {
    if (appleStyled) {
      if (isMobile) {
        return CupertinoIcons.device_phone_portrait;
      }
      return CupertinoIcons.device_laptop;
    }
    return yaruStyled
        ? YaruIcons.drive_harddisk
        : isMobile
            ? Icons.phone_android_outlined
            : Icons.computer_rounded;
  }

  IconData get localAudioFilled {
    if (appleStyled) {
      if (isMobile) {
        return CupertinoIcons.device_phone_portrait;
      }
      return CupertinoIcons.device_laptop;
    }
    return yaruStyled
        ? YaruIcons.drive_harddisk_filled
        : isMobile
            ? Icons.phone_android_rounded
            : Icons.computer_rounded;
  }

  IconData get copy {
    return yaruStyled
        ? YaruIcons.copy
        : appleStyled
            ? CupertinoIcons.doc_on_clipboard
            : Icons.copy_rounded;
  }

  IconData get explore {
    return yaruStyled
        ? YaruIcons.compass
        : appleStyled
            ? CupertinoIcons.compass
            : Icons.explore_rounded;
  }

  IconData get drag {
    if (appleStyled) {
      return CupertinoIcons.move;
    }
    if (yaruStyled) {
      return YaruIcons.drag_handle;
    }
    return Icons.drag_handle_rounded;
  }

  IconData get settings => yaruStyled
      ? YaruIcons.settings
      : appleStyled
          ? CupertinoIcons.settings
          : Icons.settings_rounded;

  IconData get addToLibrary => yaruStyled
      ? YaruIcons.bell
      : appleStyled
          ? CupertinoIcons.bell
          : Icons.notifications_outlined;
  IconData get removeFromLibrary => yaruStyled
      ? YaruIcons.bell_filled
      : appleStyled
          ? CupertinoIcons.bell_fill
          : Icons.notifications_rounded;
  IconData get refresh => yaruStyled
      ? YaruIcons.refresh
      : appleStyled
          ? CupertinoIcons.refresh
          : Icons.refresh_rounded;
  IconData get replay => yaruStyled
      ? YaruIcons.history
      : appleStyled
          ? CupertinoIcons.clock
          : Icons.history_rounded;
  IconData get speakerLowFilled => yaruStyled
      ? YaruIcons.speaker_low_filled
      : appleStyled
          ? CupertinoIcons.volume_off
          : Icons.volume_down_rounded;
  IconData get speakerMediumFilled => yaruStyled
      ? YaruIcons.speaker_medium_filled
      : appleStyled
          ? CupertinoIcons.volume_down
          : Icons.volume_down_rounded;
  IconData get speakerHighFilled => yaruStyled
      ? YaruIcons.speaker_high_filled
      : appleStyled
          ? CupertinoIcons.volume_up
          : Icons.volume_up_rounded;
  IconData get speakerMutedFilled => yaruStyled
      ? YaruIcons.speaker_muted_filled
      : appleStyled
          ? CupertinoIcons.volume_off
          : Icons.volume_off_rounded;
  IconData get fullWindowExit => yaruStyled
      ? YaruIcons.arrow_down
      : appleStyled
          ? CupertinoIcons.arrow_down
          : Icons.arrow_downward_rounded;
  IconData get fullWindow => yaruStyled
      ? YaruIcons.arrow_up
      : appleStyled
          ? CupertinoIcons.arrow_up
          : Icons.arrow_upward_rounded;
  IconData get fullScreenExit => yaruStyled
      ? YaruIcons.fullscreen_exit
      : appleStyled
          ? CupertinoIcons.fullscreen_exit
          : Icons.fullscreen_exit_rounded;
  IconData get fullScreen => yaruStyled
      ? YaruIcons.fullscreen
      : appleStyled
          ? CupertinoIcons.fullscreen
          : Icons.fullscreen_rounded;
  IconData get repeatSingle => yaruStyled
      ? YaruIcons.repeat_single
      : appleStyled
          ? CupertinoIcons.repeat_1
          : Icons.repeat_one_rounded;
  IconData get shuffle => yaruStyled
      ? YaruIcons.shuffle
      : appleStyled
          ? CupertinoIcons.shuffle
          : Icons.shuffle_rounded;
  IconData get levelMiddle => yaruStyled
      ? YaruIcons.meter_middle
      : appleStyled
          ? CupertinoIcons.speedometer
          : Icons.speed_rounded;
  IconData get levelHigh => yaruStyled
      ? YaruIcons.meter_three_quarter
      : appleStyled
          ? CupertinoIcons.speedometer
          : Icons.speed_rounded;
  IconData get levelLow => yaruStyled
      ? YaruIcons.meter_quarter
      : appleStyled
          ? CupertinoIcons.speedometer
          : Icons.speed_rounded;
  IconData get skipBackward => yaruStyled
      ? YaruIcons.skip_backward
      : appleStyled
          ? CupertinoIcons.backward_end
          : Icons.skip_previous_rounded;
  IconData get skipForward => yaruStyled
      ? YaruIcons.skip_forward
      : appleStyled
          ? CupertinoIcons.forward_end
          : Icons.skip_next_rounded;
  IconData get goBack => yaruStyled
      ? YaruIcons.go_previous
      : appleStyled
          ? CupertinoIcons.back
          : Icons.arrow_back_rounded;
  IconData get goNext => yaruStyled
      ? YaruIcons.go_next
      : appleStyled
          ? CupertinoIcons.forward
          : Icons.arrow_forward_rounded;
  IconData get forward30 => yaruStyled
      ? YaruIcons.redo
      : appleStyled
          ? CupertinoIcons.goforward_30
          : Icons.forward_30_rounded;
  IconData get backward10 => yaruStyled
      ? YaruIcons.undo
      : appleStyled
          ? CupertinoIcons.gobackward_10
          : Icons.replay_10_rounded;
  IconData get goUp => yaruStyled
      ? YaruIcons.go_up
      : appleStyled
          ? CupertinoIcons.up_arrow
          : Icons.arrow_upward_rounded;
  IconData get share => yaruStyled
      ? YaruIcons.share
      : appleStyled
          ? CupertinoIcons.share
          : Icons.share;
  IconData get startPlayList => yaruStyled
      ? YaruIcons.playlist_play
      : appleStyled
          ? CupertinoIcons.play_circle
          : Icons.playlist_play_rounded;
  IconData get playlist => yaruStyled
      ? YaruIcons.playlist
      : appleStyled
          ? CupertinoIcons.music_note_list
          : Icons.list_rounded;
  IconData get pen => yaruStyled
      ? YaruIcons.pen
      : appleStyled
          ? CupertinoIcons.pen
          : Icons.edit_rounded;
  IconData get pin => yaruStyled
      ? YaruIcons.pin
      : appleStyled
          ? CupertinoIcons.pin
          : Icons.push_pin_outlined;
  IconData get pinFilled => yaruStyled
      ? YaruIcons.pin
      : appleStyled
          ? CupertinoIcons.pin_fill
          : Icons.push_pin_rounded;
  IconData get heart => yaruStyled
      ? YaruIcons.heart
      : appleStyled
          ? CupertinoIcons.heart
          : Icons.favorite_outline_rounded;
  IconData get heartFilled => yaruStyled
      ? YaruIcons.heart_filled
      : appleStyled
          ? CupertinoIcons.heart_fill
          : Icons.favorite_rounded;
  IconData get globe => yaruStyled
      ? YaruIcons.globe
      : appleStyled
          ? CupertinoIcons.globe
          : Icons.link_rounded;
  IconData get imageMissing => yaruStyled
      ? YaruIcons.image_missing
      : appleStyled
          ? CupertinoIcons.question_diamond
          : Icons.image_not_supported_outlined;
  IconData get imageMissingFilled => yaruStyled
      ? YaruIcons.image_missing_filled
      : appleStyled
          ? CupertinoIcons.question_diamond_fill
          : Icons.image_not_supported_rounded;
  IconData get plus => yaruStyled
      ? YaruIcons.plus
      : appleStyled
          ? CupertinoIcons.plus
          : Icons.add_rounded;
  IconData get search => yaruStyled
      ? YaruIcons.search
      : appleStyled
          ? CupertinoIcons.search
          : Icons.search_rounded;
  IconData? get clear => yaruStyled
      ? YaruIcons.edit_clear
      : appleStyled
          ? CupertinoIcons.clear
          : Icons.clear_rounded;
  IconData get viewMore => yaruStyled
      ? YaruIcons.view_more
      : appleStyled
          ? CupertinoIcons.ellipsis_vertical
          : Icons.more_vert_rounded;
  IconData? get close => yaruStyled
      ? YaruIcons.window_close
      : appleStyled
          ? CupertinoIcons.clear
          : Icons.clear_rounded;
  IconData get list => yaruStyled
      ? YaruIcons.unordered_list
      : appleStyled
          ? CupertinoIcons.list_bullet
          : Icons.list_rounded;
  IconData get grid => yaruStyled
      ? YaruIcons.app_grid
      : appleStyled
          ? CupertinoIcons.square_grid_3x2_fill
          : Icons.grid_on_rounded;
  IconData get move => yaruStyled
      ? YaruIcons.ordered_list
      : appleStyled
          ? CupertinoIcons.move
          : Icons.move_down_rounded;
  IconData get materialAscending => Icons.sort_rounded;
  IconData get ascending => yaruStyled
      ? YaruIcons.sort_ascending
      : appleStyled
          ? CupertinoIcons.sort_up
          : materialAscending;
  IconData get descending => yaruStyled
      ? YaruIcons.sort_descending
      : appleStyled
          ? CupertinoIcons.sort_down
          : Icons.sort_rounded;
  IconData get info => yaruStyled
      ? YaruIcons.information
      : appleStyled
          ? CupertinoIcons.info
          : Icons.info_rounded;
  IconData get clearAll => yaruStyled
      ? YaruIcons.edit_clear_all
      : appleStyled
          ? CupertinoIcons.paintbrush
          : Icons.cleaning_services_rounded;

  IconData get insertIntoQueue => yaruStyled
      ? YaruIcons.music_queue
      : appleStyled
          ? CupertinoIcons.plus_app
          : Icons.queue_rounded;
  IconData get sleep => yaruStyled
      ? YaruIcons.clear_night
      : appleStyled
          ? CupertinoIcons.moon
          : Icons.mode_night_rounded;

  Widget getAnimatedStar(bool isStarred, [Color? color]) {
    if (yaruStyled) {
      return YaruAnimatedVectorIcon(
        isStarred ? YaruAnimatedIcons.star_filled : YaruAnimatedIcons.star,
        initialProgress: 1.0,
        color: color,
        size: iconSize,
      );
    } else {
      return isStarred
          ? Icon(
              Iconz().starFilled,
              size: iconSize,
              color: isStarred ? color : null,
            )
          : Icon(
              Iconz().star,
              size: iconSize,
              color: isStarred ? color : null,
            );
    }
  }

  Widget getAnimatedHeartIcon({required bool liked, Color? color}) {
    if (yaruStyled) {
      return YaruAnimatedVectorIcon(
        liked ? YaruAnimatedIcons.heart_filled : YaruAnimatedIcons.heart,
        initialProgress: 1.0,
        color: color,
        size: iconSize,
      );
    } else {
      return Icon(
        liked ? Icons.favorite : Icons.favorite_outline,
        color: color,
      );
    }
  }
}

double get sideBarImageSize => 38;

double get iconSize => yaruStyled
    ? kYaruIconSize
    : isMobile
        ? 24.0
        : 20.0;

IconData getIconForTag(String tag) {
  final tagsToIcons = <String, IconData>{
    'metal': TablerIcons.guitar_pick,
    'pop': TablerIcons.diamond,
  };

  return tagsToIcons[tag] ??
      (yaruStyled
          ? YaruIcons.music_note
          : appleStyled
              ? CupertinoIcons.double_music_note
              : Icons.music_note);
}

class DisconnectedServerIcon extends StatelessWidget {
  const DisconnectedServerIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.t;

    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Iconz().cloud,
          color: theme.disabledColor,
        ),
        Positioned(
          bottom: -2,
          right: -2,
          child: Icon(
            Iconz().close,
            color: theme.colorScheme.error,
            size: 16,
          ),
        ),
      ],
    );
  }
}
