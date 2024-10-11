import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import 'theme.dart';

class Iconz {
  static IconData get warning => yaruStyled
      ? YaruIcons.warning_filled
      : appleStyled
          ? CupertinoIcons.exclamationmark_triangle_fill
          : Icons.warning_rounded;

  static IconData get menu {
    return yaruStyled
        ? YaruIcons.menu
        : appleStyled
            ? CupertinoIcons.bars
            : Icons.menu_rounded;
  }

  static IconData get materialSidebar => Icons.view_sidebar_rounded;

  static IconData get sidebar {
    return yaruStyled
        ? YaruIcons.sidebar
        : appleStyled
            ? CupertinoIcons.sidebar_left
            : materialSidebar;
  }

  static IconData get updateAvailable {
    return yaruStyled
        ? YaruIcons.update_available
        : appleStyled
            ? CupertinoIcons.arrow_up_circle
            : Icons.arrow_circle_up_rounded;
  }

  static IconData get remove {
    return yaruStyled
        ? YaruIcons.minus
        : appleStyled
            ? CupertinoIcons.minus
            : Icons.remove_rounded;
  }

  static IconData get check => yaruStyled
      ? YaruIcons.checkmark
      : appleStyled
          ? CupertinoIcons.check_mark
          : Icons.check_rounded;
  static IconData get musicNote => yaruStyled
      ? YaruIcons.music_note
      : appleStyled
          ? CupertinoIcons.double_music_note
          : Icons.music_note_rounded;
  static IconData get external => yaruStyled
      ? YaruIcons.external_link
      : appleStyled
          ? CupertinoIcons.link
          : Icons.link_rounded;
  static IconData get starFilled => yaruStyled
      ? YaruIcons.star_filled
      : appleStyled
          ? CupertinoIcons.star_fill
          : Icons.star_rounded;
  static IconData get star => yaruStyled
      ? YaruIcons.star
      : appleStyled
          ? CupertinoIcons.star
          : Icons.star_outline_rounded;
  static IconData get offline => yaruStyled
      ? YaruIcons.network_offline
      : appleStyled
          ? CupertinoIcons.wifi_slash
          : Icons.offline_bolt_rounded;
  static IconData get cloud => yaruStyled
      ? YaruIcons.cloud
      : appleStyled
          ? CupertinoIcons.cloud
          : Icons.cloud_outlined;
  static IconData get pause => yaruStyled
      ? YaruIcons.media_pause
      : appleStyled
          ? CupertinoIcons.pause
          : Icons.pause_rounded;

  static IconData get playFilled => yaruStyled
      ? YaruIcons.media_play
      : appleStyled
          ? CupertinoIcons.play_fill
          : Icons.play_arrow_rounded;
  static IconData get download => yaruStyled
      ? YaruIcons.download
      : appleStyled
          ? CupertinoIcons.down_arrow
          : Icons.download_outlined;
  static IconData get downloadFilled => yaruStyled
      ? YaruIcons.download_filled
      : appleStyled
          ? CupertinoIcons.down_arrow
          : Icons.download_rounded;
  static IconData get podcast => yaruStyled
      ? YaruIcons.podcast
      : appleStyled
          ? CupertinoIcons.mic
          : Icons.podcasts_outlined;
  static IconData get podcastFilled => yaruStyled
      ? YaruIcons.podcast_filled
      : appleStyled
          ? CupertinoIcons.mic_fill
          : Icons.podcasts_rounded;
  static IconData get radio => yaruStyled
      ? YaruIcons.radio
      : appleStyled
          ? CupertinoIcons.antenna_radiowaves_left_right
          : Icons.radio_outlined;
  static IconData get radioFilled => yaruStyled
      ? YaruIcons.radio_filled
      : appleStyled
          ? CupertinoIcons.antenna_radiowaves_left_right
          : Icons.radio_rounded;

