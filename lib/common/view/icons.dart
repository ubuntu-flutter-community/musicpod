import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart' hide isMobile;

import '../../extensions/taget_platform_x.dart';

class Iconz {
  static bool get useAppleIcons => isMacOS || isIOS;

  static IconData get home => isLinux
      ? YaruIcons.home
      : useAppleIcons
          ? CupertinoIcons.home
          : Icons.home_outlined;
  static IconData get homeFilled => isLinux
      ? YaruIcons.home_filled
      : useAppleIcons
          ? CupertinoIcons.home
          : Icons.home_filled;

  static IconData get image => isLinux
      ? YaruIcons.image
      : useAppleIcons
          ? CupertinoIcons.photo
          : Icons.image_not_supported;

  static IconData get warning => isLinux
      ? YaruIcons.warning_filled
      : useAppleIcons
          ? CupertinoIcons.exclamationmark_triangle_fill
          : Icons.warning_rounded;

  static IconData get menu {
    return isLinux
        ? YaruIcons.menu
        : useAppleIcons
            ? CupertinoIcons.bars
            : Icons.menu_rounded;
  }

  static IconData get export => isLinux
      ? YaruIcons.arrow_down_outlined
      : useAppleIcons
          ? CupertinoIcons.arrow_down
          : Icons.arrow_downward;

  static IconData get import => isLinux
      ? YaruIcons.arrow_up_outlined
      : useAppleIcons
          ? CupertinoIcons.arrow_up
          : Icons.arrow_upward;

  static IconData get materialSidebar => Icons.menu_rounded;

  static IconData get sidebar {
    return isLinux
        ? YaruIcons.sidebar
        : useAppleIcons
            ? CupertinoIcons.sidebar_left
            : materialSidebar;
  }

  static IconData get updateAvailable {
    return isLinux
        ? YaruIcons.update_available
        : useAppleIcons
            ? CupertinoIcons.arrow_up_circle
            : Icons.arrow_circle_up_rounded;
  }

  static IconData get remove {
    return isLinux
        ? YaruIcons.trash
        : useAppleIcons
            ? CupertinoIcons.trash
            : Icons.delete_outline_rounded;
  }

  static IconData get check => isLinux
      ? YaruIcons.checkmark
      : useAppleIcons
          ? CupertinoIcons.check_mark
          : Icons.check_rounded;
  static IconData get musicNote => isLinux
      ? YaruIcons.music_note
      : useAppleIcons
          ? CupertinoIcons.double_music_note
          : Icons.music_note_rounded;
  static IconData get artist => isLinux
      ? YaruIcons.music_artist
      : useAppleIcons
          ? CupertinoIcons.music_albums
          : Icons.interpreter_mode_outlined;
  static IconData get album => isLinux
      ? YaruIcons.disk
      : useAppleIcons
          ? CupertinoIcons.music_albums
          : Icons.album_rounded;
  static IconData get external => isLinux
      ? YaruIcons.external_link
      : useAppleIcons
          ? CupertinoIcons.link
          : Icons.link_rounded;
  static IconData get starFilled => isLinux
      ? YaruIcons.star_filled
      : useAppleIcons
          ? CupertinoIcons.star_fill
          : Icons.star_rounded;
  static IconData get star => isLinux
      ? YaruIcons.star
      : useAppleIcons
          ? CupertinoIcons.star
          : Icons.star_outline_rounded;
  static IconData get offline => isLinux
      ? YaruIcons.network_offline
      : useAppleIcons
          ? CupertinoIcons.wifi_slash
          : Icons.offline_bolt_rounded;
  static IconData get cloud => isLinux
      ? YaruIcons.cloud
      : useAppleIcons
          ? CupertinoIcons.cloud
          : Icons.cloud_outlined;
  static IconData get pause => isLinux
      ? YaruIcons.media_pause
      : useAppleIcons
          ? CupertinoIcons.pause
          : Icons.pause_rounded;

