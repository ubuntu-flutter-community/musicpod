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
                  builder: (context) => const ManualAddDialog(),
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
                    : RoundImageContainer(
                        images: const {},
                        fallBackText: id,
                      ),
              ),
              if (id != kNewPlaylistPageId) ArtistVignette(text: id),
            ],
          ),
        );
      },
    );
  }
}
