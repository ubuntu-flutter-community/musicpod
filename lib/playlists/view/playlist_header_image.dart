import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import '../../common/data/audio.dart';
import '../../common/view/fall_back_header_image.dart';
import '../../common/view/icons.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../library/library_model.dart';
import '../../local_audio/local_audio_model.dart';

class PlaylistHeaderImage extends StatelessWidget with WatchItMixin {
  const PlaylistHeaderImage({
    super.key,
    required this.playlist,
    required this.pageId,
  });

  final String pageId;
  final List<Audio> playlist;

  @override
  Widget build(BuildContext context) {
    final model = di<LocalAudioModel>();
    watchPropertyValue((LibraryModel m) => m.getPlaylistById(pageId)?.hashCode);
    final playlistImages = model.findLocalCovers(audios: playlist, limit: 16);
    final length = playlistImages == null ? 0 : playlistImages.take(16).length;

    final padding = length == 1 ? 0.0 : 8.0;
    final spacing = length == 1 ? 0.0 : 16.0;
    final width = length == 1
        ? kMaxAudioPageHeaderHeight
        : length < 10
            ? 50.0
            : 32.0;
    final height = length == 1
        ? kMaxAudioPageHeaderHeight
        : length < 10
            ? 50.0
            : 32.0;
    final radius = length == 1 ? 0.0 : width / 2;

    Widget image;
    if (length == 0) {
      image = Icon(
        Iconz.playlist,
        size: 65,
      );
    } else {
      image = Center(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: List.generate(
              length,
              (index) => ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: Image.memory(
                  playlistImages!.elementAt(index),
                  width: width,
                  height: height,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return FallBackHeaderImage(
      color: getAlphabetColor(pageId),
      child: image,
    );
  }
}