  static IconData get playFilled => isLinux
      ? YaruIcons.media_play
      : useAppleIcons
          ? CupertinoIcons.play_fill
          : Icons.play_arrow_rounded;
  static IconData get upload => isLinux
      ? YaruIcons.arrow_up_outlined
      : useAppleIcons
          ? CupertinoIcons.up_arrow
          : Icons.download_outlined;
  static IconData get download => isLinux
      ? YaruIcons.download
      : useAppleIcons
          ? CupertinoIcons.down_arrow
          : Icons.download_outlined;
  static IconData get downloadFilled => isLinux
      ? YaruIcons.download_filled
      : useAppleIcons
          ? CupertinoIcons.down_arrow
          : Icons.download_rounded;
  static IconData get podcast => isLinux
      ? YaruIcons.podcast
      : useAppleIcons
          ? CupertinoIcons.mic
          : Icons.podcasts_outlined;
  static IconData get podcastFilled => isLinux
      ? YaruIcons.podcast_filled
      : useAppleIcons
          ? CupertinoIcons.mic_fill
          : Icons.podcasts_rounded;
  static IconData get radio => isLinux
      ? YaruIcons.radio
      : useAppleIcons
          ? CupertinoIcons.antenna_radiowaves_left_right
          : Icons.radio_outlined;
  static IconData get radioFilled => isLinux
      ? YaruIcons.radio_filled
      : useAppleIcons
          ? CupertinoIcons.antenna_radiowaves_left_right
          : Icons.radio_rounded;

  static IconData get localAudio {
    if (useAppleIcons) {
      if (isMobile) {
        return CupertinoIcons.device_phone_portrait;
      }
      return CupertinoIcons.device_laptop;
    }
    return isLinux
        ? YaruIcons.drive_harddisk
        : isMobile
            ? Icons.phone_android_outlined
            : Icons.computer_rounded;
  }

  static IconData get localAudioFilled {
    if (useAppleIcons) {
      if (isMobile) {
        return CupertinoIcons.device_phone_portrait;
      }
      return CupertinoIcons.device_laptop;
    }
    return isLinux
        ? YaruIcons.drive_harddisk_filled
        : isMobile
            ? Icons.phone_android_rounded
            : Icons.computer_rounded;
  }

  static IconData get copy {
    return isLinux
        ? YaruIcons.copy
        : useAppleIcons
            ? CupertinoIcons.doc_on_clipboard
            : Icons.copy_rounded;
  }

  static IconData get explore {
    return isLinux
        ? YaruIcons.compass
        : useAppleIcons
            ? CupertinoIcons.compass
            : Icons.explore_rounded;
  }

  static IconData get drag {
    if (useAppleIcons) {
      return CupertinoIcons.move;
    }
    if (isLinux) {
      return YaruIcons.drag_handle;
    }
    return Icons.drag_handle_rounded;
  }

  static IconData get settings => isLinux
      ? YaruIcons.settings
      : useAppleIcons
          ? CupertinoIcons.settings
          : Icons.settings_outlined;

  static IconData get settingsFilled => isLinux
      ? YaruIcons.settings_filled
      : useAppleIcons
          ? CupertinoIcons.settings
          : Icons.settings;

