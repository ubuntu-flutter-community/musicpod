import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/full_window_mode_manager.dart';
import '../../app/page_ids.dart';
import '../../app/routing_manager.dart';
import '../../dependencies.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/platform_x.dart';
import '../../local_audio/data/playlist_action.dart';
import '../../local_audio/manager/liked_audios_manager.dart';

import '../../local_audio/service/local_audio_service.dart';
import '../../local_audio/manager/playlist_ids_manager.dart';
import '../../local_audio/view/add_to_playlist_dialog.dart';
import '../../local_audio/view/album_page.dart';
import '../../local_audio/view/artist_page.dart';
import '../../player/manager/current_audio_manager.dart';
import '../../player/manager/queue_manager.dart';
import '../../podcasts/data/podcast_update_capsule.dart';
import '../../podcasts/manager/podcast_collection_filter_manager.dart';
import '../../podcasts/manager/podcast_updates_manager.dart';
import '../../podcasts/manager/subscribed_podcasts_manager.dart';
import '../../settings/data/shared_preferences_keys.dart';
import '../../settings/manager/settings_manager.dart';
import '../data/audio.dart';
import '../data/audio_type.dart';
import 'audio_tile_bottom_sheet.dart';
import 'icons.dart';
import 'meta_data_dialog.dart';
import 'modals.dart';
import 'stream_provider_share_button.dart';

class AudioTileOptionButton extends ConsumerWidget {
  const AudioTileOptionButton({
    super.key,
    required this.audios,
    required this.playlistId,
    required this.allowRemove,
    required this.searchTerm,
    required this.title,
    required this.subTitle,
    this.icon,
    this.enabled = true,
  });

  final String playlistId;
  final List<Audio> audios;
  final String searchTerm;
  final bool allowRemove;
  final Widget title;
  final Widget subTitle;
  final Widget? icon;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final l10n = context.l10n;
    final subscribedFeeds =
        ref.watch(subscribedPodcastsManagerProvider).value ?? <String>{};

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
          enabled &&
          (audios.isNotEmpty || audios.every((e) => e.isPodcast)) &&
          playlistId.isNotEmpty,
      itemBuilder: (context) {
        final hideCompletedEpisodes =
            ref.watch(
              settingsBoolManagerProvider(SPKeys.hideCompletedEpisodes),
            ) ??
            false;
        final showDownloadsOnly =
            ref.watch(podcastDownloadsOnlyManagerProvider);
        final currentAudio = ref.watch(currentAudioManagerProvider);
        final currentlyLocalPlaying =
            currentAudio != null && currentAudio.isLocal;
        return [
          if (audios.isNotEmpty &&
              audios.none((e) => e.isRadio) &&
              audios.none((e) => e.isPodcast))
            PopupMenuItem(
              onTap: () {
                if (currentlyLocalPlaying) {
                  ref.read(queueManagerProvider.notifier).insertIntoQueue(audios);
                  context.toast(
                    Text('${l10n.addedTo} ${l10n.queue}: $searchTerm'),
                    action: SnackBarAction(
                      label: l10n.queue,
                      onPressed: () => ref
                          .read(fullWindowModeManagerProvider.notifier)
                          .setFullWindowMode(true),
                    ),
                    showCloseIcon: true,
                  );
                } else {
                  ref.read(currentAudioManagerProvider.notifier).play(
                    audios: audios,
                    listName: playlistId,
                  );
                }
              },
              child: ListTile(
                leading: Icon(Iconz.insertIntoQueue),
                title: Text(
                  currentlyLocalPlaying ? l10n.playNext : l10n.playAll,
                ),
              ),
            ),
          if (allowRemove)
            PopupMenuItem(
              onTap: () => playlistId == PageIDs.likedAudios
                  ? ref
                      .read(likedAudiosManagerProvider.notifier)
                      .removeLikedAudios(audios)
                  : ref
                      .read(playlistIDsManagerProvider.notifier)
                      .createOrChangePlaylist(
                        PlaylistChange(
                          id: playlistId,
                          audios: audios,
                          action: PlaylistAction.removeFrom,
                        ),
                      ),
              child: ListTile(
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
              onTap: () => context.dialog(
                (context) => AddToPlaylistDialog(audios: audios),
              ),
              child: ListTile(
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
                  ref.read(routingManagerProvider.notifier).push(
                    pageId: artistId,
                    builder: (c) => ArtistPage(pageId: artistId),
                  );
                }
              },
              child: ListTile(
                leading: Icon(Iconz.artist),
                title: Text(l10n.showArtistPage),
              ),
            ),
            PopupMenuItem(
              onTap: () async {
                final albumId = audios.firstOrNull?.albumDbId;
                if (albumId != null) {
                  final albumAudios = await di<LocalAudioService>().findAlbum(
                    albumId,
                  );
                  if (albumAudios != null) {
                    unawaited(
                      ref.read(routingManagerProvider.notifier).push(
                        pageId: albumId.toString(),
                        builder: (context) => AlbumPage(id: albumId),
                      ),
                    );
                  }
                }
              },
              child: ListTile(
                leading: Icon(Iconz.album),
                title: Text(l10n.showAlbumPage),
              ),
            ),
          ],
          if (audios.none((e) => e.audioType == AudioType.podcast) &&
              audios.length == 1)
            PopupMenuItem(
              onTap: () => context.dialog(
                (context) => MetaDataContent.dialog(
                  audio: audios.first,
                  pageId: playlistId,
                ),
              ),
              child: ListTile(
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
          if (audios.every((e) => e.audioType == AudioType.podcast)) ...[
            PopupMenuItem(
              onTap:
                  () => ref
                      .read(
                        settingsBoolManagerProvider(
                          SPKeys.hideCompletedEpisodes,
                        ).notifier,
                      )
                      .toggle(),
              child: IgnorePointer(
                child: ListTile(
                  selectedTileColor: Colors.transparent,
                  selectedColor: theme.colorScheme.primary,
                  selected: hideCompletedEpisodes,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  leading: Icon(
                    !hideCompletedEpisodes ? Iconz.show : Iconz.hide,
                  ),
                  title: Text(
                    !hideCompletedEpisodes
                        ? l10n.showCompletedEpisodes
                        : l10n.hideCompletedEpisodes,
                  ),
                ),
              ),
            ),
            if (audios.firstOrNull?.feedUrl != null &&
                subscribedFeeds.contains(audios.first.feedUrl!))
              PopupMenuItem(
                onTap: () => ProviderScope.containerOf(
                  context,
                  listen: false,
                ).read(podcastUpdatesManagerProvider.notifier).run(
                  PodcastUpdateCapsule(
                    type: PodcastUpdateType.update,
                    feedUrls: [audios.first.feedUrl!],
                  ),
                ),
                child: IgnorePointer(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    title: Text(context.l10n.checkForUpdates),
                    leading: Icon(Iconz.refresh),
                  ),
                ),
              ),
            PopupMenuItem(
              onTap: ref.read(podcastDownloadsOnlyManagerProvider.notifier).toggle,
              child: IgnorePointer(
                child: ListTile(
                  selectedTileColor: Colors.transparent,
                  selectedColor: theme.colorScheme.primary,
                  selected: showDownloadsOnly,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  title: Text(context.l10n.downloadsOnly),
                  leading: Icon(
                    showDownloadsOnly ? Iconz.downloadFilled : Iconz.download,
                  ),
                ),
              ),
            ),
          ],
        ];
      },
      icon: icon ?? Icon(Iconz.viewMore),
    );
  }
}

// TODO: align with desktop button
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
