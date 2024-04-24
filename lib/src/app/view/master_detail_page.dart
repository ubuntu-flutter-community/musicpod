import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../../build_context_x.dart';
import '../../../common.dart';
import '../../../constants.dart';
import '../../../get.dart';
import '../../../l10n.dart';
import '../../../library.dart';
import '../../../local_audio.dart';
import '../../../playlists.dart';
import '../../../podcasts.dart';
import '../../../radio.dart';
import '../../../settings.dart';
import '../../../theme.dart';
import '../../globals.dart';

class MasterDetailPage extends StatelessWidget with WatchItMixin {
  const MasterDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final libraryModel = watchIt<LibraryModel>();
    final masterItems = _createMasterItems(libraryModel: libraryModel);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: YaruMasterDetailTheme(
        data: YaruMasterDetailTheme.of(context).copyWith(
          sideBarColor: getSideBarColor(context.t),
        ),
        child: YaruMasterDetailPage(
          navigatorKey: navigatorKey,
          onSelected: (value) => libraryModel.setIndex(value ?? 0),
          appBar: HeaderBar(
            backgroundColor: getSideBarColor(context.t),
            style: YaruTitleBarStyle.undecorated,
            adaptive: false,
            title: const Text('MusicPod'),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 10),
                child: SettingsButton(),
              ),
            ],
          ),
          layoutDelegate: const YaruMasterFixedPaneDelegate(
            paneWidth: kMasterDetailSideBarWidth,
          ),
          breakpoint: kMasterDetailBreakPoint,
          controller: YaruPageController(
            length: libraryModel.totalListAmount,
            initialIndex: libraryModel.index ?? 0,
          ),
          tileBuilder: (context, index, selected, availableWidth) {
            final item = masterItems[index];

            return MasterTile(
              pageId: item.pageId,
              libraryModel: libraryModel,
              selected: selected,
              title: item.titleBuilder(context),
              subtitle: item.subtitleBuilder?.call(context),
              leading: item.iconBuilder?.call(
                context,
                selected,
              ),
            );
          },
          pageBuilder: (context, index) => YaruDetailPage(
            body: masterItems[index].pageBuilder(context),
          ),
        ),
      ),
    );
  }

  List<_MasterItem> _createMasterItems({required LibraryModel libraryModel}) {
    return [
      _MasterItem(
        titleBuilder: (context) => Text(context.l10n.localAudio),
        pageBuilder: (context) => const LocalAudioPage(),
        iconBuilder: (context, selected) => LocalAudioPageIcon(
          selected: selected,
        ),
        pageId: kLocalAudioPageId,
      ),
      _MasterItem(
        titleBuilder: (context) => Text(context.l10n.radio),
        pageBuilder: (context) => const RadioPage(),
        iconBuilder: (context, selected) => RadioPageIcon(
          selected: selected,
        ),
        pageId: kRadioPageId,
      ),
      _MasterItem(
        titleBuilder: (context) => Text(context.l10n.podcasts),
        pageBuilder: (context) {
          return const PodcastsPage();
        },
        iconBuilder: (context, selected) => PodcastsPageIcon(
          selected: selected,
        ),
        pageId: kPodcastsPageId,
      ),
      _MasterItem(
        iconBuilder: (context, selected) => Icon(Iconz().plus),
        titleBuilder: (context) => Text(context.l10n.add),
        pageBuilder: (context) => const SizedBox.shrink(),
        pageId: kNewPlaylistPageId,
      ),
      _MasterItem(
        titleBuilder: (context) => Text(context.l10n.likedSongs),
        pageId: kLikedAudiosPageId,
        pageBuilder: (context) => const LikedAudioPage(),
        subtitleBuilder: (context) => Text(context.l10n.playlist),
        iconBuilder: (context, selected) =>
            LikedAudioPage.createIcon(context: context, selected: selected),
      ),
      for (final playlist in libraryModel.playlists.entries)
        _MasterItem(
          titleBuilder: (context) => Text(playlist.key),
          subtitleBuilder: (context) => Text(context.l10n.playlist),
          pageId: playlist.key,
          pageBuilder: (context) => PlaylistPage(playlist: playlist),
          iconBuilder: (context, selected) => SideBarFallBackImage(
            color: getAlphabetColor(playlist.key),
            child: Icon(
              Iconz().playlist,
            ),
          ),
        ),
      for (final podcast in libraryModel.podcasts.entries)
        _MasterItem(
          titleBuilder: (context) => PodcastPageTitle(
            feedUrl: podcast.key,
            title: podcast.value.firstOrNull?.album ??
                podcast.value.firstOrNull?.title ??
                podcast.value.firstOrNull.toString(),
          ),
          subtitleBuilder: (context) => Text(
            podcast.value.firstOrNull?.artist ?? context.l10n.podcast,
          ),
          pageId: podcast.key,
          pageBuilder: (context) => PodcastPage(
            pageId: podcast.key,
            title: podcast.value.firstOrNull?.album ??
                podcast.value.firstOrNull?.title ??
                podcast.value.firstOrNull.toString(),
            audios: podcast.value,
            imageUrl: podcast.value.firstOrNull?.albumArtUrl ??
                podcast.value.firstOrNull?.imageUrl,
          ),
          iconBuilder: (context, selected) => PodcastPage.createIcon(
            context: context,
            imageUrl: podcast.value.firstOrNull?.albumArtUrl ??
                podcast.value.firstOrNull?.imageUrl,
          ),
        ),
      for (final album in libraryModel.pinnedAlbums.entries)
        _MasterItem(
          titleBuilder: (context) => Text(
            album.value.firstOrNull?.album ?? album.key,
          ),
          subtitleBuilder: (context) =>
              Text(album.value.firstOrNull?.artist ?? context.l10n.album),
          pageId: album.key,
          pageBuilder: (context) => AlbumPage(
            album: album.value,
            id: album.key,
          ),
          iconBuilder: (context, selected) => AlbumPage.createIcon(
            context,
            album.value.firstOrNull?.pictureData,
          ),
        ),
      for (final station in libraryModel.starredStations.entries
          .where((e) => e.value.isNotEmpty))
        _MasterItem(
          titleBuilder: (context) =>
              Text(station.value.first.title ?? station.key),
          subtitleBuilder: (context) {
            return Text(context.l10n.station);
          },
          pageId: station.key,
          pageBuilder: (context) => StationPage(
            station: station.value.first,
          ),
          iconBuilder: (context, selected) => StationPage.createIcon(
            context: context,
            imageUrl: station.value.first.imageUrl,
            fallBackColor: getAlphabetColor(station.value.first.title ?? 'a'),
            selected: selected,
          ),
        ),
    ];
  }
}

class _MasterItem {
  _MasterItem({
    required this.titleBuilder,
    this.subtitleBuilder,
    required this.pageBuilder,
    this.iconBuilder,
    required this.pageId,
  });

  final WidgetBuilder titleBuilder;
  final WidgetBuilder? subtitleBuilder;
  final WidgetBuilder pageBuilder;
  final Widget Function(BuildContext context, bool selected)? iconBuilder;
  final String pageId;
}