  static IconData get addToLibrary => isLinux
      ? YaruIcons.plus
      : useAppleIcons
          ? CupertinoIcons.plus
          : Icons.add;
  static IconData get removeFromLibrary => isLinux
      ? YaruIcons.checkmark
      : useAppleIcons
          ? CupertinoIcons.check_mark
          : Icons.check;
  static IconData get refresh => isLinux
      ? YaruIcons.refresh
      : useAppleIcons
          ? CupertinoIcons.refresh
          : Icons.refresh_rounded;
  static IconData get replay => isLinux
      ? YaruIcons.revert
      : useAppleIcons
          ? CupertinoIcons.arrow_counterclockwise_circle
          : Icons.undo;
  static IconData get speakerLowFilled => isLinux
      ? YaruIcons.speaker_low_filled
      : useAppleIcons
          ? CupertinoIcons.volume_off
          : Icons.volume_down_rounded;
  static IconData get speakerMediumFilled => isLinux
      ? YaruIcons.speaker_medium_filled
      : useAppleIcons
          ? CupertinoIcons.volume_down
          : Icons.volume_down_rounded;
  static IconData get speakerHighFilled => isLinux
      ? YaruIcons.speaker_high_filled
      : useAppleIcons
          ? CupertinoIcons.volume_up
          : Icons.volume_up_rounded;
  static IconData get speakerMutedFilled => isLinux
      ? YaruIcons.speaker_muted_filled
      : useAppleIcons
          ? CupertinoIcons.volume_off
          : Icons.volume_off_rounded;
  static IconData get fullWindowExit => isLinux
      ? YaruIcons.arrow_down
      : useAppleIcons
          ? CupertinoIcons.arrow_down
          : Icons.arrow_downward_rounded;
  static IconData get fullWindow => isLinux
      ? YaruIcons.arrow_up
      : useAppleIcons
          ? CupertinoIcons.arrow_up
          : Icons.arrow_upward_rounded;
  static IconData get fullScreenExit => isLinux
      ? YaruIcons.fullscreen_exit
      : useAppleIcons
          ? CupertinoIcons.fullscreen_exit
          : Icons.fullscreen_exit_rounded;
  static IconData get fullScreen => isLinux
      ? YaruIcons.fullscreen
      : useAppleIcons
          ? CupertinoIcons.fullscreen
          : Icons.fullscreen_rounded;
  static IconData get repeatSingle => isLinux
      ? YaruIcons.repeat_single
      : useAppleIcons
          ? CupertinoIcons.repeat_1
          : Icons.repeat_one_rounded;
  static IconData get shuffle => isLinux
      ? YaruIcons.shuffle
      : useAppleIcons
          ? CupertinoIcons.shuffle
          : Icons.shuffle_rounded;
  static IconData get levelMiddle => isLinux
      ? YaruIcons.meter_middle
      : useAppleIcons
          ? CupertinoIcons.speedometer
          : Icons.speed_rounded;
  static IconData get levelHigh => isLinux
      ? YaruIcons.meter_three_quarter
      : useAppleIcons
          ? CupertinoIcons.speedometer
          : Icons.speed_rounded;
  static IconData get levelLow => isLinux
      ? YaruIcons.meter_quarter
      : useAppleIcons
          ? CupertinoIcons.speedometer
          : Icons.speed_rounded;
  static IconData get skipBackward => isLinux
      ? YaruIcons.skip_backward
      : useAppleIcons
          ? CupertinoIcons.backward_end
          : Icons.skip_previous_rounded;
  static IconData get skipForward => isLinux
      ? YaruIcons.skip_forward
      : useAppleIcons
          ? CupertinoIcons.forward_end
          : Icons.skip_next_rounded;
  static IconData get goBack => isLinux
      ? YaruIcons.go_previous
      : useAppleIcons
          ? CupertinoIcons.back
          : Icons.arrow_back_rounded;
  static IconData get goNext => isLinux
      ? YaruIcons.go_next
      : useAppleIcons
          ? CupertinoIcons.forward
          : Icons.arrow_forward_rounded;
  static IconData get forward30 => isLinux
      ? YaruIcons.redo
      : useAppleIcons
          ? CupertinoIcons.goforward_30
          : Icons.forward_30_rounded;
  static IconData get backward10 => isLinux
      ? YaruIcons.undo
      : useAppleIcons
          ? CupertinoIcons.gobackward_10
          : Icons.replay_10_rounded;
  static IconData get goUp => isLinux
      ? YaruIcons.go_up
      : useAppleIcons
          ? CupertinoIcons.up_arrow
          : Icons.arrow_upward_rounded;
  static IconData get share => isLinux
      ? YaruIcons.share
      : useAppleIcons
          ? CupertinoIcons.share
          : Icons.share;
  static IconData get startPlayList => isLinux
      ? YaruIcons.playlist_play
      : useAppleIcons
          ? CupertinoIcons.play_circle
          : Icons.playlist_play_rounded;
  static IconData get playlist => isLinux
      ? YaruIcons.playlist
      : useAppleIcons
          ? CupertinoIcons.music_note_list
          : Icons.list_rounded;
  static IconData get pen => isLinux
      ? YaruIcons.pen
      : useAppleIcons
          ? CupertinoIcons.pen
          : Icons.edit_rounded;
  static IconData get pin => isLinux
      ? YaruIcons.pin
      : useAppleIcons
          ? CupertinoIcons.pin
          : Icons.push_pin_outlined;
  static IconData get pinFilled => isLinux
      ? YaruIcons.pin
      : useAppleIcons
          ? CupertinoIcons.pin_fill
          : Icons.push_pin_rounded;
  static IconData get heart => isLinux
      ? YaruIcons.heart
      : useAppleIcons
          ? CupertinoIcons.heart
          : Icons.favorite_outline_rounded;
  static IconData get heartFilled => isLinux
      ? YaruIcons.heart_filled
      : useAppleIcons
          ? CupertinoIcons.heart_fill
          : Icons.favorite_rounded;
  static IconData get globe => isLinux
      ? YaruIcons.globe
      : useAppleIcons
          ? CupertinoIcons.globe
          : Icons.language;
  static IconData get imageMissing => isLinux
      ? YaruIcons.image_missing
      : useAppleIcons
          ? CupertinoIcons.question_diamond
          : Icons.image_not_supported_outlined;
  static IconData get imageMissingFilled => isLinux
      ? YaruIcons.image_missing_filled
      : useAppleIcons
          ? CupertinoIcons.question_diamond_fill
          : Icons.image_not_supported_rounded;
  static IconData get plus => isLinux
      ? YaruIcons.plus
      : useAppleIcons
          ? CupertinoIcons.plus
          : Icons.add_rounded;
  static IconData get search => isLinux
      ? YaruIcons.search
      : useAppleIcons
          ? CupertinoIcons.search
          : Icons.search_rounded;
  IconData? get clear => isLinux
      ? YaruIcons.edit_clear
      : useAppleIcons
          ? CupertinoIcons.clear
          : Icons.clear_rounded;
  static IconData get viewMore => isLinux
      ? YaruIcons.view_more
      : useAppleIcons
          ? CupertinoIcons.ellipsis_vertical
          : Icons.more_vert_rounded;
  static IconData get close => isLinux
      ? YaruIcons.window_close
      : useAppleIcons
          ? CupertinoIcons.clear
          : Icons.clear_rounded;
  static IconData get list => isLinux
      ? YaruIcons.unordered_list
      : useAppleIcons
          ? CupertinoIcons.list_bullet
          : Icons.list_rounded;
  static IconData get grid => isLinux
      ? YaruIcons.app_grid
      : useAppleIcons
          ? CupertinoIcons.square_grid_3x2_fill
          : Icons.grid_on_rounded;
  static IconData get move => isLinux
      ? YaruIcons.ordered_list
      : useAppleIcons
          ? CupertinoIcons.move
          : Icons.move_down_rounded;
  static IconData get materialAscending => Icons.sort_rounded;
  static IconData get ascending => isLinux
      ? YaruIcons.sort_ascending
      : useAppleIcons
          ? CupertinoIcons.sort_up
          : materialAscending;
  static IconData get descending => isLinux
      ? YaruIcons.sort_descending
      : useAppleIcons
          ? CupertinoIcons.sort_down
          : Icons.sort_rounded;
  static IconData get info => isLinux
      ? YaruIcons.information
      : useAppleIcons
          ? CupertinoIcons.info
          : Icons.info_rounded;
  static IconData get clearAll => isLinux
      ? YaruIcons.edit_clear_all
      : useAppleIcons
          ? CupertinoIcons.paintbrush
          : Icons.cleaning_services_rounded;

  static IconData get insertIntoQueue => isLinux
      ? YaruIcons.playlist_play
      : useAppleIcons
          ? CupertinoIcons.play_circle
          : Icons.playlist_add;
  static IconData get sleep => isLinux
      ? YaruIcons.clear_night
      : useAppleIcons
          ? CupertinoIcons.moon
          : Icons.mode_night_rounded;
  static IconData get markAllRead => isLinux
      ? YaruIcons.ok_filled
      : useAppleIcons
          ? CupertinoIcons.check_mark_circled_solid
          : Icons.check_circle;
  static IconData get radioHistory => isLinux
      ? YaruIcons.music_history
      : useAppleIcons
          ? CupertinoIcons.clock
          : Icons.history_rounded;
}
