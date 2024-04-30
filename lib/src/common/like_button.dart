import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../library.dart';
import '../../playlists.dart';
import '../../theme.dart';
import '../l10n/l10n.dart';

class LikeButton extends StatefulWidget {
  const LikeButton({
    super.key,
    required this.audio,
    required this.playlistId,
    required this.insertIntoQueue,
    required this.libraryModel,
    required this.allowRemove,
    required this.selected,
  });

  final String playlistId;
  final Audio audio;
  final void Function()? insertIntoQueue;

  final LibraryModel libraryModel;
  final bool allowRemove;
  final bool selected;

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  late bool liked;

  @override
  void initState() {
    super.initState();
    liked = widget.libraryModel.liked(widget.audio);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.t;

    final heartButton = InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        if (liked) {
          setState(() {
            liked = false;
          });
          widget.libraryModel.removeLikedAudio(widget.audio);
        } else {
          setState(() {
            liked = true;
          });
          widget.libraryModel.addLikedAudio(widget.audio);
          showAddedToPlaylistSnackBar(
            context: context,
            libraryModel: widget.libraryModel,
            id: kLikedAudiosPageId,
          );
        }
      },
      child: Iconz().getAnimatedHeartIcon(
        liked: liked,
        color: widget.selected ? theme.colorScheme.primary : null,
      ),
    );

    return YaruPopupMenuButton(
      tooltip: context.l10n.moreOptions,
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.circular(100),
        ),
      ),
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            onTap: widget.insertIntoQueue,
            child: Text(context.l10n.playNext),
          ),
          if (widget.allowRemove)
            PopupMenuItem(
              onTap: () => widget.libraryModel
                  .removeAudioFromPlaylist(widget.playlistId, widget.audio),
              child: Text('${context.l10n.removeFrom} ${widget.playlistId}'),
            ),
          PopupMenuItem(
            onTap: () => showDialog(
              context: context,
              builder: (context) {
                return AddToPlaylistDialog(
                  audio: widget.audio,
                  libraryModel: widget.libraryModel,
                );
              },
            ),
            child: Text(
              '${context.l10n.addToPlaylist} ...',
            ),
          ),
          PopupMenuItem(
            onTap: () => showDialog(
              context: context,
              builder: (context) {
                return MetaDataDialog(audio: widget.audio);
              },
            ),
            child: Text(
              '${context.l10n.showMetaData} ...',
            ),
          ),
          PopupMenuItem(
            padding: EdgeInsets.zero,
            child: StreamProviderRow(
              text:
                  '${widget.audio.artist ?? ''} - ${widget.audio.title ?? ''}',
            ),
          ),
        ];
      },
      child: heartButton,
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
