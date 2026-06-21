import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/icons.dart';
import '../../extensions/build_context_x.dart';
import '../manager/pinned_album_i_ds_manager.dart';

class PinAlbumButton extends StatelessWidget with WatchItMixin {
  const PinAlbumButton({super.key, required this.albumId});

  final int albumId;

  @override
  Widget build(BuildContext context) {
    final pinnedAlbum = watchValue(
      (PinnedAlbumIDsManager m) => m.command.select((e) => e.contains(albumId)),
    );
    return IconButton(
      tooltip: pinnedAlbum ? context.l10n.unPinAlbum : context.l10n.pinAlbum,
      isSelected: pinnedAlbum,
      icon: Icon(pinnedAlbum ? Iconz.pinFilled : Iconz.pin),
      onPressed: () => di<PinnedAlbumIDsManager>().command.run(albumId),
    );
  }
}
