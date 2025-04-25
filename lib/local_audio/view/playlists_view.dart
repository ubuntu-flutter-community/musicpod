import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app/view/routing_manager.dart';
import '../../common/page_ids.dart';
import '../../common/view/icons.dart';
import '../../common/view/round_image_container.dart';
import '../../common/view/ui_constants.dart';
import '../../custom_content/view/custom_playlists_section.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../playlists/view/playlist_page.dart';

class PlaylistsView extends StatelessWidget {
  const PlaylistsView({
    super.key,
    this.noResultMessage,
    this.noResultIcon,
    required this.playlists,
    this.take,
  });

  final List<String>? playlists;
  final Widget? noResultMessage, noResultIcon;
  final int? take;

  @override
  Widget build(BuildContext context) {
    final lists = [
      PageIDs.customContent,
      PageIDs.likedAudios,
      ...(take != null ? playlists!.take(take!).toList() : playlists ?? []),
    ];

    return SliverGrid.builder(
      itemCount: lists.length,
      gridDelegate: kDiskGridDelegate,
      itemBuilder: (context, index) {
        final id = lists.elementAt(index);
        return YaruSelectableContainer(
          selected: false,
          onTap: () => id == PageIDs.customContent
              ? showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    titlePadding: EdgeInsets.zero,
                    title: YaruDialogTitleBar(
                      title: Text(context.l10n.createNewPlaylist),
                      backgroundColor: Colors.transparent,
                      border: BorderSide.none,
                    ),
                    content: const SizedBox.square(
                      dimension: 450,
                      child: CustomPlaylistsSection(
                        shownInDialog: true,
                      ),
                    ),
                  ),
                )
              : di<RoutingManager>().push(
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
                child: id == PageIDs.customContent
                    ? Container(
                        decoration: BoxDecoration(
                          color: context.colorScheme.surface.scale(
                            lightness: context.colorScheme.isDark ? 0.1 : -0.1,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Iconz.plus),
                      )
                    : id == PageIDs.likedAudios
                        ? Container(
                            decoration: BoxDecoration(
                              color: context.colorScheme.primary
                                  .withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Iconz.heart),
                          )
                        : RoundImageContainer(
                            images: [],
                            fallBackText: id,
                          ),
              ),
              if (id != PageIDs.customContent && id != PageIDs.likedAudios)
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
