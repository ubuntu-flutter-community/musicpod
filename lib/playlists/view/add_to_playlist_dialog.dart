import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app_config.dart';
import '../../common/data/audio.dart';
import '../../common/view/common_widgets.dart';
import '../../common/view/global_keys.dart';
import '../../common/view/icons.dart';
import '../../common/view/side_bar_fall_back_image.dart';
import '../../common/view/theme.dart';
import '../../constants.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import 'add_to_playlist_snack_bar.dart';

class AddToPlaylistDialog extends StatelessWidget {
  const AddToPlaylistDialog({
    super.key,
    required this.audio,
    required this.libraryModel,
  });

  final Audio audio;
  final LibraryModel libraryModel;

  @override
  Widget build(BuildContext context) {
    final nav = Navigator(
      // ignore: deprecated_member_use
      onPopPage: (route, result) => route.didPop(result),
      key: playlistNavigatorKey,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => settings.name == '/new'
              ? _NewView(
                  libraryModel: libraryModel,
                  audio: audio,
                )
              : _PlaylistTilesList(audio: audio),
          transitionDuration: const Duration(milliseconds: 500),
        );
      },
    );

    return AlertDialog(
      title: yaruStyled
          ? YaruDialogTitleBar(
              title: Text(context.l10n.addToPlaylist),
            )
          : Text(context.l10n.addToPlaylist),
      titlePadding: yaruStyled
          ? EdgeInsets.zero
          : const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
      content: SizedBox(height: 200, width: 400, child: nav),
      contentPadding: const EdgeInsets.symmetric(vertical: 20),
    );
  }
}

class _PlaylistTilesList extends StatelessWidget with WatchItMixin {
  const _PlaylistTilesList({
    required this.audio,
  });

  final Audio audio;

  @override
  Widget build(BuildContext context) {
    final playlistNames = watchPropertyValue(
      (LibraryModel m) => m.playlists.keys.map((e) => e.toString()),
    );

    final children = [
      ListTile(
        onTap: () => playlistNavigatorKey.currentState?.pushNamed('/new'),
        leading: SideBarFallBackImage(
          color: Colors.transparent,
          child: Icon(Iconz.plus),
        ),
        title: Text(context.l10n.createNewPlaylist),
      ),
      _PlaylistTile(
        playlistId: kLikedAudiosPageId,
        title: context.l10n.likedSongs,
        iconData: Iconz.heartFilled,
        libraryModel: di<LibraryModel>(),
        audio: audio,
      ),
      ...playlistNames.map(
        (playlistId) => Builder(
          builder: (context) {
            return _PlaylistTile(
              playlistId: playlistId,
              libraryModel: di<LibraryModel>(),
              audio: audio,
            );
          },
        ),
      ),
    ];

    return ListView.separated(
      shrinkWrap: true,
      itemCount: children.length,
      separatorBuilder: (context, index) => const SizedBox(
        height: 10,
      ),
      itemBuilder: (context, index) => children.elementAt(index),
    );
  }
}

class _PlaylistTile extends StatelessWidget {
  const _PlaylistTile({
    required this.libraryModel,
    required this.audio,
    required this.playlistId,
    this.title,
    this.iconData,
  });

  final LibraryModel libraryModel;
  final Audio audio;
  final String playlistId;
  final String? title;
  final IconData? iconData;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        libraryModel.addAudioToPlaylist(playlistId, audio);
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
    required this.libraryModel,
    required this.audio,
  });

  final LibraryModel libraryModel;
  final Audio audio;

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
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).dialogBackgroundColor,
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
              height: 20,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 20,
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
                      widget.libraryModel.addPlaylist(
                        _controller.text,
                        [widget.audio],
                      );
                      showAddedToPlaylistSnackBar(
                        context: context,
                        libraryModel: widget.libraryModel,
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