  static IconData get localAudio {
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

  static IconData get localAudioFilled {
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

  static IconData get copy {
    return yaruStyled
        ? YaruIcons.copy
        : appleStyled
            ? CupertinoIcons.doc_on_clipboard
            : Icons.copy_rounded;
  }

  static IconData get explore {
    return yaruStyled
        ? YaruIcons.compass
        : appleStyled
            ? CupertinoIcons.compass
            : Icons.explore_rounded;
  }

  static IconData get drag {
    if (appleStyled) {
      return CupertinoIcons.move;
    }
    if (yaruStyled) {
      return YaruIcons.drag_handle;
    }
    return Icons.drag_handle_rounded;
  }

  static IconData get settings => yaruStyled
      ? YaruIcons.settings
      : appleStyled
          ? CupertinoIcons.settings
          : Icons.settings_rounded;

  static IconData get addToLibrary => yaruStyled
      ? YaruIcons.bell
      : appleStyled
          ? CupertinoIcons.bell
          : Icons.notifications_outlined;
  static IconData get removeFromLibrary => yaruStyled
      ? YaruIcons.bell_filled
      : appleStyled
          ? CupertinoIcons.bell_fill
          : Icons.notifications_rounded;
  static IconData get refresh => yaruStyled
      ? YaruIcons.refresh
      : appleStyled
          ? CupertinoIcons.refresh
          : Icons.refresh_rounded;
  static IconData get replay => yaruStyled
      ? YaruIcons.history
      : appleStyled
          ? CupertinoIcons.clock
          : Icons.history_rounded;
  static IconData get speakerLowFilled => yaruStyled
      ? YaruIcons.speaker_low_filled
      : appleStyled
          ? CupertinoIcons.volume_off
          : Icons.volume_down_rounded;
  static IconData get speakerMediumFilled => yaruStyled
      ? YaruIcons.speaker_medium_filled
      : appleStyled
          ? CupertinoIcons.volume_down
          : Icons.volume_down_rounded;
  static IconData get speakerHighFilled => yaruStyled
      ? YaruIcons.speaker_high_filled
      : appleStyled
          ? CupertinoIcons.volume_up
          : Icons.volume_up_rounded;
  static IconData get speakerMutedFilled => yaruStyled
      ? YaruIcons.speaker_muted_filled
      : appleStyled
          ? CupertinoIcons.volume_off
          : Icons.volume_off_rounded;
  static IconData get fullWindowExit => yaruStyled
      ? YaruIcons.arrow_down
      : appleStyled
          ? CupertinoIcons.arrow_down
          : Icons.arrow_downward_rounded;
  static IconData get fullWindow => yaruStyled
      ? YaruIcons.arrow_up
      : appleStyled
          ? CupertinoIcons.arrow_up
          : Icons.arrow_upward_rounded;
  static IconData get fullScreenExit => yaruStyled
      ? YaruIcons.fullscreen_exit
      : appleStyled
          ? CupertinoIcons.fullscreen_exit
          : Icons.fullscreen_exit_rounded;
  static IconData get fullScreen => yaruStyled
      ? YaruIcons.fullscreen
      : appleStyled
          ? CupertinoIcons.fullscreen
          : Icons.fullscreen_rounded;
  static IconData get repeatSingle => yaruStyled
      ? YaruIcons.repeat_single
      : appleStyled
          ? CupertinoIcons.repeat_1
          : Icons.repeat_one_rounded;
  static IconData get shuffle => yaruStyled
      ? YaruIcons.shuffle
      : appleStyled
          ? CupertinoIcons.shuffle
          : Icons.shuffle_rounded;
  static IconData get levelMiddle => yaruStyled
      ? YaruIcons.meter_middle
      : appleStyled
          ? CupertinoIcons.speedometer
          : Icons.speed_rounded;
  static IconData get levelHigh => yaruStyled
      ? YaruIcons.meter_three_quarter
      : appleStyled
          ? CupertinoIcons.speedometer
          : Icons.speed_rounded;
  static IconData get levelLow => yaruStyled
      ? YaruIcons.meter_quarter
      : appleStyled
          ? CupertinoIcons.speedometer
          : Icons.speed_rounded;
  static IconData get skipBackward => yaruStyled
      ? YaruIcons.skip_backward
      : appleStyled
          ? CupertinoIcons.backward_end
          : Icons.skip_previous_rounded;
  static IconData get skipForward => yaruStyled
      ? YaruIcons.skip_forward
      : appleStyled
          ? CupertinoIcons.forward_end
          : Icons.skip_next_rounded;
  static IconData get goBack => yaruStyled
      ? YaruIcons.go_previous
      : appleStyled
          ? CupertinoIcons.back
          : Icons.arrow_back_rounded;
  static IconData get goNext => yaruStyled
      ? YaruIcons.go_next
      : appleStyled
          ? CupertinoIcons.forward
          : Icons.arrow_forward_rounded;
  static IconData get forward30 => yaruStyled
      ? YaruIcons.redo
      : appleStyled
          ? CupertinoIcons.goforward_30
          : Icons.forward_30_rounded;
  static IconData get backward10 => yaruStyled
      ? YaruIcons.undo
      : appleStyled
          ? CupertinoIcons.gobackward_10
          : Icons.replay_10_rounded;
  static IconData get goUp => yaruStyled
      ? YaruIcons.go_up
      : appleStyled
          ? CupertinoIcons.up_arrow
          : Icons.arrow_upward_rounded;
  static IconData get share => yaruStyled
      ? YaruIcons.share
      : appleStyled
          ? CupertinoIcons.share
          : Icons.share;
  static IconData get startPlayList => yaruStyled
      ? YaruIcons.playlist_play
      : appleStyled
          ? CupertinoIcons.play_circle
          : Icons.playlist_play_rounded;
  static IconData get playlist => yaruStyled
      ? YaruIcons.playlist
      : appleStyled
          ? CupertinoIcons.music_note_list
          : Icons.list_rounded;
  static IconData get pen => yaruStyled
      ? YaruIcons.pen
      : appleStyled
          ? CupertinoIcons.pen
          : Icons.edit_rounded;
  static IconData get pin => yaruStyled
      ? YaruIcons.pin
      : appleStyled
          ? CupertinoIcons.pin
          : Icons.push_pin_outlined;
  static IconData get pinFilled => yaruStyled
      ? YaruIcons.pin
      : appleStyled
          ? CupertinoIcons.pin_fill
          : Icons.push_pin_rounded;
  static IconData get heart => yaruStyled
      ? YaruIcons.heart
      : appleStyled
          ? CupertinoIcons.heart
          : Icons.favorite_outline_rounded;
  static IconData get heartFilled => yaruStyled
      ? YaruIcons.heart_filled
      : appleStyled
          ? CupertinoIcons.heart_fill
          : Icons.favorite_rounded;
  static IconData get globe => yaruStyled
      ? YaruIcons.globe
      : appleStyled
          ? CupertinoIcons.globe
          : Icons.link_rounded;
  static IconData get imageMissing => yaruStyled
      ? YaruIcons.image_missing
      : appleStyled
          ? CupertinoIcons.question_diamond
          : Icons.image_not_supported_outlined;
  static IconData get imageMissingFilled => yaruStyled
      ? YaruIcons.image_missing_filled
      : appleStyled
          ? CupertinoIcons.question_diamond_fill
          : Icons.image_not_supported_rounded;
  static IconData get plus => yaruStyled
      ? YaruIcons.plus
      : appleStyled
          ? CupertinoIcons.plus
          : Icons.add_rounded;
  static IconData get search => yaruStyled
      ? YaruIcons.search
      : appleStyled
          ? CupertinoIcons.search
          : Icons.search_rounded;
  IconData? get clear => yaruStyled
      ? YaruIcons.edit_clear
      : appleStyled
          ? CupertinoIcons.clear
          : Icons.clear_rounded;
  static IconData get viewMore => yaruStyled
      ? YaruIcons.view_more
      : appleStyled
          ? CupertinoIcons.ellipsis_vertical
          : Icons.more_vert_rounded;
  static IconData get close => yaruStyled
      ? YaruIcons.window_close
      : appleStyled
          ? CupertinoIcons.clear
          : Icons.clear_rounded;
  static IconData get list => yaruStyled
      ? YaruIcons.unordered_list
      : appleStyled
          ? CupertinoIcons.list_bullet
          : Icons.list_rounded;
  static IconData get grid => yaruStyled
      ? YaruIcons.app_grid
      : appleStyled
          ? CupertinoIcons.square_grid_3x2_fill
          : Icons.grid_on_rounded;
  static IconData get move => yaruStyled
      ? YaruIcons.ordered_list
      : appleStyled
          ? CupertinoIcons.move
          : Icons.move_down_rounded;
  static IconData get materialAscending => Icons.sort_rounded;
  static IconData get ascending => yaruStyled
      ? YaruIcons.sort_ascending
      : appleStyled
          ? CupertinoIcons.sort_up
          : materialAscending;
  static IconData get descending => yaruStyled
      ? YaruIcons.sort_descending
      : appleStyled
          ? CupertinoIcons.sort_down
          : Icons.sort_rounded;
  static IconData get info => yaruStyled
      ? YaruIcons.information
      : appleStyled
          ? CupertinoIcons.info
          : Icons.info_rounded;
  static IconData get clearAll => yaruStyled
      ? YaruIcons.edit_clear_all
      : appleStyled
          ? CupertinoIcons.paintbrush
          : Icons.cleaning_services_rounded;

  static IconData get insertIntoQueue => yaruStyled
      ? YaruIcons.music_queue
      : appleStyled
          ? CupertinoIcons.plus_app
          : Icons.queue_rounded;
  static IconData get sleep => yaruStyled
      ? YaruIcons.clear_night
      : appleStyled
          ? CupertinoIcons.moon
          : Icons.mode_night_rounded;
}
