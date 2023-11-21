import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/constants.dart';

class Iconz {
  static final Iconz _instance = Iconz._internal();
  factory Iconz() => _instance;

  Iconz._internal();

  IconData get menu {
    return _l
        ? YaruIcons.menu
        : _a
            ? CupertinoIcons.bars
            : Icons.menu;
  }

  IconData get musicNote => _l
      ? YaruIcons.music_note
      : _a
          ? CupertinoIcons.double_music_note
          : Icons.music_note;
  IconData get external => _l
      ? YaruIcons.external_link
      : _a
          ? CupertinoIcons.link
          : Icons.link;
  IconData get starFilled => _l
      ? YaruIcons.star_filled
      : _a
          ? CupertinoIcons.star_fill
          : Icons.star;
  IconData get star => _l
      ? YaruIcons.star
      : _a
          ? CupertinoIcons.star
          : Icons.star_outline;
  IconData get offline => _l
      ? YaruIcons.network_offline
      : _a
          ? CupertinoIcons.wifi_slash
          : Icons.offline_bolt;
  IconData get pause => _l
      ? YaruIcons.media_pause
      : _a
          ? CupertinoIcons.pause
          : Icons.pause;
  IconData get play => _l
      ? YaruIcons.media_play
      : _a
          ? CupertinoIcons.play
          : Icons.play_arrow;
  IconData get download => _l
      ? YaruIcons.download
      : _a
          ? CupertinoIcons.down_arrow
          : Icons.download;
  IconData get podcast => _l
      ? YaruIcons.podcast
      : _a
          ? CupertinoIcons.dot_radiowaves_left_right
          : Icons.podcasts_outlined;
  IconData get podcastFilled => _l
      ? YaruIcons.podcast_filled
      : _a
          ? CupertinoIcons.dot_radiowaves_left_right
          : Icons.podcasts;
  IconData get radio => _l
      ? YaruIcons.radio
      : _a
          ? CupertinoIcons.antenna_radiowaves_left_right
          : Icons.radio_outlined;
  IconData get radioFilled => _l
      ? YaruIcons.radio_filled
      : _a
          ? CupertinoIcons.antenna_radiowaves_left_right
          : Icons.radio;
  IconData get localAudio => _l
      ? YaruIcons.drive_harddisk
      : _a
          ? CupertinoIcons.device_laptop
          : Icons.sd_storage_outlined;
  IconData get localAudioFilled => _l
      ? YaruIcons.drive_harddisk_filled
      : _a
          ? CupertinoIcons.device_laptop
          : Icons.sd_storage;
  IconData get rss => _l
      ? YaruIcons.rss
      : _a
          ? CupertinoIcons.radiowaves_right
          : Icons.rss_feed_outlined;
  IconData get refresh => _l
      ? YaruIcons.refresh
      : _a
          ? CupertinoIcons.refresh
          : Icons.refresh;
  IconData get speakerLowFilled => _l
      ? YaruIcons.speaker_low_filled
      : _a
          ? CupertinoIcons.volume_off
          : Icons.volume_down;
  IconData get speakerMediumFilled => _l
      ? YaruIcons.speaker_medium_filled
      : _a
          ? CupertinoIcons.volume_down
          : Icons.volume_up;
  IconData get speakerHighFilled => _l
      ? YaruIcons.speaker_high_filled
      : _a
          ? CupertinoIcons.volume_up
          : Icons.volume_up;
  IconData get speakerMutedFilled => _l
      ? YaruIcons.speaker_muted_filled
      : _a
          ? CupertinoIcons.volume_mute
          : Icons.volume_off;
  IconData get fullScreenExit => _l
      ? YaruIcons.fullscreen_exit
      : _a
          ? CupertinoIcons.fullscreen_exit
          : Icons.fullscreen_exit;
  IconData get fullScreen => _l
      ? YaruIcons.fullscreen
      : _a
          ? CupertinoIcons.fullscreen
          : Icons.fullscreen;
  IconData get repeatSingle => _l
      ? YaruIcons.repeat_single
      : _a
          ? CupertinoIcons.repeat_1
          : Icons.repeat_one;
  IconData get shuffle => _l
      ? YaruIcons.shuffle
      : _a
          ? CupertinoIcons.shuffle
          : Icons.shuffle;
  IconData get skipBackward => _l
      ? YaruIcons.skip_backward
      : _a
          ? CupertinoIcons.backward_end
          : Icons.skip_previous;
  IconData get skipForward => _l
      ? YaruIcons.skip_forward
      : _a
          ? CupertinoIcons.forward_end
          : Icons.skip_next;
  IconData get goBack => _l
      ? YaruIcons.go_previous
      : _a
          ? CupertinoIcons.back
          : Icons.arrow_back;
  IconData get goNext => _l
      ? YaruIcons.go_next
      : _a
          ? CupertinoIcons.forward
          : Icons.arrow_forward;
  IconData get share => _l
      ? YaruIcons.share
      : _a
          ? CupertinoIcons.share
          : Icons.share;
  IconData get startPlayList => _l
      ? YaruIcons.playlist_play
      : _a
          ? CupertinoIcons.play_circle
          : Icons.playlist_play;
  IconData get playlist => _l
      ? YaruIcons.playlist
      : _a
          ? CupertinoIcons.music_note_list
          : Icons.list;
  IconData get pen => _l
      ? YaruIcons.pen
      : _a
          ? CupertinoIcons.pen
          : Icons.edit;
  IconData get pin => _l
      ? YaruIcons.pin
      : _a
          ? CupertinoIcons.pin
          : Icons.push_pin;
  IconData get heart => _l
      ? YaruIcons.heart
      : _a
          ? CupertinoIcons.heart
          : Icons.favorite_outline;
  IconData get heartFilled => _l
      ? YaruIcons.heart_filled
      : _a
          ? CupertinoIcons.heart_fill
          : Icons.favorite;
  IconData get globe => _l
      ? YaruIcons.globe
      : _a
          ? CupertinoIcons.globe
          : Icons.link;
  IconData get imageMissing => _l
      ? YaruIcons.image_missing
      : _a
          ? CupertinoIcons.question_diamond
          : Icons.image_not_supported;
  IconData get plus => _l
      ? YaruIcons.plus
      : _a
          ? CupertinoIcons.plus
          : Icons.add;
  IconData get search => _l
      ? YaruIcons.search
      : _a
          ? CupertinoIcons.search
          : Icons.search;
  IconData? get clear => _l
      ? YaruIcons.edit_clear
      : _a
          ? CupertinoIcons.clear
          : Icons.clear;

