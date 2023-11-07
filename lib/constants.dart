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

const kSearchBarWidth = 350.0;

const kSnackBarWidth = 500.0;

const fullHeightPlayerImageSize = 300.0;

const kAudioPageHeaderHeight = 240.0;

const kSnackBarDuration = Duration(seconds: 10);

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

const kShimmerBaseLight = Color.fromARGB(120, 230, 230, 230);
const kShimmerBaseDark = Color.fromARGB(255, 51, 51, 51);
const kShimmerHighLightLight = Color.fromARGB(197, 218, 218, 218);
const kShimmerHighLightDark = Color.fromARGB(255, 57, 57, 57);

const kAudioQueueThreshHold = 100;

const kLikedAudios = 'likedAudios.json';
const kTagFavsFileName = 'tagFavs.json';
const kLastFav = 'lastFav';
const kPlaylistsFileName = 'playlists.json';
const kPinnedAlbumsFileName = 'pinnedAlbums.json';
const kPodcastsFileName = 'podcasts.json';
const kStarredStationsFileName = 'starredStations.json';
const kSettingsFileName = 'settings.json';
const kLastPositionsFileName = 'lastPositions.json';
const kDirectoryProperty = 'directory';
const kRadioUrl = 'de1.api.radio-browser.info';
const kRadioBrowserBaseUrl = 'all.api.radio-browser.info';
const kLastAudio = 'lastAudio';
const kLastPositionAsString = 'lastPositionAsString';
const kLastDurationAsString = 'lastDurationAsString';
const kLocalAudioIndex = 'localAudioIndex';
const kAppIndex = 'appIndex';
const kNeverShowImportFails = 'neverShowImportFails';

const shops = <String, String>{
  'https://us.7digital.com/': '7digital',
  'https://www.hdtracks.com/': 'hdtracks',
  'https://www.qobuz.com': 'qobuz',
  'https://www.amazon.com/music/player': 'Amazon Music',
  'https://bandcamp.com/tag/buy': 'Bandcamp',
};
