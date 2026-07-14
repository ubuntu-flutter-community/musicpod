import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/page_ids.dart';
import '../../app/routing_manager.dart';
import '../../common/data/audio.dart';
import '../../common/data/audio_type.dart';
import '../../common/util/family.dart';
import '../../common/view/adaptive_multi_layout_body.dart';
import '../../common/view/audio_page_header.dart';
import '../../common/view/audio_page_type.dart';
import '../../common/view/clean_up_caches.dart';
import '../../common/view/local_audio_tile.dart';
import '../../common/view/genre_bar.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/search_button.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../player/data/queue.dart';
import '../../player/manager/player_manager.dart';
import '../../search/manager/search_manager.dart';
import '../../search/data/search_type.dart';
import '../manager/playlist_manager.dart';
import '../manager/local_audio_manager.dart';
import '../data/playlist_action.dart';
import '../manager/playlist_ids_manager.dart';
import 'album_page.dart';
import 'artist_page.dart';
import 'failed_import_snackbar.dart';
import 'playlist_add_audio_autocomplete.dart';
import 'playlist_control_panel.dart';
import 'playlist_header_image.dart';

class PlaylistPage extends StatelessWidget with WatchItMixin {
  const PlaylistPage({super.key, required this.pageId});

  final String pageId;

  @override
  Widget build(BuildContext context) {
    callOnceAfterThisBuild((context) => clearNetworkImageCache());
    final isInitializing = watchValue(
      (LocalAudioManager m) => m.initAudiosCommand.isRunning,
    );

    return DropTarget(
      onDragDone: (details) => di<PlaylistIDsManager>().command.run(
        PlaylistChange(
          id: pageId,
          action: PlaylistAction.addTo,
          audios: details.files
              .map((xFile) => File(xFile.path))
              .map(
                (file) => Audio.local(
                  file,
                  onError: (path) => showFailedImportsSnackBarIfNotBlocked(
                    failedImports: [path],
                    context: context,
                    failedToImport: true,
                  ),
                  onParseError: (path) => showFailedImportsSnackBarIfNotBlocked(
                    failedImports: [path],
                    context: context,
                  ),
                ),
              )
              .toList(),
          external: false,
        ),
      ),
      child: Scaffold(
        appBar: HeaderBar(
          title: Text(pageId),

          actions: [
            Padding(
              padding: appBarSingleActionSpacing,
              child: SearchButton(
                onPressed: () {
                  di<RoutingManager>().push(pageId: PageIDs.searchPage);
                  final searchManager = di<SearchManager>();
                  searchManager
                    ..setAudioType(AudioType.local)
                    ..setSearchType(SearchType.localTitle)
                    ..search();
                },
              ),
            ),
          ],
        ),
        body: isInitializing
            ? const Center(child: CircularProgressIndicator())
            : _PlaylistPageBody(
                onArtistTap: (text) => di<RoutingManager>().push(
                  builder: (_) => ArtistPage(pageId: text),
                  pageId: text,
                ),
                onAlbumTap: (audio) {
                  if (audio.albumDbId == null) {
                    context.toast(Text(context.l10n.nothingFound));
                    return;
                  }
                  di<RoutingManager>().push(
                    builder: (_) => AlbumPage(id: audio.albumDbId!),
                    pageId: audio.albumDbId!.toString(),
                  );
                },
                image: PlaylistHeaderImage(pageId: pageId),
                pageId: pageId,
              ),
      ),
    );
  }
}

class _PlaylistPageBody extends StatelessWidget with WatchItMixin {
  const _PlaylistPageBody({
    required this.pageId,
    this.image,
    this.onArtistTap,
    this.onAlbumTap,
  });

  final String pageId;
  final Widget? image;

  final void Function(String text)? onArtistTap;
  final void Function(Audio audio)? onAlbumTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    onDispose(() => Family.dispose<PlaylistManager>(pageId));

    final audios =
        watchValue((PlaylistManager m) => m.command, param1: pageId) ?? [];

    final isPlaying = watchPropertyValue((PlayerManager m) => m.isPlaying);
    final playerManager = di<PlayerManager>();

    final currentAudio = watchPropertyValue((PlayerManager m) => m.audio);

    final audioPageHeader = AudioPageHeader(
      title: pageId,
      subTitle: '${audios.length} ${l10n.titles}',
      image: image,
      label: l10n.playlist,
      description: GenreBar(audios: audios),
    );

    return AdaptiveMultiLayoutBody(
      header: audioPageHeader,
      controlPanel: PlaylistControlPanel(pageId: pageId, audios: audios),
      secondSliverControlPanel: SliverPadding(
        padding: const EdgeInsetsGeometry.symmetric(
          horizontal: 2 * kLargestSpace,
        ),
        sliver: SliverToBoxAdapter(
          child: PlaylistAddAudioAutoCompleteOrShrink(pageId: pageId),
        ),
      ),
      secondControlPanel: Padding(
        padding: const EdgeInsets.only(top: kLargestSpace),
        child: PlaylistAddAudioAutoCompleteOrShrink(pageId: pageId),
      ),
      sliverBody: (constraints) {
        final width = constraints.maxWidth;

        return SliverReorderableList(
          itemCount: audios.length,

          proxyDecorator: (child, index, animation) => Material(
            borderRadius: BorderRadius.circular(8),
            child: child,
            elevation: 6,
            color: Theme.of(context).cardColor.withValues(alpha: 0.8),
          ),
          itemBuilder: (BuildContext context, int index) {
            final audio = audios.elementAt(index);
            final audioSelected = currentAudio == audio;

            return ReorderableDragStartListener(
              key: ValueKey(audio.path ?? audio.url),
              index: index,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: LocalAudioTile(
                  showSubSubTitle: width > 1200,
                  showDuration: width > 1000,
                  showSubTitle: width > 500,
                  style: width <= 500
                      ? AudioTileStyle.normal
                      : AudioTileStyle.compact,
                  allowLeadingImage: audios.length < kShowLeadingThreshold,
                  onSubTitleTap: onArtistTap,
                  onSubSubTitleTap: onAlbumTap,
                  key: ValueKey(audio.path ?? audio.url),
                  isPlayerPlaying: isPlaying,
                  onTap: () {
                    if (audioSelected) {
                      if (isPlaying) {
                        playerManager.pause();
                      } else {
                        playerManager.resume();
                      }
                    } else {
                      playerManager.play(
                        audios: audios,
                        listName: pageId,
                        index: index,
                      );
                    }
                  },
                  selected: audioSelected,
                  audio: audio,
                  pageId: pageId,
                  audioPageType: AudioPageType.playlist,
                ),
              ),
            );
          },
          onReorder: (oldIndex, newIndex) {
            if (playerManager.queue == Queue(name: pageId, audios: audios)) {
              playerManager.moveAudioInQueue(oldIndex, newIndex);
            }

            di<PlaylistIDsManager>().command.run(
              PlaylistChange(
                id: pageId,
                audios: [],
                action: PlaylistAction.moveWithin,
                oldIndex: oldIndex,
                newIndex: newIndex,
              ),
            );
          },
        );
      },
    );
  }
}
