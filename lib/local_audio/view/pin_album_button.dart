import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/icons.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../local_audio_manager.dart';

class PinAlbumButton extends StatelessWidget with WatchItMixin {
  const PinAlbumButton({super.key, required this.albumId});

  final int albumId;

  @override
  Widget build(BuildContext context) {
    watchPropertyValue((LocalAudioManager m) => m.pinnedAlbums.length);
    final pinnedAlbum = di<LocalAudioManager>().isPinnedAlbum(albumId);
    return IconButton(
      key: ValueKey(pinnedAlbum),
      tooltip: pinnedAlbum ? context.l10n.unPinAlbum : context.l10n.pinAlbum,
      isSelected: pinnedAlbum,
      icon: Icon(pinnedAlbum ? Iconz.pinFilled : Iconz.pin),
      onPressed: () {
        if (pinnedAlbum) {
          di<LocalAudioManager>().unpinAlbum(
            albumId,
            onFail: () => context.toast(Text(context.l10n.cantUnpinEmptyAlbum)),
          );
        } else {
          di<LocalAudioManager>().pinAlbum(
            albumId,
            onFail: () => context.toast(Text(context.l10n.cantPinEmptyAlbum)),
          );
        }
      },
    );
  }
}
