import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/data/audio.dart';
import '../../common/page_ids.dart';
import '../../common/view/common_widgets.dart';
import '../../common/view/global_keys.dart';
import '../../common/view/icons.dart';
import '../../common/view/side_bar_fall_back_image.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import 'add_to_playlist_snack_bar.dart';

class AddToPlaylistNavigator extends StatelessWidget {
  const AddToPlaylistNavigator({
    super.key,
    required this.audios,
  });

  final List<Audio> audios;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: playlistNavigatorKey,
      onDidRemovePage: (page) {},
      initialRoute: '/',
      onGenerateRoute: (settings) {
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => settings.name == '/new'
              ? _NewView(audios: audios)
              : _PlaylistTilesList(audios: audios),
          transitionDuration: const Duration(milliseconds: 500),
        );
      },
    );
  }
}

class _PlaylistTilesList extends StatelessWidget with WatchItMixin {
  const _PlaylistTilesList({required this.audios});

  final List<Audio> audios;

  @override
  Widget build(BuildContext context) {
    final playlistNames = watchPropertyValue(
      (LibraryModel m) => m.playlists.keys.map((e) => e.toString()),
    );

    final children = [
      ListTile(
        contentPadding: _PlaylistTile.padding,
        onTap: () => playlistNavigatorKey.currentState?.pushNamed('/new'),
        leading: SideBarFallBackImage(
          color: Colors.transparent,
          child: Icon(Iconz.plus),
        ),
        title: Text(context.l10n.createNewPlaylist),
      ),
      _PlaylistTile(
        playlistId: PageIDs.likedAudios,
        title: context.l10n.likedSongs,
        iconData: Iconz.heartFilled,
        libraryModel: di<LibraryModel>(),
        audios: audios,
      ),
      ...playlistNames.map(
        (playlistId) => Builder(
          builder: (context) {
            return _PlaylistTile(
              playlistId: playlistId,
              libraryModel: di<LibraryModel>(),
              audios: audios,
            );
          },
        ),
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      shrinkWrap: true,
      itemCount: children.length,
      separatorBuilder: (context, index) => const SizedBox(height: 5),
      itemBuilder: (context, index) => children.elementAt(index),
    );
  }
}

class _PlaylistTile extends StatelessWidget {
  const _PlaylistTile({
    required this.libraryModel,
    required this.audios,
    required this.playlistId,
    this.title,
    this.iconData,
  });

  final LibraryModel libraryModel;
  final List<Audio> audios;
  final String playlistId;
  final String? title;
  final IconData? iconData;

  static EdgeInsets get padding =>
      const EdgeInsets.symmetric(horizontal: 10, vertical: 5);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: padding,
      onTap: () {
        if (playlistId == PageIDs.likedAudios) {
          libraryModel.addFavoriteAudios(audios);
        } else {
          libraryModel.addAudiosToPlaylist(
            id: playlistId,
            audios: audios,
          );
        }

        Navigator.of(context, rootNavigator: true).maybePop();
        showAddedToPlaylistSnackBar(
          context: context,
          libraryModel: libraryModel,
          id: playlistId,
        );
      },
      leading: SideBarFallBackImage(
        color: getAlphabetColor(playlistId),
        child: Icon(iconData ?? Iconz.starFilled),
      ),
      title: Text(title ?? playlistId),
    );
  }
}

class _NewView extends StatefulWidget {
  const _NewView({
    required this.audios,
  });

  final List<Audio> audios;

  @override
  State<_NewView> createState() => _NewViewState();
}

class _NewViewState extends State<_NewView> {
  late TextEditingController _controller;

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

  @override
  Widget build(BuildContext context) {
    final libraryModel = di<LibraryModel>();
    return Container(
      decoration: BoxDecoration(
        color: context.theme.dialogTheme.backgroundColor,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
            ),
            const SizedBox(
              height: kLargestSpace,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: kLargestSpace,
                runSpacing: 10,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      context.l10n.cancel,
                    ),
                  ),
                  ImportantButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      libraryModel.addPlaylist(
                        _controller.text,
                        widget.audios,
                      );
                      showAddedToPlaylistSnackBar(
                        context: context,
                        libraryModel: libraryModel,
                        id: _controller.text,
                      );
                    },
                    child: Text(
                      context.l10n.add,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
