import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../app_config.dart';
import '../../common/data/audio_type.dart';
import '../../common/page_ids.dart';
import '../../common/view/icons.dart';
import '../../common/view/side_bar_fall_back_image.dart';
import '../../common/view/theme.dart';
import '../../custom_content/view/custom_content_page.dart';
import '../../home/home_page.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../local_audio/view/album_page.dart';
import '../../local_audio/view/local_audio_page.dart';
import '../../playlists/view/liked_audio_page.dart';
import '../../playlists/view/playlist_page.dart';
import '../../podcasts/view/lazy_podcast_page.dart';
import '../../podcasts/view/podcast_page_side_bar_icon.dart';
import '../../podcasts/view/podcast_page_title.dart';
import '../../podcasts/view/podcasts_page.dart';
import '../../radio/view/radio_page.dart';
import '../../radio/view/station_page.dart';
import '../../radio/view/station_page_icon.dart';
import '../../search/view/search_page.dart';
import '../../settings/view/settings_page.dart';
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
      pageId: PageIDs.searchPage,
    ),
    MasterItem(
      titleBuilder: (context) => Text(context.l10n.local),
      pageBuilder: (_) => const LocalAudioPage(),
      iconBuilder: (selected) => MainPageIcon(
        audioType: AudioType.local,
        selected: selected,
      ),
      pageId: PageIDs.localAudio,
    ),
    MasterItem(
      titleBuilder: (context) => Text(context.l10n.radio),
      pageBuilder: (_) => const RadioPage(),
      iconBuilder: (selected) => MainPageIcon(
        audioType: AudioType.radio,
        selected: selected,
      ),
      pageId: PageIDs.radio,
    ),
    MasterItem(
      titleBuilder: (context) => Text(context.l10n.podcasts),
      pageBuilder: (_) => const PodcastsPage(),
      iconBuilder: (selected) => MainPageIcon(
        audioType: AudioType.podcast,
        selected: selected,
      ),
      pageId: PageIDs.podcasts,
    ),
    if (AppConfig.isMobilePlatform)
      MasterItem(
        titleBuilder: (context) => Text(context.l10n.settings),
        iconBuilder: (selected) =>
            Icon(selected ? Iconz.settingsFilled : Iconz.settings),
        pageBuilder: (context) => const SettingsPage(),
        pageId: PageIDs.settings,
      ),
    if (AppConfig.isMobilePlatform)
      MasterItem(
        titleBuilder: (context) => Text(context.l10n.home),
        iconBuilder: (selected) =>
            Icon(selected ? Iconz.homeFilled : Iconz.home),
        pageBuilder: (context) => const HomePage(),
        pageId: PageIDs.homePage,
      ),
    MasterItem(
      iconBuilder: (selected) => Icon(Iconz.plus),
      titleBuilder: (context) => Text(context.l10n.add),
      pageBuilder: (_) => const CustomContentPage(),
      pageId: PageIDs.customContent,
    ),
    MasterItem(
      titleBuilder: (context) => Text(context.l10n.likedSongs),
      pageId: PageIDs.likedAudios,
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
        pageBuilder: (_) => LazyPodcastPage(feedUrl: podcast.key),
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
