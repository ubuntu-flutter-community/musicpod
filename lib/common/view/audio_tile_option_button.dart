import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:yaru/yaru.dart';

import '../../app/view/routing_manager.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/taget_platform_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../local_audio/local_audio_model.dart';
import '../../local_audio/view/album_page.dart';
import '../../local_audio/view/artist_page.dart';
import '../../player/player_model.dart';
import '../../playlists/view/add_to_playlist_dialog.dart';
import '../../podcasts/podcast_model.dart';
import '../../settings/settings_model.dart';
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
    required this.searchTerm,
    required this.title,
    required this.subTitle,
    this.icon,
  });

  final String playlistId;
  final List<Audio> audios;
  final String searchTerm;
  final bool allowRemove;
  final Widget title;
  final Widget subTitle;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = context.l10n;
    final libraryModel = di<LibraryModel>();

    if (isMobile) {
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
      enabled:
          (audios.isNotEmpty || audios.every((e) => e.isPodcast)) &&
          playlistId.isNotEmpty,
      itemBuilder: (context) {
        final hideCompletedEpisodes = di<SettingsModel>().hideCompletedEpisodes;
        final playerModel = di<PlayerModel>();
        final currentAudio = playerModel.audio;
        final currentlyLocalPlaying =
            currentAudio != null && currentAudio.isLocal;
        return [
          if (audios.isNotEmpty &&
              audios.none((e) => e.isRadio) &&
              audios.none((e) => e.isPodcast))
            PopupMenuItem(
              onTap: () {
                if (currentlyLocalPlaying) {
                  playerModel.insertIntoQueue(audios);
                  showSnackBar(
                    context: context,
                    content: Text('${l10n.addedTo} ${l10n.queue}: $searchTerm'),
                  );
                } else {
                  playerModel.startPlaylist(
                    audios: audios,
                    listName: playlistId,
                  );
                }
              },
              child: YaruTile(
                leading: Icon(Iconz.insertIntoQueue),
                title: Text(
                  currentlyLocalPlaying ? l10n.playNext : l10n.playAll,
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
          if (audios.isNotEmpty &&
              audios.none((e) => e.audioType == AudioType.radio) &&
              audios.none((e) => e.audioType == AudioType.podcast))
            PopupMenuItem(
              onTap: () => showDialog(
                context: context,
                builder: (context) => AddToPlaylistDialog(audios: audios),
              ),
              child: YaruTile(
                leading: Icon(Iconz.plus),
                title: Text('${l10n.addToPlaylist} ...'),
              ),
            ),
          if (audios.length == 1 &&
              audios.none((e) => e.audioType != AudioType.local)) ...[
            PopupMenuItem(
              onTap: () {
                final artistId = audios.firstOrNull?.artist;
                if (artistId != null) {
                  di<RoutingManager>().push(
                    pageId: artistId,
                    builder: (c) => ArtistPage(pageId: artistId),
                  );
                }
              },
              child: YaruTile(
                leading: Icon(Iconz.artist),
                title: Text(l10n.showArtistPage),
              ),
            ),
            PopupMenuItem(
              onTap: () async {
                final albumId = audios.firstOrNull?.albumId;
                if (albumId != null) {
                  final albumAudios = await di<LocalAudioModel>().findAlbum(
                    albumId,
                  );
                  if (albumAudios != null) {
                    di<RoutingManager>().push(
                      pageId: albumId,
                      builder: (context) => AlbumPage(id: albumId),
                    );
                  }
                }
              },
              child: YaruTile(
                leading: Icon(Iconz.album),
                title: Text(l10n.showAlbumPage),
              ),
            ),
          ],
          if (audios.none((e) => e.audioType == AudioType.podcast) &&
              audios.length == 1)
            PopupMenuItem(
              onTap: () => showDialog(
                context: context,
                builder: (context) => MetaDataContent.dialog(
                  audio: audios.first,
                  pageId: playlistId,
                ),
              ),
              child: YaruTile(
                leading: Icon(Iconz.info),
                title: Text('${l10n.showMetaData} ...'),
              ),
            ),
          if (audios.none((e) => e.audioType == AudioType.radio))
            PopupMenuItem(
              enabled: false,
              padding: EdgeInsets.zero,
              child: Theme(
                data: theme.copyWith(
                  disabledColor: theme.colorScheme.onSurface,
                ),
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
          if (audios.every((e) => e.isPodcast)) ...[
            PopupMenuItem(
              onTap: () => di<SettingsModel>().setHideCompletedEpisodes(
                !hideCompletedEpisodes,
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                leading: Icon(hideCompletedEpisodes ? Iconz.show : Iconz.hide),
                title: Text(
                  hideCompletedEpisodes
                      ? l10n.showCompletedEpisodes
                      : l10n.hideCompletedEpisodes,
                ),
              ),
            ),
            if (audios.firstOrNull?.website != null)
              PopupMenuItem(
                onTap: () => showFutureLoadingDialog(
                  context: context,
                  title: context.l10n.loadingPodcastFeed,
                  future: () => di<PodcastModel>().checkForUpdates(
                    feedUrls: {audios.first.website!},
                    updateMessage: context.l10n.newEpisodeAvailable,
                    multiUpdateMessage: (length) =>
                        context.l10n.newEpisodesAvailableFor(length),
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  title: Text(context.l10n.checkForUpdates),
                  leading: Icon(Iconz.refresh),
                ),
              ),
          ],
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
    onPressed: playlistId.isEmpty
        ? null
        : () => showModal(
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
