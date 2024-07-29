import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/back_gesture.dart';
import '../../common/view/global_keys.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/icons.dart';
import '../../common/view/side_bar_fall_back_image.dart';
import '../../common/view/theme.dart';
import '../../constants.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../local_audio/view/album_page.dart';
import '../../local_audio/view/local_audio_page.dart';
import '../../playlists/view/liked_audio_page.dart';
import '../../playlists/view/manual_add_dialog.dart';
import '../../playlists/view/playlist_page.dart';
import '../../podcasts/view/podcast_page.dart';
import '../../podcasts/view/podcasts_page.dart';
import '../../radio/view/radio_page.dart';
import '../../radio/view/radio_page_icon.dart';
import '../../radio/view/station_page.dart';
import '../../radio/view/station_page_icon.dart';
import '../../search/view/search_page.dart';
import '../../settings/view/settings_tile.dart';
import 'master_tile.dart';

class MasterDetailPage extends StatelessWidget with WatchItMixin {
  const MasterDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final libraryModel = watchIt<LibraryModel>();
    final masterItems = createMasterItems(libraryModel: libraryModel);

    return Scaffold(
      resizeToAvoidBottomInset: isMobile ? false : null,
      key: masterScaffoldKey,
      drawer: Drawer(
        width: kMasterDetailSideBarWidth,
        child: Stack(
          children: [
            MasterPanel(masterItems: masterItems, libraryModel: libraryModel),
            Positioned(
              top: 5,
              right: 5,
              child: IconButton(
                onPressed: masterScaffoldKey.currentState?.closeDrawer,
                icon: Icon(
                  Iconz().close,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          if (context.showMasterPanel)
            MasterPanel(
              masterItems: masterItems,
              libraryModel: libraryModel,
            ),
          const VerticalDivider(),
          Expanded(
            child: BackGesture(
              child: Navigator(
                onPopPage: (route, result) => route.didPop(result),
                key: masterNavigator,
                onGenerateRoute: (settings) {
                  final page = (masterItems.firstWhereOrNull(
                            (e) =>
                                e.pageId == settings.name ||
                                e.pageId == libraryModel.selectedPageId,
                          ) ??
                          masterItems.elementAt(0))
                      .pageBuilder(context);

                  return PageRouteBuilder(
                    pageBuilder: (_, __, ___) => page,
                    transitionsBuilder: (_, a, __, c) =>
                        FadeTransition(opacity: a, child: c),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MasterPanel extends StatelessWidget {
  const MasterPanel({
    super.key,
    required this.masterItems,
    required this.libraryModel,
  });

  final List<MasterItem> masterItems;
  final LibraryModel libraryModel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: kMasterDetailSideBarWidth,
      child: Column(
        children: [
          const HeaderBar(
            includeBackButtonAsLeading: false,
            backgroundColor: Colors.transparent,
            style: YaruTitleBarStyle.undecorated,
            adaptive: false,
            title: Text(kAppTitle),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: masterItems.length,
              itemBuilder: (context, index) {
                final item = masterItems.elementAt(index);
                return MasterTile(
                  onTap: () {
                    if (item.pageId == kNewPlaylistPageId) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return const ManualAddDialog();
                        },
                      );
                    } else {
                      libraryModel.pushNamed(pageId: item.pageId);
                    }

                    if (!context.showMasterPanel) {
                      masterScaffoldKey.currentState?.closeDrawer();
                    }
                  },
                  pageId: item.pageId,
                  libraryModel: libraryModel,
                  leading: item.iconBuilder
                      ?.call(libraryModel.selectedPageId == item.pageId),
                  title: item.titleBuilder(context),
                  subtitle: item.subtitleBuilder?.call(context),
                  selected: libraryModel.selectedPageId == item.pageId,
                );
              },
              separatorBuilder: (_, __) => const SizedBox(
                height: 5,
              ),
            ),
          ),
          const SettingsTile(),
        ],
      ),
    );
  }
}

class MasterItem {
  MasterItem({
    required this.titleBuilder,
    this.subtitleBuilder,
    required this.pageBuilder,
    this.iconBuilder,
    required this.pageId,
  });

  final WidgetBuilder titleBuilder;
  final WidgetBuilder? subtitleBuilder;
  final WidgetBuilder pageBuilder;
  final Widget Function(bool selected)? iconBuilder;
  final String pageId;
}

List<MasterItem> createMasterItems({required LibraryModel libraryModel}) {
  return [
    MasterItem(
      titleBuilder: (context) => Text(context.l10n.search),
      pageBuilder: (_) => const SearchPage(),
      iconBuilder: (_) => Icon(Iconz().search),
      pageId: kSearchPageId,
    ),
    MasterItem(
      titleBuilder: (context) => Text(context.l10n.localAudio),
      pageBuilder: (_) => const LocalAudioPage(),
      iconBuilder: (selected) => LocalAudioPageIcon(
        selected: selected,
      ),
      pageId: kLocalAudioPageId,
    ),
    MasterItem(
      titleBuilder: (context) => Text(context.l10n.radio),
      pageBuilder: (_) => const RadioPage(),
      iconBuilder: (selected) => RadioPageIcon(
        selected: selected,
      ),
      pageId: kRadioPageId,
    ),
    MasterItem(
      titleBuilder: (context) => Text(context.l10n.podcasts),
      pageBuilder: (_) => const PodcastsPage(),
      iconBuilder: (selected) => PodcastsPageIcon(
        selected: selected,
      ),
      pageId: kPodcastsPageId,
    ),
    MasterItem(
      iconBuilder: (selected) => Icon(Iconz().plus),
      titleBuilder: (context) => Text(context.l10n.add),
      pageBuilder: (_) => const SizedBox.shrink(),
      pageId: kNewPlaylistPageId,
    ),
    MasterItem(
      titleBuilder: (context) => Text(context.l10n.likedSongs),
      pageId: kLikedAudiosPageId,
      pageBuilder: (_) => const LikedAudioPage(),
      subtitleBuilder: (context) => Text(context.l10n.playlist),
      iconBuilder: (selected) => LikedAudioPageIcon(selected: selected),
    ),
    for (final playlist in libraryModel.playlists.entries)
      MasterItem(
        titleBuilder: (context) => Text(playlist.key),
        subtitleBuilder: (context) => Text(context.l10n.playlist),
        pageId: playlist.key,
        pageBuilder: (_) => PlaylistPage(playlist: playlist),
        iconBuilder: (selected) => SideBarFallBackImage(
          color: getAlphabetColor(playlist.key),
          child: Icon(
            Iconz().playlist,
          ),
        ),
      ),
    for (final podcast in libraryModel.podcasts.entries)
      MasterItem(
        titleBuilder: (_) => PodcastPageTitle(
          feedUrl: podcast.key,
          title: podcast.value.firstOrNull?.album ??
              podcast.value.firstOrNull?.title ??
              podcast.value.firstOrNull.toString(),
        ),
        subtitleBuilder: (context) => Text(
          podcast.value.firstOrNull?.artist ?? context.l10n.podcast,
        ),
        pageId: podcast.key,
        pageBuilder: (_) => PodcastPage(
          pageId: podcast.key,
          title: podcast.value.firstOrNull?.album ??
              podcast.value.firstOrNull?.title ??
              podcast.value.firstOrNull.toString(),
          audios: podcast.value,
          imageUrl: podcast.value.firstOrNull?.albumArtUrl ??
              podcast.value.firstOrNull?.imageUrl,
        ),
        iconBuilder: (selected) => PodcastPageSideBarIcon(
          imageUrl: podcast.value.firstOrNull?.albumArtUrl ??
              podcast.value.firstOrNull?.imageUrl,
        ),
      ),
    for (final album in libraryModel.pinnedAlbums.entries)
      MasterItem(
        titleBuilder: (context) => Text(
          album.value.firstOrNull?.album ?? album.key,
        ),
        subtitleBuilder: (context) =>
            Text(album.value.firstOrNull?.artist ?? context.l10n.album),
        pageId: album.key,
        pageBuilder: (_) => AlbumPage(
          album: album.value,
          id: album.key,
        ),
        iconBuilder: (selected) => AlbumPageSideBarIcon(
          picture: album.value.firstOrNull?.pictureData,
          album: album.value.firstWhereOrNull((e) => e.album != null)?.album,
        ),
      ),
    for (final station in libraryModel.starredStations.entries
        .where((e) => e.value.isNotEmpty))
      MasterItem(
        titleBuilder: (context) =>
            Text(station.value.first.title ?? station.key),
        subtitleBuilder: (context) {
          return Text(context.l10n.station);
        },
        pageId: station.key,
        pageBuilder: (_) => StationPage(
          station: station.value.first,
        ),
        iconBuilder: (selected) => StationPageIcon(
          imageUrl: station.value.first.imageUrl,
          fallBackColor: getAlphabetColor(station.value.first.title ?? 'a'),
          selected: selected,
        ),
      ),
  ];
}