  bool get _l => Platform.isLinux;

  bool get _a => Platform.isMacOS || Platform.isIOS;

  Widget getAnimatedStar(bool isStarred, [Color? color]) {
    if (_l) {
      return YaruAnimatedIcon(
        isStarred
            ? const YaruAnimatedStarIcon(filled: true)
            : const YaruAnimatedStarIcon(filled: false),
        initialProgress: 1.0,
        color: color,
        size: iconSize(),
      );
    } else {
      return isStarred
          ? Icon(
              Iconz().starFilled,
              size: iconSize(),
            )
          : Icon(
              Iconz().star,
              size: iconSize(),
            );
    }
  }

  Widget getAnimatedHeartIcon({required bool liked, Color? color}) {
    if (_l) {
      return YaruAnimatedIcon(
        liked
            ? const YaruAnimatedHeartIcon(filled: true)
            : const YaruAnimatedHeartIcon(filled: false),
        initialProgress: 1.0,
        color: color,
        size: iconSize(),
      );
    } else {
      return Icon(
        liked ? Icons.favorite : Icons.favorite_outline,
        color: color,
      );
    }
  }

  Color? getAvatarIconColor(ThemeData theme) =>
      _l ? theme.colorScheme.onSurface.withOpacity(0.08) : null;
}

double iconSize() => Platform.isLinux
    ? kYaruIconSize
    : Platform.isMacOS
        ? 22.0
        : 24.0;
