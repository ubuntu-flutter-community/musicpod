import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../view/icons.dart';

enum AudioType {
  local,
  radio,
  podcast;

  String localize(AppLocalizations l10n) => switch (this) {
        local => l10n.localAudio,
        radio => l10n.radio,
        podcast => l10n.podcast,
      };

  String localizeShort(AppLocalizations l10n) => switch (this) {
        local => l10n.local,
        radio => l10n.radio,
        podcast => l10n.podcast,
      };

  String localizedBackupName(AppLocalizations l10n) => switch (this) {
        local => l10n.pinnedAlbumsAndPlaylists,
        radio => l10n.starredStations,
        podcast => l10n.podcastSubscriptions,
      };

  String localizedSearchHint(AppLocalizations l10n) => switch (this) {
        local => '${l10n.search}: ${l10n.local}',
        radio => '${l10n.search}: ${l10n.station}',
        podcast => '${l10n.search}: ${l10n.podcast}',
      };

  IconData get iconData => switch (this) {
        local => Iconz.musicNote,
        radio => Iconz.radio,
        podcast => Iconz.podcast,
      };

  IconData get selectedIconData => switch (this) {
        local => Iconz.musicNote,
        radio => Iconz.radioFilled,
        podcast => Iconz.podcastFilled,
      };

  IconData get iconDataMainPage => switch (this) {
        local => Iconz.localAudio,
        radio => Iconz.radio,
        podcast => Iconz.podcast,
      };

  IconData get selectedIconDataMainPage => switch (this) {
        local => Iconz.localAudioFilled,
        radio => Iconz.radioFilled,
        podcast => Iconz.podcastFilled,
      };

  static AudioType? fromString(String type) => switch (type) {
        'local' => local,
        'radio' => radio,
        'podcast' => podcast,
        _ => null,
      };
}
