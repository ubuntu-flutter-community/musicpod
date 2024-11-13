import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/icons.dart';
import '../../common/view/round_image_container.dart';
import '../../constants.dart';
import '../../extensions/build_context_x.dart';
import '../../library/library_model.dart';
import '../../playlists/view/manual_add_dialog.dart';
import '../../playlists/view/playlist_page.dart';

class PlaylistsView extends StatelessWidget {
  const PlaylistsView({
    super.key,
    this.noResultMessage,
    this.noResultIcon,
    required this.playlists,
  });

  final List<String>? playlists;
  final Widget? noResultMessage, noResultIcon;

  @override
  Widget build(BuildContext context) {
    final lists = [
      kNewPlaylistPageId,
      kLikedAudiosPageId,
      ...(playlists ?? []),
    ];

    return SliverGrid.builder(
      itemCount: lists.length,
      gridDelegate: kDiskGridDelegate,
      itemBuilder: (context, index) {
        final id = lists.elementAt(index);
        return YaruSelectableContainer(
          selected: false,
          onTap: () => id == kNewPlaylistPageId
              ? showDialog(
                  context: context,
                  builder: (context) =>
                      const ManualAddDialog(onlyPlaylists: true),
                )
              : di<LibraryModel>().push(
                  builder: (_) => PlaylistPage(
                    pageId: id,
                  ),
                  pageId: id,
                ),
          borderRadius: BorderRadius.circular(300),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: id == kNewPlaylistPageId
                    ? Container(
                        decoration: BoxDecoration(
                          color: context.colorScheme.surface.scale(
                            lightness: context.colorScheme.isDark ? 0.1 : -0.1,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Iconz.plus),
                      )
                    : id == kLikedAudiosPageId
                        ? Container(
                            decoration: BoxDecoration(
                              color:
                                  context.colorScheme.primary.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Iconz.heart),
                          )
                        : RoundImageContainer(
                            images: [],
                            fallBackText: id,
                          ),
              ),
              if (id != kNewPlaylistPageId && id != kLikedAudiosPageId)
                ArtistVignette(
                  text: id,
                ),
            ],
          ),
        );
      },
    );
  }
}
