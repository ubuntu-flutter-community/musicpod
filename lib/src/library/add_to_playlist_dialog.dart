import 'package:flutter/material.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../common.dart';
import '../../data.dart';
import '../../globals.dart';
import '../../l10n.dart';
import '../../library.dart';
import '../../theme.dart';

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
      onPopPage: (route, result) => route.didPop(result),
      key: playlistNavigatorKey,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final listView = ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              onTap: () => playlistNavigatorKey.currentState?.pushNamed('/new'),
              leading: SideBarFallBackImage(
                color: Colors.transparent,
                child: Icon(Iconz().plus),
              ),
              title: Text(context.l10n.createNewPlaylist),
            ),
            ...libraryModel.getPlaylistNames().map(
                  (playlistId) => Builder(
                    builder: (context) {
                      return _PlaylistTile(
                        playlistId: playlistId,
                        libraryModel: libraryModel,
                        audio: audio,
                      );
                    },
                  ),
                ),
          ],
        );

        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => settings.name == '/new'
              ? _NewView(
                  libraryModel: libraryModel,
                  audio: audio,
                )
              : listView,
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

class _PlaylistTile extends StatelessWidget {
  const _PlaylistTile({
    required this.libraryModel,
    required this.audio,
    required this.playlistId,
  });

  final LibraryModel libraryModel;
  final Audio audio;
  final String playlistId;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        libraryModel.addAudioToPlaylist(playlistId, audio);
        _snack(context, playlistId, libraryModel);
      },
      leading: SideBarFallBackImage(
        color: getAlphabetColor(playlistId),
        child: Icon(Iconz().starFilled),
      ),
      title: Text(playlistId),
    );
  }
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _snack(
  BuildContext context,
  String playlistID,
  LibraryModel libraryModel,
) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  return messenger.showSnackBar(
    SnackBar(
      content: AddToPlaylistSnackBar(
        id: playlistID,
        libraryModel: libraryModel,
      ),
      duration: const Duration(seconds: 5),
    ),
  );
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
                        {widget.audio},
                      );
                      _snack(
                        context,
                        _controller.text,
                        widget.libraryModel,
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
