import 'dart:io';

import 'package:flutter/material.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/constants.dart';

class Iconz {
  static final Iconz _instance = Iconz._internal();
  factory Iconz() => _instance;

  Iconz._internal();

  IconData get menu => _l ? YaruIcons.menu : Icons.menu;
  IconData get musicNote => _l ? YaruIcons.music_note : Icons.music_note;
  IconData get external => _l ? YaruIcons.external_link : Icons.link;
  IconData get starFilled => _l ? YaruIcons.star_filled : Icons.star;
  IconData get star => _l ? YaruIcons.star : Icons.star_outline;
  IconData get offline => _l ? YaruIcons.network_offline : Icons.offline_bolt;
  IconData get pause => _l ? YaruIcons.media_pause : Icons.pause;
  IconData get play => _l ? YaruIcons.media_play : Icons.play_arrow;
  IconData get download => _l ? YaruIcons.download : Icons.download;
  IconData get podcast => _l ? YaruIcons.podcast : Icons.podcasts_outlined;
  IconData get podcastFilled => _l ? YaruIcons.podcast_filled : Icons.podcasts;
  IconData get radio =>
      _l ? YaruIcons.radio : Icons.settings_input_antenna_outlined;
  IconData get radioFilled =>
      _l ? YaruIcons.radio_filled : Icons.settings_input_antenna;
  IconData get localAudio =>
      _l ? YaruIcons.drive_harddisk : Icons.sd_storage_outlined;
  IconData get localAudioFilled =>
      _l ? YaruIcons.drive_harddisk_filled : Icons.sd_storage;
  IconData get rss => _l ? YaruIcons.rss : Icons.rss_feed_outlined;
  IconData get refresh => _l ? YaruIcons.refresh : Icons.refresh;
  IconData get speakerLowFilled =>
      _l ? YaruIcons.speaker_low_filled : Icons.volume_down;
  IconData get speakerMediumFilled =>
      _l ? YaruIcons.speaker_medium_filled : Icons.volume_up;
  IconData get speakerHighFilled =>
      _l ? YaruIcons.speaker_high_filled : Icons.volume_up;
  IconData get speakerMutedFilled =>
      _l ? YaruIcons.speaker_muted_filled : Icons.volume_off;
  IconData get fullScreenExit =>
      _l ? YaruIcons.fullscreen_exit : Icons.fullscreen_exit;
  IconData get fullScreen => _l ? YaruIcons.fullscreen : Icons.fullscreen;
  IconData get repeatSingle => _l ? YaruIcons.repeat_single : Icons.repeat_one;
  IconData get shuffle => _l ? YaruIcons.shuffle : Icons.shuffle;
  IconData get skipBackward =>
      _l ? YaruIcons.skip_backward : Icons.skip_previous;
  IconData get skipForward => _l ? YaruIcons.skip_forward : Icons.skip_next;
  IconData get share => _l ? YaruIcons.share : Icons.share;
  IconData get startPlayList =>
      _l ? YaruIcons.playlist_play : Icons.playlist_play;
  IconData get playlist => _l ? YaruIcons.playlist : Icons.list;
  IconData get pen => _l ? YaruIcons.pen : Icons.edit;
  IconData get pin => _l ? YaruIcons.pin : Icons.sticky_note_2;
  IconData get heart => _l ? YaruIcons.heart : Icons.favorite_outline;
  IconData get heartFilled => _l ? YaruIcons.heart_filled : Icons.favorite;
  IconData get globe => _l ? YaruIcons.globe : Icons.link;
  IconData get imageMissing =>
      _l ? YaruIcons.image_missing : Icons.image_not_supported;
  IconData get plus => _l ? YaruIcons.plus : Icons.add;

  bool get _l => Platform.isLinux;
}

double iconSize() => Platform.isLinux ? kYaruIconSize : 24.0;
