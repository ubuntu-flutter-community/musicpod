import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../app_config.dart';

class Iconz {
  static IconData get home => AppConfig.yaruStyled
      ? YaruIcons.home
      : AppConfig.appleStyled
          ? CupertinoIcons.home
          : Icons.home_outlined;
  static IconData get homeFilled => AppConfig.yaruStyled
      ? YaruIcons.home_filled
      : AppConfig.appleStyled
          ? CupertinoIcons.home
          : Icons.home_filled;

  static IconData get image => AppConfig.yaruStyled
      ? YaruIcons.image
      : AppConfig.appleStyled
          ? CupertinoIcons.photo
          : Icons.image_not_supported;

  static IconData get warning => AppConfig.yaruStyled
      ? YaruIcons.warning_filled
      : AppConfig.appleStyled
          ? CupertinoIcons.exclamationmark_triangle_fill
          : Icons.warning_rounded;

  static IconData get menu {
    return AppConfig.yaruStyled
        ? YaruIcons.menu
        : AppConfig.appleStyled
            ? CupertinoIcons.bars
            : Icons.menu_rounded;
  }

  static IconData get materialSidebar => Icons.menu_rounded;

  static IconData get sidebar {
    return AppConfig.yaruStyled
        ? YaruIcons.sidebar
        : AppConfig.appleStyled
            ? CupertinoIcons.sidebar_left
            : materialSidebar;
  }

  static IconData get updateAvailable {
    return AppConfig.yaruStyled
        ? YaruIcons.update_available
        : AppConfig.appleStyled
            ? CupertinoIcons.arrow_up_circle
            : Icons.arrow_circle_up_rounded;
  }

  static IconData get remove {
    return AppConfig.yaruStyled
        ? YaruIcons.trash
        : AppConfig.appleStyled
            ? CupertinoIcons.trash
            : Icons.delete_outline_rounded;
  }

  static IconData get check => AppConfig.yaruStyled
      ? YaruIcons.checkmark
      : AppConfig.appleStyled
          ? CupertinoIcons.check_mark
          : Icons.check_rounded;
  static IconData get musicNote => AppConfig.yaruStyled
      ? YaruIcons.music_note
      : AppConfig.appleStyled
          ? CupertinoIcons.double_music_note
          : Icons.music_note_rounded;
  static IconData get artist => AppConfig.yaruStyled
      ? YaruIcons.music_artist
      : AppConfig.appleStyled
          ? CupertinoIcons.music_albums
          : Icons.interpreter_mode_outlined;
  static IconData get album => AppConfig.yaruStyled
      ? YaruIcons.disk
      : AppConfig.appleStyled
          ? CupertinoIcons.music_albums
          : Icons.album_rounded;
  static IconData get external => AppConfig.yaruStyled
      ? YaruIcons.external_link
      : AppConfig.appleStyled
          ? CupertinoIcons.link
          : Icons.link_rounded;
  static IconData get starFilled => AppConfig.yaruStyled
      ? YaruIcons.star_filled
      : AppConfig.appleStyled
          ? CupertinoIcons.star_fill
          : Icons.star_rounded;
  static IconData get star => AppConfig.yaruStyled
      ? YaruIcons.star
      : AppConfig.appleStyled
          ? CupertinoIcons.star
          : Icons.star_outline_rounded;
  static IconData get offline => AppConfig.yaruStyled
      ? YaruIcons.network_offline
      : AppConfig.appleStyled
          ? CupertinoIcons.wifi_slash
          : Icons.offline_bolt_rounded;
  static IconData get cloud => AppConfig.yaruStyled
      ? YaruIcons.cloud
      : AppConfig.appleStyled
          ? CupertinoIcons.cloud
          : Icons.cloud_outlined;
  static IconData get pause => AppConfig.yaruStyled
      ? YaruIcons.media_pause
      : AppConfig.appleStyled
          ? CupertinoIcons.pause
          : Icons.pause_rounded;

