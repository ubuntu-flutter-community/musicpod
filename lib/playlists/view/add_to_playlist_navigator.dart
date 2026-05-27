import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/page_ids.dart';
import '../../common/data/audio.dart';
import '../../common/view/global_keys.dart';
import '../../common/view/icons.dart';
import '../../common/view/side_bar_fall_back_image.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../local_audio/local_audio_manager.dart';
import '../../local_audio/playlist_action.dart';
import 'add_to_playlist_snack_bar.dart';

class AddToPlaylistNavigator extends StatelessWidget {
  const AddToPlaylistNavigator({super.key, required this.audios});

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
    final playlistNames = watchValue(
      (LocalAudioManager m) => m.allPlaylistsCommand,
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
        localAudioManager: di<LocalAudioManager>(),
        audios: audios,
      ),
      ...playlistNames.map(
        (playlistId) => Builder(
          builder: (context) {
            return _PlaylistTile(
              playlistId: playlistId,
              localAudioManager: di<LocalAudioManager>(),
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
    required this.localAudioManager,
    required this.audios,
    required this.playlistId,
    this.title,
    this.iconData,
  });

  final LocalAudioManager localAudioManager;
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
          localAudioManager.addLikedAudios(audios);
        } else {
          localAudioManager
              .playlistCommand(playlistId)
              .run(
                PlaylistChange(
                  id: playlistId,
                  audios: audios,
                  action: PlaylistAction.addTo,
                ),
              );
        }

        Navigator.of(context, rootNavigator: true).maybePop();
        showAddedToPlaylistSnackBar(context: context, id: playlistId);
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
  const _NewView({required this.audios});

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
    final localAudioManager = di<LocalAudioManager>();
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
            TextField(controller: _controller),
            const SizedBox(height: kLargestSpace),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: kLargestSpace,
                runSpacing: 10,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(context.l10n.cancel),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.pop();
                      localAudioManager
                          .playlistCommand(_controller.text)
                          .run(
                            PlaylistChange(
                              id: _controller.text,
                              audios: widget.audios,
                              action: PlaylistAction.create,
                            ),
                          );
                      showAddedToPlaylistSnackBar(
                        context: context,
                        id: _controller.text,
                      );
                    },
                    child: Text(context.l10n.add),
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
