import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:music/app/common/audio_card.dart';
import 'package:music/app/common/audio_page.dart';
import 'package:music/app/common/constants.dart';
import 'package:music/app/playlists/playlist_model.dart';
import 'package:music/app/podcasts/podcast_model.dart';
import 'package:music/data/audio.dart';
import 'package:music/l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class PodcastSearchField extends StatefulWidget {
  const PodcastSearchField({
    super.key,
    this.onPlay,
  });

  final void Function(Set<Audio>)? onPlay;

  @override
  State<PodcastSearchField> createState() => _PodcastSearchFieldState();
}

class _PodcastSearchFieldState extends State<PodcastSearchField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final text = context.read<PodcastModel>().searchQuery;
    _controller = TextEditingController(text: text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final light = theme.brightness == Brightness.light;
    final model = context.watch<PodcastModel>();
    final playlistModel = context.read<PlaylistModel>();

    return SizedBox(
      key: ObjectKey(model.podcastSearchResult),
      height: 35,
      width: 400,
      child: TextField(
        autofocus: true,
        onChanged: (value) =>
            context.read<PodcastModel>().setSearchQuery(value),
        onSubmitted: (value) {
          model.podcastSearchResult = null;
          var materialPageRoute = MaterialPageRoute(
            builder: (context) {
              return YaruDetailPage(
                appBar: YaruWindowTitleBar(
                  title: const PodcastSearchField(),
                  leading: YaruBackButton(
                    style: YaruBackButtonStyle.rounded,
                    onPressed: () {
                      model.setSearchQuery('');
                      Navigator.maybePop(context);
                    },
                  ),
                ),
                body: model.podcastSearchResult == null
                    ? GridView(
                        padding: const EdgeInsets.all(kYaruPagePadding),
                        gridDelegate: kImageGridDelegate,
                        children:
                            List.generate(30, (index) => const AudioCard())
                                .toList(),
                      )
                    : model.podcastSearchResult!.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(kYaruPagePadding),
                              child: Text(
                                context.l10n.noPodcastFound,
                                style: theme.textTheme.headlineLarge,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : GridView(
                            padding: const EdgeInsets.all(kYaruPagePadding),
                            gridDelegate: kImageGridDelegate,
                            children: [
                              for (final Set<Audio> group
                                  in model.podcastSearchResult ?? {})
                                AudioCard(
                                  imageUrl: group.firstOrNull?.imageUrl,
                                  onPlay: widget.onPlay == null
                                      ? null
                                      : () => widget.onPlay!(group),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) {
                                          final starred = playlistModel
                                              .playlists
                                              .containsKey(
                                            group.first.metadata?.album,
                                          );
                                          return AudioPage(
                                            sort: false,
                                            showTrack: false,
                                            imageUrl: group.first.imageUrl,
                                            likeButton: YaruIconButton(
                                              icon: Icon(
                                                starred
                                                    ? YaruIcons.star_filled
                                                    : YaruIcons.star,
                                              ),
                                              onPressed: starred
                                                  ? () => playlistModel
                                                          .removePlaylist(
                                                        group.first.metadata!
                                                            .album!,
                                                      )
                                                  : () {
                                                      playlistModel.addPlaylist(
                                                        group.first.metadata!
                                                            .album!,
                                                        group,
                                                      );
                                                    },
                                            ),
                                            title: const PodcastSearchField(),
                                            deletable: false,
                                            audioPageType:
                                                AudioPageType.albumList,
                                            editableName: false,
                                            audios: group,
                                            pageName:
                                                group.first.metadata?.album ??
                                                    '',
                                          );
                                        },
                                      ),
                                    );
                                  },
                                )
                            ],
                          ),
              );
            },
          );
          Navigator.of(context).canPop()
              ? Navigator.of(context).pushReplacement(
                  materialPageRoute,
                )
              : Navigator.of(context).push(materialPageRoute);

          model.search(searchQuery: value, useAlbumImage: true);
        },
        controller: _controller,
        focusNode: FocusNode(),
        decoration: InputDecoration(
          hintText: context.l10n.search,
          contentPadding: const EdgeInsets.only(left: 10, right: 10),
          suffixIconConstraints:
              const BoxConstraints(maxHeight: 35, maxWidth: 35),
          suffixIcon: YaruIconButton(
            onPressed: () => _controller.clear(),
            icon: const Icon(
              YaruIcons.edit_clear,
            ),
          ),
          fillColor: light ? Colors.white : Theme.of(context).dividerColor,
        ),
      ),
    );
  }
}