  static IconData get playFilled => AppConfig.yaruStyled
      ? YaruIcons.media_play
      : AppConfig.appleStyled
          ? CupertinoIcons.play_fill
          : Icons.play_arrow_rounded;
  static IconData get upload => AppConfig.yaruStyled
      ? YaruIcons.arrow_up_outlined
      : AppConfig.appleStyled
          ? CupertinoIcons.up_arrow
          : Icons.download_outlined;
  static IconData get download => AppConfig.yaruStyled
      ? YaruIcons.download
      : AppConfig.appleStyled
          ? CupertinoIcons.down_arrow
          : Icons.download_outlined;
  static IconData get downloadFilled => AppConfig.yaruStyled
      ? YaruIcons.download_filled
      : AppConfig.appleStyled
          ? CupertinoIcons.down_arrow
          : Icons.download_rounded;
  static IconData get podcast => AppConfig.yaruStyled
      ? YaruIcons.podcast
      : AppConfig.appleStyled
          ? CupertinoIcons.mic
          : Icons.podcasts_outlined;
  static IconData get podcastFilled => AppConfig.yaruStyled
      ? YaruIcons.podcast_filled
      : AppConfig.appleStyled
          ? CupertinoIcons.mic_fill
          : Icons.podcasts_rounded;
  static IconData get radio => AppConfig.yaruStyled
      ? YaruIcons.radio
      : AppConfig.appleStyled
          ? CupertinoIcons.antenna_radiowaves_left_right
          : Icons.radio_outlined;
  static IconData get radioFilled => AppConfig.yaruStyled
      ? YaruIcons.radio_filled
      : AppConfig.appleStyled
          ? CupertinoIcons.antenna_radiowaves_left_right
          : Icons.radio_rounded;

  static IconData get localAudio {
    if (AppConfig.appleStyled) {
      if (AppConfig.isMobilePlatform) {
        return CupertinoIcons.device_phone_portrait;
      }
      return CupertinoIcons.device_laptop;
    }
    return AppConfig.yaruStyled
        ? YaruIcons.drive_harddisk
        : AppConfig.isMobilePlatform
            ? Icons.phone_android_outlined
            : Icons.computer_rounded;
  }

  static IconData get localAudioFilled {
    if (AppConfig.appleStyled) {
      if (AppConfig.isMobilePlatform) {
        return CupertinoIcons.device_phone_portrait;
      }
      return CupertinoIcons.device_laptop;
    }
    return AppConfig.yaruStyled
        ? YaruIcons.drive_harddisk_filled
        : AppConfig.isMobilePlatform
            ? Icons.phone_android_rounded
            : Icons.computer_rounded;
  }

  static IconData get copy {
    return AppConfig.yaruStyled
        ? YaruIcons.copy
        : AppConfig.appleStyled
            ? CupertinoIcons.doc_on_clipboard
            : Icons.copy_rounded;
  }

  static IconData get explore {
    return AppConfig.yaruStyled
        ? YaruIcons.compass
        : AppConfig.appleStyled
            ? CupertinoIcons.compass
            : Icons.explore_rounded;
  }

  static IconData get drag {
    if (AppConfig.appleStyled) {
      return CupertinoIcons.move;
    }
    if (AppConfig.yaruStyled) {
      return YaruIcons.drag_handle;
    }
    return Icons.drag_handle_rounded;
  }

  static IconData get settings => AppConfig.yaruStyled
      ? YaruIcons.settings
      : AppConfig.appleStyled
          ? CupertinoIcons.settings
          : Icons.settings_outlined;

  static IconData get settingsFilled => AppConfig.yaruStyled
      ? YaruIcons.settings_filled
      : AppConfig.appleStyled
          ? CupertinoIcons.settings
          : Icons.settings;

