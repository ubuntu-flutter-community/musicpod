import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../extensions/taget_platform_x.dart';
import '../../settings/settings_service.dart';

class Iconz {
  static int get _iconSetIndex => di<SettingsService>().iconSetIndex;
  static bool get cupertino => _iconSetIndex == IconSet.cupertino.index;
  static bool get yaru => _iconSetIndex == IconSet.yaru.index;

  static IconData get show => yaru
      ? YaruIcons.eye
      : cupertino
      ? CupertinoIcons.eye
      : Icons.remove_red_eye_outlined;

  static IconData get showLyrics => yaru
      ? YaruIcons.chat_bubble_filled
      : cupertino
      ? CupertinoIcons.chat_bubble_text_fill
      : Icons.chat_bubble;

  static IconData get hideLyrics => yaru
      ? YaruIcons.chat_bubble
      : cupertino
      ? CupertinoIcons.chat_bubble_text
      : Icons.chat_bubble_outline;

  static IconData get hide => yaru
      ? YaruIcons.hide
      : cupertino
      ? CupertinoIcons.eye_slash
      : Icons.visibility_off_outlined;

  static IconData get dropdown => yaru
      ? YaruIcons.pan_down
      : cupertino
      ? CupertinoIcons.chevron_down
      : Icons.arrow_drop_down_rounded;

  static IconData get color => yaru
      ? YaruIcons.color_select
      : cupertino
      ? CupertinoIcons.color_filter
      : Icons.color_lens_rounded;

  static IconData get home => yaru
      ? YaruIcons.home
      : cupertino
      ? CupertinoIcons.home
      : Icons.home_outlined;
  static IconData get homeFilled => yaru
      ? YaruIcons.home_filled
      : cupertino
      ? CupertinoIcons.home
      : Icons.home_rounded;

  static IconData get image => yaru
      ? YaruIcons.image
      : cupertino
      ? CupertinoIcons.photo
      : Icons.image_not_supported;

  static IconData get warning => yaru
      ? YaruIcons.warning_filled
      : cupertino
      ? CupertinoIcons.exclamationmark_triangle_fill
      : Icons.warning_rounded;

  static IconData get menu {
    return yaru
        ? YaruIcons.menu
        : cupertino
        ? CupertinoIcons.bars
        : Icons.menu_rounded;
  }

  static IconData get export => yaru
      ? YaruIcons.arrow_down_outlined
      : cupertino
      ? CupertinoIcons.arrow_down
      : Icons.arrow_downward;

  static IconData get import => yaru
      ? YaruIcons.arrow_up_outlined
      : cupertino
      ? CupertinoIcons.arrow_up
      : Icons.arrow_upward;

  static IconData get materialSidebar => Icons.menu_rounded;

  static IconData get sidebar {
    return yaru
        ? YaruIcons.sidebar
        : cupertino
        ? CupertinoIcons.sidebar_left
        : materialSidebar;
  }

  static IconData get updateAvailable {
    return yaru
        ? YaruIcons.update_available
        : cupertino
        ? CupertinoIcons.arrow_up_circle
        : Icons.arrow_circle_up_rounded;
  }

  static IconData get remove {
    return yaru
        ? YaruIcons.trash
        : cupertino
        ? CupertinoIcons.trash
        : Icons.delete_outline_rounded;
  }

  static IconData get check => yaru
      ? YaruIcons.checkmark
      : cupertino
      ? CupertinoIcons.check_mark
      : Icons.check_rounded;
  static IconData get musicNote => yaru
      ? YaruIcons.music_note
      : cupertino
      ? CupertinoIcons.double_music_note
      : Icons.music_note_rounded;
  static IconData get artist => yaru
      ? YaruIcons.music_artist
      : cupertino
      ? CupertinoIcons.music_albums
      : Icons.interpreter_mode_outlined;
  static IconData get album => yaru
      ? YaruIcons.disk
      : cupertino
      ? CupertinoIcons.circle
      : Icons.album_rounded;
  static IconData get external => yaru
      ? YaruIcons.external_link
      : cupertino
      ? CupertinoIcons.link
      : Icons.link_rounded;
  static IconData get starFilled => yaru
      ? YaruIcons.star_filled
      : cupertino
      ? CupertinoIcons.star_fill
      : Icons.star_rounded;
  static IconData get star => yaru
      ? YaruIcons.star
      : cupertino
      ? CupertinoIcons.star
      : Icons.star_outline_rounded;
  static IconData get offline => yaru
      ? YaruIcons.network_offline
      : cupertino
      ? CupertinoIcons.wifi_slash
      : Icons.offline_bolt_rounded;
  static IconData get cloud => yaru
      ? YaruIcons.cloud
      : cupertino
      ? CupertinoIcons.cloud
      : Icons.cloud_outlined;
  static IconData get pause => yaru
      ? YaruIcons.media_pause
      : cupertino
      ? CupertinoIcons.pause
      : Icons.pause_rounded;

