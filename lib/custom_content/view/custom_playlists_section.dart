import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:yaru/yaru.dart';

import '../../app/page_ids.dart';
import '../../app/routing_manager.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/icons.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../local_audio/data/playlist_action.dart';
import '../../local_audio/manager/find_all_tracks_manager.dart';
import '../../local_audio/manager/playlist_ids_manager.dart';
import '../../search/manager/search_manager.dart';
import '../../settings/view/settings_action.dart';
import '../manager/custom_content_manager.dart';

class CustomPlaylistsSection extends StatelessWidget with WatchItMixin {
  const CustomPlaylistsSection({super.key, this.shownInDialog = false});

  final bool shownInDialog;

  Future<void> _createEmptyPlaylist(
    BuildContext context,
    String playlistName,
  ) async {
    if (shownInDialog && context.canPop()) {
      context.pop();
    }

    di<PlaylistIDsManager>().command.run(
      PlaylistChange(id: playlistName, action: PlaylistAction.create),
    );

    await Future.delayed(
      const Duration(milliseconds: 200),
      () => di<RoutingManager>().push(pageId: playlistName),
    );

    di<CustomContentManager>().reset();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final tracksResults = watchValue(
      (FindAllTracksManager m) => m.command.results,
    );
    if (!tracksResults.isRunning && (tracksResults.data?.isEmpty ?? false)) {
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

    final manager = di<CustomContentManager>();
    final playlistName = watchValue((CustomContentManager m) => m.playlistName);
    final playlists = watchValue(
      (CustomContentManager m) => m.externalPlaylists,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SizedBox(
            height: 45,
            child: TextField(
              autofocus: true,
              onSubmitted: (playlistName?.isNotEmpty ?? false)
                  ? (_) => _createEmptyPlaylist(context, playlistName!)
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
                    onPressed: (playlistName?.isNotEmpty ?? false)
                        ? () => _createEmptyPlaylist(context, playlistName!)
                        : null,
                    child: Text(l10n.add),
                  ),
                ),
              ),
              onChanged: di<CustomContentManager>().setPlaylistName,
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
          onPressed: () => showFutureLoadingDialog(
            context: context,
            future: () => di<CustomContentManager>().addPlaylists(),
            backLabel: context.l10n.back,
            title: context.l10n.importingPlaylistsPleaseWait,
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
                icon: Icon(Iconz.remove, semanticLabel: l10n.deletePlaylist),
                onPressed: () =>
                    di<CustomContentManager>().removePlaylist(name: e.key),
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
                  di<SearchManager>().setAudioType(AudioType.radio);
                  di<RoutingManager>().push(pageId: PageIDs.searchPage);
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
                onPressed:
                    playlists.isNotEmpty &&
                        playlists.entries.any(
                          (e) => e.value.any((e) => e.isLocal),
                        )
                    ? () async {
                        if (shownInDialog && context.canPop()) {
                          context.pop();
                        }
                        await di<CustomContentManager>()
                            .importExternalPlaylistsCommand
                            .runAsync();

                        await di<RoutingManager>().push(
                          pageId: playlists.entries.first.key,
                        );

                        manager.reset();
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
