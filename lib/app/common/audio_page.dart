import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:music/app/common/audio_list.dart';
import 'package:music/app/common/audio_tile.dart';
import 'package:music/app/common/search_field.dart';
import 'package:music/app/player_model.dart';
import 'package:music/app/playlists/playlist_dialog.dart';
import 'package:music/app/playlists/playlist_model.dart';
import 'package:music/data/audio.dart';
import 'package:music/l10n/l10n.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class AudioPage extends StatelessWidget {
  const AudioPage({
    super.key,
    required this.audios,
    required this.pageName,
    this.editableName = true,
    this.audioPageType = AudioPageType.list,
  });

  final Set<Audio> audios;
  final String pageName;
  final bool editableName;
  final AudioPageType audioPageType;

  @override
  Widget build(BuildContext context) {
    final playerModel = context.watch<PlayerModel>();
    final playlistModel = context.watch<PlaylistModel>();
    final theme = Theme.of(context);

    Widget? body = Padding(
      padding: const EdgeInsets.only(top: 20),
      child: AudioList(
        audios: audios,
        editableName: editableName,
      ),
    );
    if (audioPageType == AudioPageType.albumList) {
      body = ListView(
        children: [
          FutureBuilder<Color?>(
            future: getColor(audios.firstOrNull),
            builder: (context, snapshot) {
              return Container(
                height: 240,
                color: snapshot.data ?? theme.cardColor,
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (audios.firstOrNull?.metadata?.picture != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            audios.firstOrNull!.metadata!.picture!.data,
                            width: 200.0,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            context.l10n.album,
                            style: theme.textTheme.labelSmall,
                          ),
                          Text(
                            audios.firstOrNull!.metadata!.album ?? '',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.w300,
                              fontSize: 50,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.8),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            audios.firstOrNull?.metadata?.artist ?? '',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.hintColor,
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: 15,
            ),
            child: AudioListControlPanel(
              editableName: false,
              audios: audios,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
            ),
            child: AudioListHeader(),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Column(
              children: List.generate(audios.length, (index) {
                final audio = audios.elementAt(index);
                final audioSelected = playerModel.audio == audio;

                final liked = playlistModel.liked(audio);

                return AudioTile(
                  key: ValueKey(audio),
                  selected: audioSelected,
                  audio: audio,
                  // TODO: extract popup menu button!!!
                  likeIcon: YaruPopupMenuButton(
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        side: BorderSide.none,
                        borderRadius: BorderRadius.circular(kYaruButtonRadius),
                      ),
                    ),
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          child: Text(context.l10n.createNewPlaylist),
                          onTap: () => showDialog(
                            context: context,
                            builder: (context) {
                              return ChangeNotifierProvider.value(
                                value: playlistModel,
                                child: PlaylistDialog(
                                  audios: {audio},
                                ),
                              );
                            },
                          ),
                        ),
                        if (playlistModel.playlists.containsKey(pageName))
                          PopupMenuItem(
                            child: Text('Remove from $pageName'),
                            onTap: () => playlistModel.removeAudioFromPlaylist(
                              pageName,
                              audio,
                            ),
                          ),
                        for (final playlist
                            in playlistModel.playlists.entries.take(5).toList())
                          if (playlist.key != 'likedAudio')
                            PopupMenuItem(
                              child: Text(
                                '${context.l10n.addTo} ${playlist.key == 'likedAudio' ? context.l10n.likedSongs : playlist.key}',
                              ),
                              onTap: () => playlistModel.addAudioToPlaylist(
                                playlist.key,
                                audio,
                              ),
                            )
                      ];
                    },
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => liked
                          ? playlistModel.removeLikedAudio(audio)
                          : playlistModel.addLikedAudio(audio),
                      child: Icon(
                        liked ? YaruIcons.heart_filled : YaruIcons.heart,
                        color: audioSelected
                            ? theme.colorScheme.onSurface
                            : theme.hintColor,
                      ),
                    ),
                  ),
                );
              }),
            ),
          )
        ],
      );
    }

    return YaruDetailPage(
      backgroundColor: theme.brightness == Brightness.dark
          ? const Color.fromARGB(255, 37, 37, 37)
          : Colors.white,
      appBar: YaruWindowTitleBar(
        title: const SearchField(),
        leading: Navigator.canPop(context)
            ? const YaruBackButton(
                style: YaruBackButtonStyle.rounded,
              )
            : const SizedBox(
                width: 40,
              ),
      ),
      body: body,
    );
  }
}

enum AudioPageType {
  albumList,
  list,
  grid,
  artistGrid,
}

Future<Color?> getColor(Audio? audio) async {
  if (audio == null || audio.path == null) return null;

  final image = MemoryImage(
    audio.metadata!.picture!.data,
  );
  final generator = await PaletteGenerator.fromImageProvider(image);
  return generator.dominantColor?.color.withOpacity(0.1);
}
