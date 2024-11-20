import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../common/data/audio.dart';
import '../../common/view/icons.dart';
import '../../common/view/side_bar_fall_back_image.dart';
import '../../common/view/theme.dart';
import '../../constants.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../local_audio/view/album_page.dart';
import '../../local_audio/view/local_audio_page.dart';
import '../../playlists/view/liked_audio_page.dart';
import '../../playlists/view/playlist_page.dart';
import '../../podcasts/view/podcast_page.dart';
import '../../podcasts/view/podcast_page_side_bar_icon.dart';
import '../../podcasts/view/podcast_page_title.dart';
import '../../podcasts/view/podcasts_page.dart';
import '../../radio/view/radio_page.dart';
import '../../radio/view/station_page.dart';
import '../../radio/view/station_page_icon.dart';
import '../../search/view/search_page.dart';
import 'main_page_icon.dart';

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
      iconBuilder: (_) => Icon(Iconz.search),
      pageId: kSearchPageId,
    ),
    MasterItem(
      titleBuilder: (context) => Text(context.l10n.local),
      pageBuilder: (_) => const LocalAudioPage(),
      iconBuilder: (selected) => MainPageIcon(
        audioType: AudioType.local,
        selected: selected,
      ),
      pageId: kLocalAudioPageId,
    ),
    MasterItem(
      titleBuilder: (context) => Text(context.l10n.radio),
      pageBuilder: (_) => const RadioPage(),
      iconBuilder: (selected) => MainPageIcon(
        audioType: AudioType.radio,
        selected: selected,
      ),
      pageId: kRadioPageId,
    ),
    MasterItem(
      titleBuilder: (context) => Text(context.l10n.podcasts),
      pageBuilder: (_) => const PodcastsPage(),
      iconBuilder: (selected) => MainPageIcon(
        audioType: AudioType.podcast,
        selected: selected,
      ),
      pageId: kPodcastsPageId,
    ),
    MasterItem(
      iconBuilder: (selected) => Icon(Iconz.plus),
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
        pageBuilder: (_) => PlaylistPage(pageId: playlist.key),
        iconBuilder: (selected) => SideBarFallBackImage(
          color: getAlphabetColor(playlist.key),
          child: Icon(
            Iconz.playlist,
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
          feedUrl: podcast.key,
          title: podcast.value.firstOrNull?.album ??
              podcast.value.firstOrNull?.title ??
              podcast.value.firstOrNull.toString(),
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
          audio: album.value.firstOrNull,
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