  static IconData get playFilled => yaru
      ? YaruIcons.media_play
      : cupertino
      ? CupertinoIcons.play_fill
      : Icons.play_arrow_rounded;
  static IconData get upload => yaru
      ? YaruIcons.arrow_up_outlined
      : cupertino
      ? CupertinoIcons.up_arrow
      : Icons.download_outlined;
  static IconData get download => yaru
      ? YaruIcons.download
      : cupertino
      ? CupertinoIcons.down_arrow
      : Icons.download_outlined;
  static IconData get downloadFilled => yaru
      ? YaruIcons.download_filled
      : cupertino
      ? CupertinoIcons.down_arrow
      : Icons.download_rounded;
  static IconData get podcast => yaru
      ? YaruIcons.podcast
      : cupertino
      ? CupertinoIcons.mic
      : Icons.podcasts_outlined;
  static IconData get podcastFilled => yaru
      ? YaruIcons.podcast_filled
      : cupertino
      ? CupertinoIcons.mic_fill
      : Icons.podcasts_rounded;
  static IconData get radio => yaru
      ? YaruIcons.radio
      : cupertino
      ? CupertinoIcons.antenna_radiowaves_left_right
      : Icons.radio_outlined;
  static IconData get radioFilled => yaru
      ? YaruIcons.radio_filled
      : cupertino
      ? CupertinoIcons.antenna_radiowaves_left_right
      : Icons.radio_rounded;

  static IconData get localAudio {
    if (cupertino) {
      if (isMobile) {
        return CupertinoIcons.device_phone_portrait;
      }
      return CupertinoIcons.device_laptop;
    }
    return yaru
        ? YaruIcons.drive_harddisk
        : isMobile
        ? Icons.phone_android_outlined
        : Icons.computer_rounded;
  }

  static IconData get localAudioFilled {
    if (cupertino) {
      if (isMobile) {
        return CupertinoIcons.device_phone_portrait;
      }
      return CupertinoIcons.device_laptop;
    }
    return yaru
        ? YaruIcons.drive_harddisk_filled
        : isMobile
        ? Icons.phone_android_rounded
        : Icons.computer_rounded;
  }

  static IconData get copy {
    return yaru
        ? YaruIcons.copy
        : cupertino
        ? CupertinoIcons.doc_on_clipboard
        : Icons.copy_rounded;
  }

  static IconData get explore {
    return yaru
        ? YaruIcons.compass
        : cupertino
        ? CupertinoIcons.compass
        : Icons.explore_rounded;
  }

  static IconData get drag {
    if (cupertino) {
      return CupertinoIcons.move;
    }
    if (yaru) {
      return YaruIcons.drag_handle;
    }
    return Icons.drag_handle_rounded;
  }

  static IconData get settings => yaru
      ? YaruIcons.settings
      : cupertino
      ? CupertinoIcons.settings
      : Icons.settings_outlined;

  static IconData get settingsFilled => yaru
      ? YaruIcons.settings_filled
      : cupertino
      ? CupertinoIcons.settings
      : Icons.settings;

