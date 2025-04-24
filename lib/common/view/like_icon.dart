import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../playlists/view/add_to_playlist_snack_bar.dart';
import '../data/audio.dart';
import '../page_ids.dart';
import 'animated_like_icon.dart';

class LikeIcon extends StatelessWidget with WatchItMixin {
  const LikeIcon({
    super.key,
    required this.audio,
    this.color,
  });

  final Audio? audio;

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final libraryModel = di<LibraryModel>();

    watchPropertyValue((LibraryModel m) => m.likedAudios.length);

    final liked = libraryModel.isLikedAudio(audio);

    final void Function()? onLike;
    if (audio == null) {
      onLike = null;
    } else {
      onLike = () {
        if (liked) {
          libraryModel.removeLikedAudio(audio!);
        } else {
          libraryModel.addLikedAudio(audio!);
          showAddedToPlaylistSnackBar(
            context: context,
            libraryModel: libraryModel,
            id: PageIDs.likedAudios,
          );
        }
      };
    }

    return IconButton(
      tooltip: liked
          ? context.l10n.removeFromFavorites
          : context.l10n.addToFavorites,
      icon: AnimatedHeart(
        liked: liked,
        color: color,
      ),
      onPressed: onLike,
      color: color,
    );
  }
}

class RadioLikeIcon extends StatelessWidget with WatchItMixin {
  const RadioLikeIcon({
    super.key,
    required this.audio,
    this.color,
  });

  final Audio? audio;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final libraryModel = di<LibraryModel>();

    watchPropertyValue((LibraryModel m) => m.starredStations.length);

    final isStarredStation = libraryModel.isStarredStation(audio?.uuid);

    final void Function()? onLike;
    if (audio == null && audio?.uuid == null) {
      onLike = null;
    } else {
      onLike = () {
        isStarredStation
            ? libraryModel.unStarStation(audio!.uuid!)
            : libraryModel.addStarredStation(
                audio!.uuid!,
              );
      };
    }

    return IconButton(
      tooltip: isStarredStation
          ? context.l10n.removeFromCollection
          : context.l10n.addToCollection,
      icon: AnimatedStar(
        isStarred: isStarredStation,
        color: color,
      ),
      onPressed: onLike,
      color: color,
    );
  }
}
