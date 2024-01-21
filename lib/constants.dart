import 'package:flutter/material.dart';
import 'package:yaru_widgets/constants.dart';

const kAppName = 'musicpod';

const kBusName = 'org.mpris.MediaPlayer2.musicpod';

const kRepoUrl = 'http://github.com/ubuntu-flutter-community/musicpod';

const kSnapDesktopEntry = '/var/lib/snapd/desktop/applications/musicpod';

// TODO: find the correct flatpak desktop entry path
// and sed into line 16
const kFlatPakDesktopEntry = '';

const kDesktopEntry = kSnapDesktopEntry;

const kTinyButtonSize = 30.0;

const kTinyButtonIconSize = 13.0;

const kSearchBarWidth = 350.0;

const kSnackBarWidth = 500.0;

const fullHeightPlayerImageSize = 300.0;

const kAudioPageHeaderHeight = 240.0;

const kSnackBarDuration = Duration(seconds: 10);

const kAudioTilePadding = EdgeInsets.only(left: 25, right: 25);

const kAudioTileTrackPadding = EdgeInsets.only(right: 20);

const kAudioTileSpacing = EdgeInsets.only(right: 10.0);

const kAudioTrackWidth = 40.0;

const kFallbackThumbnail =
    'https://raw.githubusercontent.com/ubuntu-flutter-community/musicpod/main/snap/gui/musicpod.png';

const kGridPadding = EdgeInsets.only(
  top: 0,
  bottom: kYaruPagePadding,
  left: kYaruPagePadding - 5,
  right: kYaruPagePadding - 5,
);
const kMobileGridPadding = EdgeInsets.only(
  top: 0,
  bottom: kYaruPagePadding,
  left: kYaruPagePadding - 5,
  right: kYaruPagePadding - 5,
);

const kHeaderPadding = EdgeInsets.only(
  top: kYaruPagePadding,
  left: kYaruPagePadding,
  right: kYaruPagePadding,
  bottom: kYaruPagePadding - 5,
);

const kCardHeight = 200.0;

const kSmallCardHeight = kCardHeight - 70;

const kCardBottomHeight = 30.0;

const kImageGridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: kSmallCardHeight + 40,
  mainAxisExtent: kSmallCardHeight + kCardBottomHeight + 10,
  mainAxisSpacing: 0,
  crossAxisSpacing: 10,
);

const kMobileImageGridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: kSmallCardHeight + 60,
  mainAxisExtent: kSmallCardHeight + kCardBottomHeight + 10,
  mainAxisSpacing: 0,
  crossAxisSpacing: 10,
);

const kDiskGridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: kSmallCardHeight + 10,
  mainAxisSpacing: 10,
  crossAxisSpacing: 10,
);

const kCardColorLight = Color.fromARGB(255, 233, 233, 233);
const kCardColorDark = Color.fromARGB(255, 51, 51, 51);
const kCardColorNeutral = Color.fromARGB(255, 133, 133, 133);

const kAudioQueueThreshHold = 100;

const kMainPageIconPadding = EdgeInsets.only(right: 4.0);

const kLikedAudiosFileName = 'likedAudios.json';
const kTagFavsFileName = 'tagFavs.json';
const kCountryFavsFileName = 'countryfavs.json';
const kLastFav = 'lastFav';
const kPlaylistsFileName = 'playlists.json';
const kPinnedAlbumsFileName = 'pinnedAlbums.json';
const kPodcastsFileName = 'podcasts.json';
const kPodcastsUpdates = 'podcastsupdates.json';
const kStarredStationsFileName = 'betterStarredStations.json';
const kSettingsFileName = 'settings.json';
const kLastPositionsFileName = 'lastPositions.json';
const kPlayerStateFileName = 'playerstate.json';
const kLocalAudioCacheFileName = 'localaudiocache.json';
const kDownloads = 'downloads.json';
const kFeedsWithDownloads = 'feedswithdownloads.json';
const kLocalAudioCache = 'localAudioCache';
const kUseLocalAudioCache = 'cacheSuggestionDisposed';
const kCreateCacheLimit = 1000;
const kDirectoryProperty = 'directory';
const kRadioUrl = 'de1.api.radio-browser.info';
const kRadioBrowserBaseUrl = 'all.api.radio-browser.info';
const kLastAudio = 'lastAudio';
const kLastPositionAsString = 'lastPositionAsString';
const kLastDurationAsString = 'lastDurationAsString';
const kLocalAudioIndex = 'localAudioIndex';
const kAppIndex = 'appIndex';
const kRadioIndex = 'radioIndex';
const kPodcastIndex = 'podcastIndex';
const kNeverShowImportFails = 'neverShowImportFails';
const kLastCountryCode = 'lastCountryCode';
const kSearchResult = 'searchResult';
const kLocalAudioPageId = 'localAudio';
const kPodcastsPageId = 'podcasts';
const kRadioPageId = 'radio';
const kNewPlaylistPageId = 'newPlaylist';
const kLikedAudiosPageId = 'likedAudios';

const shops = <String, String>{
  'https://us.7digital.com/': '7digital',
  'https://www.hdtracks.com/': 'hdtracks',
  'https://www.qobuz.com': 'qobuz',
  'https://www.amazon.com/music/player': 'Amazon Music',
  'https://bandcamp.com/tag/buy': 'Bandcamp',
};

const kSponsorLink = 'https://github.com/sponsors/Feichtmeier';
