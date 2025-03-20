import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app_config.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../player/player_model.dart';
import '../../playlists/view/add_to_playlist_dialog.dart';
import '../data/audio.dart';
import '../data/audio_type.dart';
import '../page_ids.dart';
import 'audio_tile_bottom_sheet.dart';
import 'icons.dart';
import 'meta_data_dialog.dart';
import 'modals.dart';
import 'snackbars.dart';
import 'stream_provider_share_button.dart';

class AudioTileOptionButton extends StatelessWidget {
  const AudioTileOptionButton({
    super.key,
    required this.audios,
    required this.playlistId,
    required this.allowRemove,
    required this.selected,
    required this.searchTerm,
    required this.title,
    required this.subTitle,
    this.icon,
  });

  final String playlistId;
  final List<Audio> audios;
  final String searchTerm;
  final bool allowRemove;
  final bool selected;
  final Widget title;
  final Widget subTitle;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = context.l10n;
    final libraryModel = di<LibraryModel>();

    if (AppConfig.isMobilePlatform) {
      return AudioTileBottomSheetButton(
        audios: audios,
        allowRemove: allowRemove,
        playlistId: playlistId,
        searchTerm: searchTerm,
        title: title,
        subTitle: subTitle,
        icon: icon,
      );
    }

    return PopupMenuButton(
      tooltip: l10n.moreOptions,
      padding: EdgeInsets.zero,
      itemBuilder: (context) {
        final currentAudioType = di<PlayerModel>().audio?.audioType;
        return [
          if (audios.none((e) => e.audioType == AudioType.radio))
            PopupMenuItem(
              onTap: () {
                if (di<PlayerModel>().audio?.audioType == AudioType.radio) {
                  di<PlayerModel>()
                      .startPlaylist(audios: audios, listName: playlistId);
                } else {
                  di<PlayerModel>().insertIntoQueue(audios);
                  showSnackBar(
                    context: context,
                    content: Text(
                      '${l10n.addedTo} ${l10n.queue}: $searchTerm',
                    ),
                  );
                }
              },
              child: YaruTile(
                leading: Icon(Iconz.insertIntoQueue),
                title: Text(
                  currentAudioType == AudioType.radio
                      ? l10n.playAll
                      : l10n.playNext,
                ),
              ),
            ),
          if (allowRemove)
            PopupMenuItem(
              onTap: () => playlistId == PageIDs.likedAudios
                  ? libraryModel.removeLikedAudios(audios)
                  : libraryModel.removeAudiosFromPlaylist(
                      id: playlistId,
                      audios: audios,
                    ),
              child: YaruTile(
                leading: Icon(Iconz.remove),
                title: Text(
                  '${l10n.removeFrom} ${playlistId == PageIDs.likedAudios ? l10n.likedSongs : playlistId}',
                ),
              ),
            ),
          if (audios.none((e) => e.audioType == AudioType.radio) &&
              audios.none((e) => e.audioType == AudioType.podcast))
            PopupMenuItem(
              onTap: () => showDialog(
                context: context,
                builder: (context) => AddToPlaylistDialog(audios: audios),
              ),
              child: YaruTile(
                leading: Icon(Iconz.plus),
                title: Text(
                  '${l10n.addToPlaylist} ...',
                ),
              ),
            ),
          if (audios.none(
                (e) => e.audioType == AudioType.podcast,
              ) &&
              audios.length == 1)
            PopupMenuItem(
              onTap: () => showDialog(
                context: context,
                builder: (context) =>
                    MetaDataContent.dialog(audio: audios.first),
              ),
              child: YaruTile(
                leading: Icon(Iconz.info),
                title: Text(
                  '${l10n.showMetaData} ...',
                ),
              ),
            ),
          if (audios.none((e) => e.audioType == AudioType.radio))
            PopupMenuItem(
              enabled: false,
              padding: EdgeInsets.zero,
              child: Theme(
                data:
                    theme.copyWith(disabledColor: theme.colorScheme.onSurface),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  child: StreamProviderRow(
                    iconColor: theme.colorScheme.onSurface,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    text: searchTerm,
                  ),
                ),
              ),
            ),
        ];
      },
      icon: icon ?? Icon(Iconz.viewMore),
    );
  }
}

class AudioTileBottomSheetButton extends StatelessWidget {
  const AudioTileBottomSheetButton({
    super.key,
    required this.audios,
    required this.allowRemove,
    required this.playlistId,
    required this.searchTerm,
    required this.title,
    required this.subTitle,
    this.icon,
  });

  final List<Audio> audios;
  final String searchTerm;
  final bool allowRemove;
  final String playlistId;
  final Widget title;
  final Widget subTitle;
  final Widget? icon;

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: context.l10n.moreOptions,
        onPressed: () => showModal(
          mode: ModalMode.platformModalMode,
          context: context,
          content: AudioTileBottomSheet(
            searchTerm: searchTerm,
            title: title,
            subTitle: subTitle,
            audios: audios,
            allowRemove: allowRemove,
            playlistId: playlistId,
          ),
        ),
        icon: icon ?? Icon(Iconz.viewMore),
      );
}