  static IconData get addToLibrary => AppConfig.yaruStyled
      ? YaruIcons.plus
      : AppConfig.appleStyled
          ? CupertinoIcons.plus
          : Icons.add;
  static IconData get removeFromLibrary => AppConfig.yaruStyled
      ? YaruIcons.checkmark
      : AppConfig.appleStyled
          ? CupertinoIcons.check_mark
          : Icons.check;
  static IconData get refresh => AppConfig.yaruStyled
      ? YaruIcons.refresh
      : AppConfig.appleStyled
          ? CupertinoIcons.refresh
          : Icons.refresh_rounded;
  static IconData get replay => AppConfig.yaruStyled
      ? YaruIcons.revert
      : AppConfig.appleStyled
          ? CupertinoIcons.arrow_counterclockwise_circle
          : Icons.undo;
  static IconData get speakerLowFilled => AppConfig.yaruStyled
      ? YaruIcons.speaker_low_filled
      : AppConfig.appleStyled
          ? CupertinoIcons.volume_off
          : Icons.volume_down_rounded;
  static IconData get speakerMediumFilled => AppConfig.yaruStyled
      ? YaruIcons.speaker_medium_filled
      : AppConfig.appleStyled
          ? CupertinoIcons.volume_down
          : Icons.volume_down_rounded;
  static IconData get speakerHighFilled => AppConfig.yaruStyled
      ? YaruIcons.speaker_high_filled
      : AppConfig.appleStyled
          ? CupertinoIcons.volume_up
          : Icons.volume_up_rounded;
  static IconData get speakerMutedFilled => AppConfig.yaruStyled
      ? YaruIcons.speaker_muted_filled
      : AppConfig.appleStyled
          ? CupertinoIcons.volume_off
          : Icons.volume_off_rounded;
  static IconData get fullWindowExit => AppConfig.yaruStyled
      ? YaruIcons.arrow_down
      : AppConfig.appleStyled
          ? CupertinoIcons.arrow_down
          : Icons.arrow_downward_rounded;
  static IconData get fullWindow => AppConfig.yaruStyled
      ? YaruIcons.arrow_up
      : AppConfig.appleStyled
          ? CupertinoIcons.arrow_up
          : Icons.arrow_upward_rounded;
  static IconData get fullScreenExit => AppConfig.yaruStyled
      ? YaruIcons.fullscreen_exit
      : AppConfig.appleStyled
          ? CupertinoIcons.fullscreen_exit
          : Icons.fullscreen_exit_rounded;
  static IconData get fullScreen => AppConfig.yaruStyled
      ? YaruIcons.fullscreen
      : AppConfig.appleStyled
          ? CupertinoIcons.fullscreen
          : Icons.fullscreen_rounded;
  static IconData get repeatSingle => AppConfig.yaruStyled
      ? YaruIcons.repeat_single
      : AppConfig.appleStyled
          ? CupertinoIcons.repeat_1
          : Icons.repeat_one_rounded;
  static IconData get shuffle => AppConfig.yaruStyled
      ? YaruIcons.shuffle
      : AppConfig.appleStyled
          ? CupertinoIcons.shuffle
          : Icons.shuffle_rounded;
  static IconData get levelMiddle => AppConfig.yaruStyled
      ? YaruIcons.meter_middle
      : AppConfig.appleStyled
          ? CupertinoIcons.speedometer
          : Icons.speed_rounded;
  static IconData get levelHigh => AppConfig.yaruStyled
      ? YaruIcons.meter_three_quarter
      : AppConfig.appleStyled
          ? CupertinoIcons.speedometer
          : Icons.speed_rounded;
  static IconData get levelLow => AppConfig.yaruStyled
      ? YaruIcons.meter_quarter
      : AppConfig.appleStyled
          ? CupertinoIcons.speedometer
          : Icons.speed_rounded;
  static IconData get skipBackward => AppConfig.yaruStyled
      ? YaruIcons.skip_backward
      : AppConfig.appleStyled
          ? CupertinoIcons.backward_end
          : Icons.skip_previous_rounded;
  static IconData get skipForward => AppConfig.yaruStyled
      ? YaruIcons.skip_forward
      : AppConfig.appleStyled
          ? CupertinoIcons.forward_end
          : Icons.skip_next_rounded;
  static IconData get goBack => AppConfig.yaruStyled
      ? YaruIcons.go_previous
      : AppConfig.appleStyled
          ? CupertinoIcons.back
          : Icons.arrow_back_rounded;
  static IconData get goNext => AppConfig.yaruStyled
      ? YaruIcons.go_next
      : AppConfig.appleStyled
          ? CupertinoIcons.forward
          : Icons.arrow_forward_rounded;
  static IconData get forward30 => AppConfig.yaruStyled
      ? YaruIcons.redo
      : AppConfig.appleStyled
          ? CupertinoIcons.goforward_30
          : Icons.forward_30_rounded;
  static IconData get backward10 => AppConfig.yaruStyled
      ? YaruIcons.undo
      : AppConfig.appleStyled
          ? CupertinoIcons.gobackward_10
          : Icons.replay_10_rounded;
  static IconData get goUp => AppConfig.yaruStyled
      ? YaruIcons.go_up
      : AppConfig.appleStyled
          ? CupertinoIcons.up_arrow
          : Icons.arrow_upward_rounded;
  static IconData get share => AppConfig.yaruStyled
      ? YaruIcons.share
      : AppConfig.appleStyled
          ? CupertinoIcons.share
          : Icons.share;
  static IconData get startPlayList => AppConfig.yaruStyled
      ? YaruIcons.playlist_play
      : AppConfig.appleStyled
          ? CupertinoIcons.play_circle
          : Icons.playlist_play_rounded;
  static IconData get playlist => AppConfig.yaruStyled
      ? YaruIcons.playlist
      : AppConfig.appleStyled
          ? CupertinoIcons.music_note_list
          : Icons.list_rounded;
  static IconData get pen => AppConfig.yaruStyled
      ? YaruIcons.pen
      : AppConfig.appleStyled
          ? CupertinoIcons.pen
          : Icons.edit_rounded;
  static IconData get pin => AppConfig.yaruStyled
      ? YaruIcons.pin
      : AppConfig.appleStyled
          ? CupertinoIcons.pin
          : Icons.push_pin_outlined;
  static IconData get pinFilled => AppConfig.yaruStyled
      ? YaruIcons.pin
      : AppConfig.appleStyled
          ? CupertinoIcons.pin_fill
          : Icons.push_pin_rounded;
  static IconData get heart => AppConfig.yaruStyled
      ? YaruIcons.heart
      : AppConfig.appleStyled
          ? CupertinoIcons.heart
          : Icons.favorite_outline_rounded;
  static IconData get heartFilled => AppConfig.yaruStyled
      ? YaruIcons.heart_filled
      : AppConfig.appleStyled
          ? CupertinoIcons.heart_fill
          : Icons.favorite_rounded;
  static IconData get globe => AppConfig.yaruStyled
      ? YaruIcons.globe
      : AppConfig.appleStyled
          ? CupertinoIcons.globe
          : Icons.language;
  static IconData get imageMissing => AppConfig.yaruStyled
      ? YaruIcons.image_missing
      : AppConfig.appleStyled
          ? CupertinoIcons.question_diamond
          : Icons.image_not_supported_outlined;
  static IconData get imageMissingFilled => AppConfig.yaruStyled
      ? YaruIcons.image_missing_filled
      : AppConfig.appleStyled
          ? CupertinoIcons.question_diamond_fill
          : Icons.image_not_supported_rounded;
  static IconData get plus => AppConfig.yaruStyled
      ? YaruIcons.plus
      : AppConfig.appleStyled
          ? CupertinoIcons.plus
          : Icons.add_rounded;
  static IconData get search => AppConfig.yaruStyled
      ? YaruIcons.search
      : AppConfig.appleStyled
          ? CupertinoIcons.search
          : Icons.search_rounded;
  IconData? get clear => AppConfig.yaruStyled
      ? YaruIcons.edit_clear
      : AppConfig.appleStyled
          ? CupertinoIcons.clear
          : Icons.clear_rounded;
  static IconData get viewMore => AppConfig.yaruStyled
      ? YaruIcons.view_more
      : AppConfig.appleStyled
          ? CupertinoIcons.ellipsis_vertical
          : Icons.more_vert_rounded;
  static IconData get close => AppConfig.yaruStyled
      ? YaruIcons.window_close
      : AppConfig.appleStyled
          ? CupertinoIcons.clear
          : Icons.clear_rounded;
  static IconData get list => AppConfig.yaruStyled
      ? YaruIcons.unordered_list
      : AppConfig.appleStyled
          ? CupertinoIcons.list_bullet
          : Icons.list_rounded;
  static IconData get grid => AppConfig.yaruStyled
      ? YaruIcons.app_grid
      : AppConfig.appleStyled
          ? CupertinoIcons.square_grid_3x2_fill
          : Icons.grid_on_rounded;
  static IconData get move => AppConfig.yaruStyled
      ? YaruIcons.ordered_list
      : AppConfig.appleStyled
          ? CupertinoIcons.move
          : Icons.move_down_rounded;
  static IconData get materialAscending => Icons.sort_rounded;
  static IconData get ascending => AppConfig.yaruStyled
      ? YaruIcons.sort_ascending
      : AppConfig.appleStyled
          ? CupertinoIcons.sort_up
          : materialAscending;
  static IconData get descending => AppConfig.yaruStyled
      ? YaruIcons.sort_descending
      : AppConfig.appleStyled
          ? CupertinoIcons.sort_down
          : Icons.sort_rounded;
  static IconData get info => AppConfig.yaruStyled
      ? YaruIcons.information
      : AppConfig.appleStyled
          ? CupertinoIcons.info
          : Icons.info_rounded;
  static IconData get clearAll => AppConfig.yaruStyled
      ? YaruIcons.edit_clear_all
      : AppConfig.appleStyled
          ? CupertinoIcons.paintbrush
          : Icons.cleaning_services_rounded;

  static IconData get insertIntoQueue => AppConfig.yaruStyled
      ? YaruIcons.playlist_play
      : AppConfig.appleStyled
          ? CupertinoIcons.play_circle
          : Icons.playlist_add;
  static IconData get sleep => AppConfig.yaruStyled
      ? YaruIcons.clear_night
      : AppConfig.appleStyled
          ? CupertinoIcons.moon
          : Icons.mode_night_rounded;
  static IconData get markAllRead => AppConfig.yaruStyled
      ? YaruIcons.ok_filled
      : AppConfig.appleStyled
          ? CupertinoIcons.check_mark_circled_solid
          : Icons.check_circle;
  static IconData get radioHistory => AppConfig.yaruStyled
      ? YaruIcons.music_history
      : AppConfig.appleStyled
          ? CupertinoIcons.clock
          : Icons.history_rounded;
}
