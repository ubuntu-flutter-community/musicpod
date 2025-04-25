import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../app_config.dart';
import '../../common/data/audio_type.dart';
import '../../common/page_ids.dart';
import '../../common/view/icons.dart';
import '../../common/view/side_bar_fall_back_image.dart';
import '../../common/view/theme.dart';
import '../../custom_content/view/custom_content_page.dart';
import '../../extensions/string_x.dart';
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
import '../../radio/view/station_title.dart';
import '../../search/view/search_page.dart';
import '../../settings/view/settings_page.dart';
import 'main_page_icon.dart';
import 'master_item.dart';

Iterable<MasterItem> getAllMasterItems() => [
      ...permanentMasterItems,
      ...createPlaylistMasterItems(),
      ...createPodcastMasterItems(),
      ...createFavoriteAlbumsMasterItems(),
      ...createStarredStationsMasterItems(),
    ];

Iterable<MasterItem> permanentMasterItems = [
  MasterItem(
    titleBuilder: (context) => Text(context.l10n.search),
    pageBuilder: (_) => const SearchPage(),
    iconBuilder: (_) => Icon(Iconz.search),
    pageId: PageIDs.searchPage,
  ),
  MasterItem(
    titleBuilder: (context) => Text(context.l10n.local),
    pageBuilder: (_) => const LocalAudioPage(),
    iconBuilder: (selected) =>
        MainPageIcon(audioType: AudioType.local, selected: selected),
    pageId: PageIDs.localAudio,
  ),
  MasterItem(
    titleBuilder: (context) => Text(context.l10n.radio),
    pageBuilder: (_) => const RadioPage(),
    iconBuilder: (selected) =>
        MainPageIcon(audioType: AudioType.radio, selected: selected),
    pageId: PageIDs.radio,
  ),
  MasterItem(
    titleBuilder: (context) => Text(context.l10n.podcasts),
    pageBuilder: (_) => const PodcastsPage(),
    iconBuilder: (selected) =>
        MainPageIcon(audioType: AudioType.podcast, selected: selected),
    pageId: PageIDs.podcasts,
  ),
  if (AppConfig.isMobilePlatform)
    MasterItem(
      titleBuilder: (context) => Text(context.l10n.settings),
      iconBuilder: (selected) =>
          Icon(selected ? Iconz.settingsFilled : Iconz.settings),
      pageBuilder: (_) => const SettingsPage(),
      pageId: PageIDs.settings,
    ),
  if (AppConfig.isMobilePlatform)
    MasterItem(
      titleBuilder: (context) => Text(context.l10n.home),
      iconBuilder: (selected) => Icon(selected ? Iconz.homeFilled : Iconz.home),
      pageBuilder: (_) => const HomePage(),
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
];

Iterable<MasterItem> createPlaylistMasterItems() =>
    di<LibraryModel>().playlistIDs.map(
          (id) => MasterItem(
            titleBuilder: (context) => Text(id),
            subtitleBuilder: (context) => Text(context.l10n.playlist),
            pageId: id,
            pageBuilder: (_) => PlaylistPage(pageId: id),
            iconBuilder: (selected) => SideBarFallBackImage(
              color: getAlphabetColor(id),
              child: Icon(Iconz.playlist),
            ),
          ),
        );

Iterable<MasterItem> createStarredStationsMasterItems() =>
    di<LibraryModel>().starredStations.map(
          (uuid) => MasterItem(
            titleBuilder: (_) => StationTitle(uuid: uuid),
            subtitleBuilder: (context) => Text(context.l10n.station),
            pageId: uuid,
            pageBuilder: (_) => StationPage(uuid: uuid),
            iconBuilder: (selected) => StationPageIcon(
              uuid: uuid,
              selected: selected,
            ),
          ),
        );

Iterable<MasterItem> createFavoriteAlbumsMasterItems() =>
    di<LibraryModel>().favoriteAlbums.map(
          (id) => MasterItem(
            titleBuilder: (context) => Text(id.albumOfId),
            subtitleBuilder: (context) => Text(id.artistOfId),
            pageId: id,
            pageBuilder: (_) => AlbumPage(id: id),
            iconBuilder: (selected) => AlbumPageSideBarIcon(
              albumId: id,
            ),
          ),
        );

Iterable<MasterItem> createPodcastMasterItems() =>
    di<LibraryModel>().podcastFeedUrls.map(
          (feedUrl) => MasterItem(
            titleBuilder: (_) => PodcastPageTitle(
              feedUrl: feedUrl,
            ),
            subtitleBuilder: (_) => PodcastPageSubTitle(feedUrl: feedUrl),
            pageId: feedUrl,
            pageBuilder: (_) => LazyPodcastPage(feedUrl: feedUrl),
            iconBuilder: (selected) => PodcastPageSideBarIcon(feedUrl: feedUrl),
          ),
        );
