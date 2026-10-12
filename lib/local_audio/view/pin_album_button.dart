import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/view/icons.dart';
import '../../extensions/build_context_x.dart';
import '../manager/pinned_album_ids_manager.dart';

class PinAlbumButton extends ConsumerWidget {
  const PinAlbumButton({super.key, required this.albumId});

  final int albumId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinnedAlbum =
        ref.watch(pinnedAlbumIDsManagerProvider).value?.contains(albumId) ??
        false;
    return IconButton(
      tooltip: pinnedAlbum ? context.l10n.unPinAlbum : context.l10n.pinAlbum,
      isSelected: pinnedAlbum,
      icon: Icon(pinnedAlbum ? Iconz.pinFilled : Iconz.pin),
      onPressed: () => ref
          .read(pinnedAlbumIDsManagerProvider.notifier)
          .togglePinAlbum(albumId),
    );
  }
}
