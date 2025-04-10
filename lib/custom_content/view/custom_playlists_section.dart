import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/common_widgets.dart';
import '../../common/view/icons.dart';
import '../../common/view/ui_constants.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../custom_content_model.dart';

class CustomPlaylistsSection extends StatelessWidget with WatchItMixin {
  const CustomPlaylistsSection({super.key, this.shownInDialog = false});

  final bool shownInDialog;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final libraryModel = di<LibraryModel>();
    final customContentModel = di<CustomContentModel>();
    final playlistName =
        watchPropertyValue((CustomContentModel m) => m.playlistName);
    watchPropertyValue((CustomContentModel m) => m.playlists.length);
    final playlists = di<CustomContentModel>().playlists;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TextField(
            autofocus: true,
            decoration: InputDecoration(
              label: Text(l10n.setPlaylistNameAndAddMoreLater),
            ),
            onChanged: di<CustomContentModel>().setPlaylistName,
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
          onPressed: () => di<CustomContentModel>().addPlaylists(),
          child: Text(l10n.loadFromFileOptional),
        ),
        ...playlists.map(
          (e) => ListTile(
            title: Text(e.id.replaceAll('.m3u', '').replaceAll('.pls', '')),
            subtitle: Text(
              '${e.audios.length} ${l10n.titles}',
            ),
            trailing: IconButton(
              tooltip: l10n.deletePlaylist,
              icon: Icon(
                Iconz.remove,
                semanticLabel: l10n.deletePlaylist,
              ),
              onPressed: () =>
                  di<CustomContentModel>().removePlaylist(name: e.id),
            ),
          ),
        ),
        const SizedBox(
          height: kLargestSpace,
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ImportantButton(
                onPressed: () async {
                  if (shownInDialog && Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                  if (playlistName?.isNotEmpty ?? false) {
                    await libraryModel.addPlaylist(playlistName!, []);
                    await Future.delayed(
                      const Duration(milliseconds: 200),
                      () => libraryModel.push(
                        pageId: customContentModel.playlistName!,
                      ),
                    );
                  } else if (playlists.isNotEmpty) {
                    await libraryModel.addPlaylists(playlists, external: true);
                    await Future.delayed(
                      const Duration(milliseconds: 200),
                      () => libraryModel.push(
                        pageId: playlists.first.id,
                      ),
                    );
                  }
                  customContentModel.reset();
                },
                child: Text(
                  l10n.add,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
