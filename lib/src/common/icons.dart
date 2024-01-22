import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../globals.dart';
import '../../theme.dart';

class Iconz {
  static final Iconz _instance = Iconz._internal();
  factory Iconz() => _instance;

  Iconz._internal();

  IconData get menu {
    return yaruStyled
        ? YaruIcons.menu
        : appleStyled
            ? CupertinoIcons.bars
            : Icons.menu;
  }

  IconData get musicNote => yaruStyled
      ? YaruIcons.music_note
      : appleStyled
          ? CupertinoIcons.double_music_note
          : Icons.music_note;
  IconData get external => yaruStyled
      ? YaruIcons.external_link
      : appleStyled
          ? CupertinoIcons.link
          : Icons.link;
  IconData get starFilled => yaruStyled
      ? YaruIcons.star_filled
      : appleStyled
          ? CupertinoIcons.star_fill
          : Icons.star;
  IconData get star => yaruStyled
      ? YaruIcons.star
      : appleStyled
          ? CupertinoIcons.star
          : Icons.star_outline;
  IconData get offline => yaruStyled
      ? YaruIcons.network_offline
      : appleStyled
          ? CupertinoIcons.wifi_slash
          : Icons.offline_bolt;
  IconData get pause => yaruStyled
      ? YaruIcons.media_pause
      : appleStyled
          ? CupertinoIcons.pause
          : Icons.pause;
  IconData get play => yaruStyled
      ? YaruIcons.media_play
      : appleStyled
          ? CupertinoIcons.play
          : Icons.play_arrow_outlined;
  IconData get playFilled => yaruStyled
      ? YaruIcons.media_play
      : appleStyled
          ? CupertinoIcons.play_fill
          : Icons.play_arrow;
  IconData get download => yaruStyled
      ? YaruIcons.download
      : appleStyled
          ? CupertinoIcons.down_arrow
          : Icons.download_outlined;
  IconData get downloadFilled => yaruStyled
      ? YaruIcons.download_filled
      : appleStyled
          ? CupertinoIcons.down_arrow
          : Icons.download;
  IconData get podcast => yaruStyled
      ? YaruIcons.podcast
      : appleStyled
          ? CupertinoIcons.mic
          : Icons.podcasts_outlined;
  IconData get podcastFilled => yaruStyled
      ? YaruIcons.podcast_filled
      : appleStyled
          ? CupertinoIcons.mic_fill
          : Icons.podcasts;
  IconData get radio => yaruStyled
      ? YaruIcons.radio
      : appleStyled
          ? CupertinoIcons.antenna_radiowaves_left_right
          : Icons.radio_outlined;
  IconData get radioFilled => yaruStyled
      ? YaruIcons.radio_filled
      : appleStyled
          ? CupertinoIcons.antenna_radiowaves_left_right
          : Icons.radio;
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
            ? Icons.sd_storage_outlined
            : Icons.computer;
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
            ? Icons.sd_storage
            : Icons.computer;
  }

  IconData get addToLibrary => yaruStyled
      ? YaruIcons.bell
      : appleStyled
          ? CupertinoIcons.bell
          : Icons.notifications_outlined;
  IconData get removeFromLibrary => yaruStyled
      ? YaruIcons.bell_filled
      : appleStyled
          ? CupertinoIcons.bell_fill
          : Icons.notifications;
  IconData get refresh => yaruStyled
      ? YaruIcons.refresh
      : appleStyled
          ? CupertinoIcons.refresh
          : Icons.refresh;
  IconData get speakerLowFilled => yaruStyled
      ? YaruIcons.speaker_low_filled
      : appleStyled
          ? CupertinoIcons.volume_off
          : Icons.volume_down;
  IconData get speakerMediumFilled => yaruStyled
      ? YaruIcons.speaker_medium_filled
      : appleStyled
          ? CupertinoIcons.volume_down
          : Icons.volume_down;
  IconData get speakerHighFilled => yaruStyled
      ? YaruIcons.speaker_high_filled
      : appleStyled
          ? CupertinoIcons.volume_up
          : Icons.volume_up;
  IconData get speakerMutedFilled => yaruStyled
      ? YaruIcons.speaker_muted_filled
      : appleStyled
          ? CupertinoIcons.volume_off
          : Icons.volume_off;
  IconData get fullScreenExit => yaruStyled
      ? YaruIcons.fullscreen_exit
      : appleStyled
          ? CupertinoIcons.fullscreen_exit
          : Icons.fullscreen_exit;
  IconData get fullScreen => yaruStyled
      ? YaruIcons.fullscreen
      : appleStyled
          ? CupertinoIcons.fullscreen
          : Icons.fullscreen;
  IconData get repeatSingle => yaruStyled
      ? YaruIcons.repeat_single
      : appleStyled
          ? CupertinoIcons.repeat_1
          : Icons.repeat_one;
  IconData get shuffle => yaruStyled
      ? YaruIcons.shuffle
      : appleStyled
          ? CupertinoIcons.shuffle
          : Icons.shuffle;
  IconData get levelMiddle => yaruStyled
      ? YaruIcons.meter_middle
      : appleStyled
          ? CupertinoIcons.speedometer
          : Icons.speed;
  IconData get levelHigh => yaruStyled
      ? YaruIcons.meter_three_quarter
      : appleStyled
          ? CupertinoIcons.speedometer
          : Icons.speed;
  IconData get levelLow => yaruStyled
      ? YaruIcons.meter_quarter
      : appleStyled
          ? CupertinoIcons.speedometer
          : Icons.speed;
  IconData get skipBackward => yaruStyled
      ? YaruIcons.skip_backward
      : appleStyled
          ? CupertinoIcons.backward_end
          : Icons.skip_previous;
  IconData get skipForward => yaruStyled
      ? YaruIcons.skip_forward
      : appleStyled
          ? CupertinoIcons.forward_end
          : Icons.skip_next;
  IconData get goBack => yaruStyled
      ? YaruIcons.go_previous
      : appleStyled
          ? CupertinoIcons.back
          : Icons.arrow_back;
  IconData get goNext => yaruStyled
      ? YaruIcons.go_next
      : appleStyled
          ? CupertinoIcons.forward
          : Icons.arrow_forward;
  IconData get forward30 => yaruStyled
      ? YaruIcons.redo
      : appleStyled
          ? CupertinoIcons.goforward_30
          : Icons.forward_30;
  IconData get backward10 => yaruStyled
      ? YaruIcons.undo
      : appleStyled
          ? CupertinoIcons.gobackward_10
          : Icons.replay_10;
  IconData get goUp => yaruStyled
      ? YaruIcons.go_up
      : appleStyled
          ? CupertinoIcons.up_arrow
          : Icons.arrow_upward;
  IconData get share => yaruStyled
      ? YaruIcons.share
      : appleStyled
          ? CupertinoIcons.share
          : Icons.share;
  IconData get startPlayList => yaruStyled
      ? YaruIcons.playlist_play
      : appleStyled
          ? CupertinoIcons.play_circle
          : Icons.playlist_play;
  IconData get playlist => yaruStyled
      ? YaruIcons.playlist
      : appleStyled
          ? CupertinoIcons.music_note_list
          : Icons.list;
  IconData get pen => yaruStyled
      ? YaruIcons.pen
      : appleStyled
          ? CupertinoIcons.pen
          : Icons.edit;
  IconData get pin => yaruStyled
      ? YaruIcons.pin
      : appleStyled
          ? CupertinoIcons.pin
          : Icons.push_pin_outlined;
  IconData get pinFilled => yaruStyled
      ? YaruIcons.pin
      : appleStyled
          ? CupertinoIcons.pin_fill
          : Icons.push_pin;
  IconData get heart => yaruStyled
      ? YaruIcons.heart
      : appleStyled
          ? CupertinoIcons.heart
          : Icons.favorite_outline;
  IconData get heartFilled => yaruStyled
      ? YaruIcons.heart_filled
      : appleStyled
          ? CupertinoIcons.heart_fill
          : Icons.favorite;
  IconData get globe => yaruStyled
      ? YaruIcons.globe
      : appleStyled
          ? CupertinoIcons.globe
          : Icons.link;
  IconData get imageMissing => yaruStyled
      ? YaruIcons.image_missing
      : appleStyled
          ? CupertinoIcons.question_diamond
          : Icons.image_not_supported;
  IconData get plus => yaruStyled
      ? YaruIcons.plus
      : appleStyled
          ? CupertinoIcons.plus
          : Icons.add;
  IconData get search => yaruStyled
      ? YaruIcons.search
      : appleStyled
          ? CupertinoIcons.search
          : Icons.search;
  IconData? get clear => yaruStyled
      ? YaruIcons.edit_clear
      : appleStyled
          ? CupertinoIcons.clear
          : Icons.clear;
  IconData get viewMore => yaruStyled
      ? YaruIcons.view_more_horizontal
      : appleStyled
          ? CupertinoIcons.ellipsis
          : Icons.more_horiz;
  IconData? get close => yaruStyled
      ? YaruIcons.window_close
      : appleStyled
          ? CupertinoIcons.clear
          : Icons.clear;

  Widget getAnimatedStar(bool isStarred, [Color? color]) {
    if (yaruStyled) {
      return YaruAnimatedIcon(
        isStarred
            ? const YaruAnimatedStarIcon(filled: true)
            : const YaruAnimatedStarIcon(filled: false),
        initialProgress: 1.0,
        color: color,
        size: iconSize,
      );
    } else {
      return isStarred
          ? Icon(
              Iconz().starFilled,
              size: iconSize,
            )
          : Icon(
              Iconz().star,
              size: iconSize,
            );
    }
  }

  Widget getAnimatedHeartIcon({required bool liked, Color? color}) {
    if (yaruStyled) {
      return YaruAnimatedIcon(
        liked
            ? const YaruAnimatedHeartIcon(filled: true)
            : const YaruAnimatedHeartIcon(filled: false),
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

double get iconSize => yaruStyled ? kYaruIconSize : 24;

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
