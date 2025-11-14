import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:yaru/yaru.dart';

import '../../app/view/routing_manager.dart';
import '../../common/data/audio_type.dart';
import '../../common/page_ids.dart';
import '../../common/view/icons.dart';
import '../../common/view/ui_constants.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../local_audio/local_audio_model.dart';
import '../../search/search_model.dart';
import '../custom_content_model.dart';

class CustomPlaylistsSection extends StatelessWidget with WatchItMixin {
  const CustomPlaylistsSection({super.key, this.shownInDialog = false});

  final bool shownInDialog;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final libraryModel = di<LibraryModel>();
    final routingManager = di<RoutingManager>();

    final customContentModel = di<CustomContentModel>();
    final playlistName = watchPropertyValue(
      (CustomContentModel m) => m.playlistName,
    );
    watchPropertyValue((CustomContentModel m) => m.playlists.length);
    final playlists = di<CustomContentModel>().playlists;
    final onPressed = (playlistName?.isNotEmpty ?? false)
        ? () async {
            if (shownInDialog && Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }

            await libraryModel.addPlaylist(playlistName!, []);
            await Future.delayed(
              const Duration(milliseconds: 200),
              () =>
                  routingManager.push(pageId: customContentModel.playlistName!),
            );

            customContentModel.reset();
          }
        : null;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SizedBox(
            height: 45,
            child: TextField(
              autofocus: true,
              onSubmitted: (_) => onPressed?.call(),
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
                    onPressed: onPressed,
                    child: Text(l10n.add),
                  ),
                ),
              ),
              onChanged: di<CustomContentModel>().setPlaylistName,
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
            future: () => di<CustomContentModel>().addPlaylists(),
            backLabel: context.l10n.back,
            title: context.l10n.importingPlaylistsPleaseWait,
          ),
          child: Text(l10n.loadFromFileOptional),
        ),
        ...playlists.map((e) {
          if (e.audios.any((e) => e.isLocal)) {
            return ListTile(
              title: Text(e.id),
              subtitle: Text('${e.audios.length} ${l10n.titles}'),
              trailing: IconButton(
                tooltip: l10n.deletePlaylist,
                icon: Icon(Iconz.remove, semanticLabel: l10n.deletePlaylist),
                onPressed: () =>
                    di<CustomContentModel>().removePlaylist(name: e.id),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        }),
        if (playlists.isNotEmpty &&
            playlists.any((e) => e.audios.none((e) => e.isLocal)))
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
                  di<SearchModel>().setAudioType(AudioType.radio);
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
                        playlists.any((e) => e.audios.any((e) => e.isLocal))
                    ? () async {
                        if (shownInDialog && Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }

                        await libraryModel.addExternalPlaylists(playlists);
                        di<LocalAudioModel>().addAudios(
                          di<LibraryModel>().externalPlaylistAudios,
                        );
                        await Future.delayed(
                          const Duration(milliseconds: 200),
                          () => routingManager.push(pageId: playlists.first.id),
                        );

                        customContentModel.reset();
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
