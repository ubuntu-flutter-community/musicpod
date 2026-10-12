import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';

import '../../app/page_ids.dart';
import '../../app/routing_manager.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/confirm.dart';
import '../../common/view/icons.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../local_audio/data/playlist_action.dart';
import '../../local_audio/manager/has_tracks_manager.dart';
import '../../local_audio/manager/playlist_ids_manager.dart';
import '../../search/manager/search_manager.dart';
import '../../settings/view/settings_action.dart';
import '../manager/external_playlist_drafts_manager.dart';

class CustomPlaylistsSection extends ConsumerStatefulWidget {
  const CustomPlaylistsSection({super.key, this.shownInDialog = false});

  final bool shownInDialog;

  @override
  ConsumerState<CustomPlaylistsSection> createState() =>
      _CustomPlaylistsSectionState();
}

class _CustomPlaylistsSectionState
    extends ConsumerState<CustomPlaylistsSection> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _createEmptyPlaylist(String playlistName) async {
    if (widget.shownInDialog && context.canPop()) {
      context.pop();
    }

    await ref
        .read(playlistIDsManagerProvider.notifier)
        .createOrChangePlaylist(
          PlaylistChange(id: playlistName, action: PlaylistAction.create),
        );

    await Future.delayed(
      const Duration(milliseconds: 200),
      () => ref
          .read(routingManagerProvider.notifier)
          .push(pageId: playlistName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasTracks = ref.watch(hasTracksManagerProvider);

    if (!hasTracks.isLoading && hasTracks.value == false) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.l10n.noLocalTitlesFound),
          const SizedBox(height: kLargestSpace),
          const SettingsButton.important(scrollIndex: 2),
        ],
      );
    }

    final playlists = ref.watch(externalPlaylistDraftsManagerProvider);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SizedBox(
            height: 45,
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                final hasText = _controller.text.trim().isNotEmpty;
                return TextField(
                  controller: _controller,
                  autofocus: true,
                  onSubmitted: hasText
                      ? (_) => _createEmptyPlaylist(_controller.text.trim())
                      : null,
                  decoration: InputDecoration(
                    label: Text(l10n.name),
                    suffixIcon: SizedBox(
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(kYaruButtonRadius),
                              bottomRight: Radius.circular(kYaruButtonRadius),
                            ),
                          ),
                        ),
                        onPressed: hasText
                            ? () => _createEmptyPlaylist(_controller.text.trim())
                            : null,
                        child: Text(l10n.add),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.all(kMediumSpace),
              child: Text(l10n.or),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        TextButton(
          onPressed: () => ConfirmationDialog.show(
            context: context,
            initialFuture: () => ref
                .read(externalPlaylistDraftsManagerProvider.notifier)
                .addPlaylists(),
            cancelLabel: context.l10n.back,
            loadingTitle: Text(context.l10n.importingPlaylistsPleaseWait),
          ),
          child: Text(l10n.loadFromFileOptional),
        ),
        ...playlists.entries.map((e) {
          if (e.value.any((e) => e.isLocal)) {
            return ListTile(
              title: Text(e.key),
              subtitle: Text('${e.value.length} ${l10n.titles}'),
              trailing: IconButton(
                tooltip: l10n.deletePlaylist,
                icon: Icon(
                  Iconz.remove,
                  semanticLabel: l10n.deletePlaylist,
                ),
                onPressed: () => ref
                    .read(externalPlaylistDraftsManagerProvider.notifier)
                    .removePlaylist(name: e.key),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        }),
        if (playlists.isNotEmpty &&
            playlists.entries.any((e) => e.value.none((e) => e.isLocal)))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: kLargestSpace),
            child: YaruInfoBox(
              yaruInfoType: YaruInfoType.warning,
              trailing: TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kYaruButtonRadius),
                  ),
                  foregroundColor: YaruInfoType.warning.getColor(context),
                ),
                onPressed: () {
                  ref
                      .read(searchManagerProvider.notifier)
                      .setAudioType(AudioType.radio);
                  ref
                      .read(routingManagerProvider.notifier)
                      .push(pageId: PageIDs.searchPage);
                },
                child: Text(l10n.search),
              ),
              subtitle: Text(l10n.onlyLocalAudioForPlaylists),
            ),
          ),
        Align(
          alignment: Alignment.bottomRight,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton(
                onPressed: playlists.isNotEmpty &&
                        playlists.entries.any(
                          (e) => e.value.any((e) => e.isLocal),
                        )
                    ? () async {
                        if (widget.shownInDialog && context.canPop()) {
                          context.pop();
                        }
                        final firstKey = playlists.entries.first.key;
                        await ref
                            .read(externalPlaylistDraftsManagerProvider.notifier)
                            .importPlaylists();

                        await ref
                            .read(routingManagerProvider.notifier)
                            .push(
                              pageId: firstKey,
                            );
                      }
                    : null,
                child: Text(l10n.add),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
