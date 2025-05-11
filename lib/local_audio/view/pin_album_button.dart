import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import '../../common/view/icons.dart';
import '../../common/view/snackbars.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';

class PinAlbumButton extends StatelessWidget with WatchItMixin {
  const PinAlbumButton({super.key, required this.albumId});

  final String albumId;

  @override
  Widget build(BuildContext context) {
    watchPropertyValue((LibraryModel m) => m.favoriteAlbums.length);
    final pinnedAlbum = di<LibraryModel>().isFavoriteAlbum(albumId);
    return IconButton(
      key: ValueKey(pinnedAlbum),
      tooltip: pinnedAlbum ? context.l10n.unPinAlbum : context.l10n.pinAlbum,
      isSelected: pinnedAlbum,
      icon: Icon(
        pinnedAlbum ? Iconz.pinFilled : Iconz.pin,
      ),
      onPressed: () {
        if (pinnedAlbum) {
          di<LibraryModel>().removeFavoriteAlbum(
            albumId,
            onFail: () {
              showSnackBar(
                context: context,
                content: Text(context.l10n.cantUnpinEmptyAlbum),
              );
            },
          );
        } else {
          di<LibraryModel>().addFavoriteAlbum(
            albumId,
            onFail: () {
              showSnackBar(
                context: context,
                content: Text(context.l10n.cantPinEmptyAlbum),
              );
            },
          );
        }
      },
    );
  }
}
