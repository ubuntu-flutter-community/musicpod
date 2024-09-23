import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../playlists/view/add_to_playlist_dialog.dart';
import '../data/audio.dart';
import 'icons.dart';
import 'snackbars.dart';
import 'stream_provider_share_button.dart';
import 'theme.dart';

class AudioTileOptionButton extends StatelessWidget {
  const AudioTileOptionButton({
    super.key,
    required this.audio,
    required this.playlistId,
    required this.insertIntoQueue,
    required this.allowRemove,
    required this.selected,
  });

  final String playlistId;
  final Audio audio;
  final void Function()? insertIntoQueue;

  final bool allowRemove;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final libraryModel = di<LibraryModel>();

    return PopupMenuButton(
      tooltip: context.l10n.moreOptions,
      padding: EdgeInsets.zero,
      itemBuilder: (context) {
        return [
          if (audio.audioType != AudioType.radio)
            PopupMenuItem(
              onTap: () {
                insertIntoQueue?.call();
                showSnackBar(
                  context: context,
                  content: Text(
                    '${context.l10n.addedTo} ${context.l10n.queue}: ${audio.artist} - ${audio.title}',
                  ),
                );
              },
              child: YaruTile(
                leading: Icon(Iconz().insertIntoQueue),
                title: Text(context.l10n.playNext),
              ),
            ),
          if (audio.audioType != AudioType.radio)
            if (allowRemove)
              PopupMenuItem(
                onTap: () =>
                    libraryModel.removeAudioFromPlaylist(playlistId, audio),
                child: YaruTile(
                  leading: Icon(Iconz().remove),
                  title: Text('${context.l10n.removeFrom} $playlistId'),
                ),
              ),
          if (audio.audioType != AudioType.radio)
            PopupMenuItem(
              onTap: () => showDialog(
                context: context,
                builder: (context) {
                  return AddToPlaylistDialog(
                    audio: audio,
                    libraryModel: libraryModel,
                  );
                },
              ),
              child: YaruTile(
                leading: Icon(Iconz().plus),
                title: Text(
                  '${context.l10n.addToPlaylist} ...',
                ),
              ),
            ),
          PopupMenuItem(
            onTap: () => showDialog(
              context: context,
              builder: (context) {
                return MetaDataDialog(audio: audio);
              },
            ),
            child: YaruTile(
              leading: Icon(Iconz().info),
              title: Text(
                '${context.l10n.showMetaData} ...',
              ),
            ),
          ),
          if (audio.audioType != AudioType.radio)
            PopupMenuItem(
              enabled: false,
              padding: EdgeInsets.zero,
              child: Theme(
                data:
                    theme.copyWith(disabledColor: theme.colorScheme.onSurface),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  child: StreamProviderRow(
                    iconColor: theme.colorScheme.onSurface,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    text: '${audio.artist ?? ''} - ${audio.title ?? ''}',
                  ),
                ),
              ),
            ),
        ];
      },
      icon: Icon(Iconz().viewMore),
    );
  }
}

class MetaDataDialog extends StatelessWidget {
  const MetaDataDialog({super.key, required this.audio});

  final Audio audio;

  @override
  Widget build(BuildContext context) {
    final items = <(String, String)>{
      (
        context.l10n.title,
        '${audio.title}',
      ),
      (
        context.l10n.album,
        '${audio.album}',
      ),
      (
        context.l10n.artist,
        '${audio.artist}',
      ),
      (
        context.l10n.albumArtists,
        '${audio.albumArtist}',
      ),
      (
        context.l10n.trackNumber,
        '${audio.trackNumber}',
      ),
      (
        context.l10n.diskNumber,
        '${audio.discNumber}',
      ),
      (
        context.l10n.totalDisks,
        '${audio.discTotal}',
      ),
      (
        context.l10n.genre,
        '${audio.genre}',
      ),
      (
        context.l10n.url,
        (audio.url ?? ''),
      ),
    };

    return AlertDialog(
      title: yaruStyled
          ? YaruDialogTitleBar(
              title: Text(context.l10n.metadata),
            )
          : Center(child: Text(context.l10n.metadata)),
      titlePadding:
          yaruStyled ? EdgeInsets.zero : const EdgeInsets.only(top: 10),
      contentPadding: const EdgeInsets.only(bottom: 12),
      scrollable: true,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map(
              (e) => ListTile(
                dense: true,
                title: Text(e.$1),
                subtitle: Text(e.$2),
              ),
            )
            .toList(),
      ),
    );
  }
}
