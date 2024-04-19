import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../../data.dart';
import '../../../get.dart';
import '../../../l10n.dart';
import '../../../library.dart';
import '../../common/icons.dart';

class PlayerLikeIcon extends StatelessWidget with WatchItMixin {
  const PlayerLikeIcon({
    super.key,
    required this.audio,
    this.color,
  });

  final Audio? audio;

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final libraryModel = getIt<LibraryModel>();

    watchPropertyValue((LibraryModel m) => m.likedAudios.length);
    watchPropertyValue((LibraryModel m) => m.starredStations.length);

    final isStarredStation = libraryModel.isStarredStation(audio?.url);
    final liked = libraryModel.liked(audio);

    Widget likeIcon;
    if (audio?.audioType == AudioType.radio) {
      likeIcon = Iconz().getAnimatedStar(isStarredStation);
    } else {
      likeIcon = Iconz().getAnimatedHeartIcon(liked: liked);
    }

    final void Function()? onLike;
    if (audio == null && audio?.url == null) {
      onLike = null;
    } else {
      if (audio?.audioType == AudioType.radio) {
        onLike = () {
          isStarredStation
              ? libraryModel.unStarStation(audio!.url!)
              : libraryModel.addStarredStation(
                  audio!.url!,
                  {audio!},
                );
        };
      } else {
        onLike = () {
          if (liked) {
            libraryModel.removeLikedAudio(audio!, true);
          } else {
            libraryModel.addLikedAudio(audio!, true);
            showAddedToPlaylistSnackBar(
              context: context,
              libraryModel: libraryModel,
              id: kLikedAudiosPageId,
            );
          }
        };
      }
    }

    final toolTip = audio?.audioType == AudioType.local
        ? liked
            ? context.l10n.removeFromFavorites
            : context.l10n.addToFavorites
        : isStarredStation
            ? context.l10n.removeFromCollection
            : context.l10n.addToCollection;

    return IconButton(
      tooltip: toolTip,
      icon: likeIcon,
      onPressed: onLike,
      color: color,
    );
  }
}
