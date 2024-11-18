import '../../constants.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../player/player_model.dart';
import '../../playlists/view/add_to_playlist_dialog.dart';
import '../data/audio.dart';
import 'audio_tile_image.dart';
import 'icons.dart';
import 'like_icon.dart';
import 'meta_data_dialog.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'snackbars.dart';
import 'spaced_divider.dart';
import 'stream_provider_share_button.dart';
import 'theme.dart';

class AudioTileBottomSheet extends StatelessWidget {
  const AudioTileBottomSheet({
    super.key,
    required this.audio,
    required this.allowRemove,
    required this.playlistId,
  });

  final Audio audio;
  final bool allowRemove;
  final String playlistId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final libraryModel = di<LibraryModel>();
    return BottomSheet(
      enableDrag: false,
      onClosing: () {},
      builder: (context) {
        var searchTerm = '${audio.artist ?? ''} - ${audio.title ?? ''}';
        return SizedBox(
          height: 460,
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.only(
                  left: 15,
                  right: 15,
                  top: 5,
                ),
                title: Text(audio.title ?? ''),
                subtitle: Text(audio.artist ?? ''),
                leading: AudioTileImage(
                  size: kAudioTrackWidth,
                  audio: audio,
                ),
                trailing: switch (audio.audioType) {
                  AudioType.radio => RadioLikeIcon(
                      audio: audio,
                    ),
                  AudioType.local => LikeIcon(
                      audio: audio,
                    ),
                  _ => null,
                },
              ),
              const SpacedDivider(
                bottom: 20,
                top: 10,
                left: 0,
                right: 0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: SizedBox(
                  height: 100,
                  child: Row(
                    children: space(
                      widthGap: 10,
                      children: [
                        if (audio.audioType != AudioType.radio)
                          Column(
                            children: [
                              _Button(
                                icon: Icon(Iconz.plus),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        AddToPlaylistDialog(audio: audio),
                                  );
                                },
                              ),
                              _ButtonLabel(label: l10n.addToPlaylist),
                            ],
                          ),
                        if (audio.audioType != AudioType.radio)
                          Column(
                            children: [
                              _Button(
                                onPressed: () {
                                  di<PlayerModel>().insertIntoQueue(audio);
                                  Navigator.of(context).pop();
                                  showSnackBar(
                                    context: context,
                                    content: Text(
                                      '${l10n.addedTo} ${l10n.queue}: ${audio.artist} - ${audio.title}',
                                    ),
                                  );
                                },
                                icon: Icon(Iconz.insertIntoQueue),
                              ),
                              _ButtonLabel(label: l10n.playNext),
                            ],
                          ),
                        if (allowRemove)
                          Column(
                            children: [
                              _Button(
                                onPressed: () {
                                  playlistId == kLikedAudiosPageId
                                      ? libraryModel.removeLikedAudio(audio)
                                      : libraryModel.removeAudioFromPlaylist(
                                          playlistId,
                                          audio,
                                        );
                                  Navigator.of(context).pop();
                                },
                                icon: Icon(Iconz.remove),
                              ),
                              _ButtonLabel(
                                label:
                                    '${l10n.removeFrom} ${playlistId == kLikedAudiosPageId ? l10n.likedSongs : playlistId}',
                              ),
                            ],
                          ),
                        Column(
                          children: [
                            _Button(
                              onPressed: () {
                                Navigator.of(context).pop();
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return MetaDataDialog(audio: audio);
                                  },
                                );
                              },
                              icon: Icon(Iconz.info),
                            ),
                            _ButtonLabel(label: l10n.showMetaData),
                          ],
                        ),
                      ].map((e) => Expanded(child: e)).toList(),
                    ),
                  ),
                ),
              ),
              if (audio.audioType != AudioType.radio)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        StreamProviderShareButton(
                          streamProvider: StreamProvider.youTubeMusic,
                          text: searchTerm,
                          tile: true,
                        ),
                        StreamProviderShareButton(
                          text: searchTerm,
                          tile: true,
                          streamProvider: StreamProvider.spotify,
                        ),
                        StreamProviderShareButton(
                          text: searchTerm,
                          tile: true,
                          streamProvider: StreamProvider.appleMusic,
                        ),
                        StreamProviderShareButton(
                          text: searchTerm,
                          tile: true,
                          streamProvider: StreamProvider.amazonMusic,
                        ),
                        StreamProviderShareButton(
                          text: searchTerm,
                          tile: true,
                          streamProvider: StreamProvider.amazon,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({
    required this.icon,
    required this.onPressed,
  });

  final Widget icon;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: IconButton.filledTonal(
        color: context.colorScheme.onSurface,
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          backgroundColor: context.colorScheme.onSurface.withOpacity(0.1),
        ),
        onPressed: onPressed,
        icon: icon,
      ),
    );
  }
}

class _ButtonLabel extends StatelessWidget {
  const _ButtonLabel({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(
          label,
          style: context.textTheme.labelMedium,
          overflow: TextOverflow.ellipsis,
          maxLines: 3,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