  static IconData get addToLibrary => yaru
      ? YaruIcons.plus
      : cupertino
      ? CupertinoIcons.plus
      : Icons.add;
  static IconData get removeFromLibrary => yaru
      ? YaruIcons.minus
      : cupertino
      ? CupertinoIcons.minus
      : Icons.remove;
  static IconData get refresh => yaru
      ? YaruIcons.refresh
      : cupertino
      ? CupertinoIcons.refresh
      : Icons.refresh_rounded;
  static IconData get replay => yaru
      ? YaruIcons.revert
      : cupertino
      ? CupertinoIcons.arrow_counterclockwise_circle
      : Icons.undo;
  static IconData get speakerLowFilled => yaru
      ? YaruIcons.speaker_low_filled
      : cupertino
      ? CupertinoIcons.volume_off
      : Icons.volume_down_rounded;
  static IconData get speakerMediumFilled => yaru
      ? YaruIcons.speaker_medium_filled
      : cupertino
      ? CupertinoIcons.volume_down
      : Icons.volume_down_rounded;
  static IconData get speakerHighFilled => yaru
      ? YaruIcons.speaker_high_filled
      : cupertino
      ? CupertinoIcons.volume_up
      : Icons.volume_up_rounded;
  static IconData get speakerMutedFilled => yaru
      ? YaruIcons.speaker_muted_filled
      : cupertino
      ? CupertinoIcons.volume_off
      : Icons.volume_off_rounded;
  static IconData get fullWindowExit => yaru
      ? YaruIcons.arrow_down
      : cupertino
      ? CupertinoIcons.arrow_down
      : Icons.arrow_downward_rounded;
  static IconData get fullWindow => yaru
      ? YaruIcons.arrow_up
      : cupertino
      ? CupertinoIcons.arrow_up
      : Icons.arrow_upward_rounded;
  static IconData get fullScreenExit => yaru
      ? YaruIcons.fullscreen_exit
      : cupertino
      ? CupertinoIcons.fullscreen_exit
      : Icons.fullscreen_exit_rounded;
  static IconData get fullScreen => yaru
      ? YaruIcons.fullscreen
      : cupertino
      ? CupertinoIcons.fullscreen
      : Icons.fullscreen_rounded;
  static IconData get repeatSingle => yaru
      ? YaruIcons.repeat_single
      : cupertino
      ? CupertinoIcons.repeat_1
      : Icons.repeat_one_rounded;
  static IconData get shuffle => yaru
      ? YaruIcons.shuffle
      : cupertino
      ? CupertinoIcons.shuffle
      : Icons.shuffle_rounded;
  static IconData get levelMiddle => yaru
      ? YaruIcons.meter_middle
      : cupertino
      ? CupertinoIcons.speedometer
      : Icons.speed_rounded;
  static IconData get levelHigh => yaru
      ? YaruIcons.meter_three_quarter
      : cupertino
      ? CupertinoIcons.speedometer
      : Icons.speed_rounded;
  static IconData get levelLow => yaru
      ? YaruIcons.meter_quarter
      : cupertino
      ? CupertinoIcons.speedometer
      : Icons.speed_rounded;
  static IconData get skipBackward => yaru
      ? YaruIcons.skip_backward
      : cupertino
      ? CupertinoIcons.backward_end
      : Icons.skip_previous_rounded;
  static IconData get skipForward => yaru
      ? YaruIcons.skip_forward
      : cupertino
      ? CupertinoIcons.forward_end
      : Icons.skip_next_rounded;
  static IconData get goBack => yaru
      ? YaruIcons.go_previous
      : cupertino
      ? CupertinoIcons.back
      : Icons.arrow_back_rounded;
  static IconData get goNext => yaru
      ? YaruIcons.go_next
      : cupertino
      ? CupertinoIcons.forward
      : Icons.arrow_forward_rounded;
  static IconData get forward30 => yaru
      ? YaruIcons.redo
      : cupertino
      ? CupertinoIcons.goforward_30
      : Icons.forward_30_rounded;
  static IconData get backward10 => yaru
      ? YaruIcons.undo
      : cupertino
      ? CupertinoIcons.gobackward_10
      : Icons.replay_10_rounded;
  static IconData get goUp => yaru
      ? YaruIcons.go_up
      : cupertino
      ? CupertinoIcons.up_arrow
      : Icons.arrow_upward_rounded;
  static IconData get share => yaru
      ? YaruIcons.share
      : cupertino
      ? CupertinoIcons.share
      : Icons.share;
  static IconData get startPlayList => yaru
      ? YaruIcons.playlist_play
      : cupertino
      ? CupertinoIcons.play_circle
      : Icons.playlist_play_rounded;
  static IconData get playlist => yaru
      ? YaruIcons.playlist
      : cupertino
      ? CupertinoIcons.music_note_list
      : Icons.list_rounded;
  static IconData get pen => yaru
      ? YaruIcons.pen
      : cupertino
      ? CupertinoIcons.pen
      : Icons.edit_rounded;
  static IconData get pin => yaru
      ? YaruIcons.pin
      : cupertino
      ? CupertinoIcons.pin
      : Icons.push_pin_outlined;
  static IconData get pinFilled => yaru
      ? YaruIcons.pin
      : cupertino
      ? CupertinoIcons.pin_fill
      : Icons.push_pin_rounded;
  static IconData get heart => yaru
      ? YaruIcons.heart
      : cupertino
      ? CupertinoIcons.heart
      : Icons.favorite_outline_rounded;
  static IconData get heartFilled => yaru
      ? YaruIcons.heart_filled
      : cupertino
      ? CupertinoIcons.heart_fill
      : Icons.favorite_rounded;
  static IconData get globe => yaru
      ? YaruIcons.globe
      : cupertino
      ? CupertinoIcons.globe
      : Icons.language;
  static IconData get imageMissing => yaru
      ? YaruIcons.image_missing
      : cupertino
      ? CupertinoIcons.question_diamond
      : Icons.image_not_supported_outlined;
  static IconData get imageMissingFilled => yaru
      ? YaruIcons.image_missing_filled
      : cupertino
      ? CupertinoIcons.question_diamond_fill
      : Icons.image_not_supported_rounded;
  static IconData get plus => yaru
      ? YaruIcons.plus
      : cupertino
      ? CupertinoIcons.plus
      : Icons.add_rounded;
  static IconData get search => yaru
      ? YaruIcons.search
      : cupertino
      ? CupertinoIcons.search
      : Icons.search_rounded;
  IconData? get clear => yaru
      ? YaruIcons.edit_clear
      : cupertino
      ? CupertinoIcons.clear
      : Icons.clear_rounded;
  static IconData get viewMore => yaru
      ? YaruIcons.view_more
      : cupertino
      ? CupertinoIcons.ellipsis_vertical
      : Icons.more_vert_rounded;
  static IconData get close => yaru
      ? YaruIcons.window_close
      : cupertino
      ? CupertinoIcons.clear
      : Icons.clear_rounded;
  static IconData get list => yaru
      ? YaruIcons.unordered_list
      : cupertino
      ? CupertinoIcons.list_bullet
      : Icons.list_rounded;
  static IconData get grid => yaru
      ? YaruIcons.app_grid
      : cupertino
      ? CupertinoIcons.square_grid_3x2_fill
      : Icons.grid_on_rounded;
  static IconData get move => yaru
      ? YaruIcons.ordered_list
      : cupertino
      ? CupertinoIcons.move
      : Icons.move_down_rounded;
  static IconData get materialAscending => Icons.sort_rounded;
  static IconData get ascending => yaru
      ? YaruIcons.sort_ascending
      : cupertino
      ? CupertinoIcons.sort_up
      : materialAscending;
  static IconData get descending => yaru
      ? YaruIcons.sort_descending
      : cupertino
      ? CupertinoIcons.sort_down
      : Icons.sort_rounded;
  static IconData get info => yaru
      ? YaruIcons.information
      : cupertino
      ? CupertinoIcons.info
      : Icons.info_rounded;
  static IconData get clearAll => yaru
      ? YaruIcons.edit_clear_all
      : cupertino
      ? CupertinoIcons.paintbrush
      : Icons.cleaning_services_rounded;

  static IconData get insertIntoQueue => yaru
      ? YaruIcons.playlist_play
      : cupertino
      ? CupertinoIcons.play_circle
      : Icons.playlist_add;
  static IconData get sleep => yaru
      ? YaruIcons.clear_night
      : cupertino
      ? CupertinoIcons.moon
      : Icons.mode_night_rounded;
  static IconData get markAllRead => yaru
      ? YaruIcons.ok_filled
      : cupertino
      ? CupertinoIcons.check_mark_circled_solid
      : Icons.check_circle;
  static IconData get radioHistory => yaru
      ? YaruIcons.music_history
      : cupertino
      ? CupertinoIcons.clock
      : Icons.history_rounded;
}

enum IconSet {
  yaru,
  cupertino,
  material;

  static int get platformDefaultIndex {
    if (isLinux) return yaru.index;
    if (isMacOS || isIOS) return cupertino.index;
    return material.index;
  }
}
