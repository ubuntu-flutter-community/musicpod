import 'package:flutter/material.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SuperLikeButton extends StatelessWidget {
  const SuperLikeButton({
    super.key,
    this.onCreateNewPlaylist,
    this.onRemoveFromPlaylist,
    this.onAddToPlaylist,
    this.playlistId,
    this.topFivePlaylistIds,
    this.onTap,
    this.icon,
  });

  final void Function()? onCreateNewPlaylist;
  final void Function(String playlistId)? onRemoveFromPlaylist;
  final void Function(String playlistId)? onAddToPlaylist;
  final String? playlistId;
  final List<String>? topFivePlaylistIds;
  final void Function()? onTap;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return YaruPopupMenuButton(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.circular(kYaruButtonRadius),
        ),
      ),
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            onTap: onCreateNewPlaylist,
            child: Text(context.l10n.createNewPlaylist),
          ),
          if (onRemoveFromPlaylist != null)
            PopupMenuItem(
              onTap: onRemoveFromPlaylist == null || playlistId == null
                  ? null
                  : () => onRemoveFromPlaylist!(playlistId!),
              child: Text('Remove from $playlistId'),
            ),
          if (topFivePlaylistIds != null)
            for (final playlist in topFivePlaylistIds!)
              PopupMenuItem(
                onTap: onAddToPlaylist == null
                    ? null
                    : () => onAddToPlaylist!(playlist),
                child: Text(
                  '${context.l10n.addTo} $playlist',
                ),
              )
        ];
      },
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: icon,
      ),
    );
  }
}
