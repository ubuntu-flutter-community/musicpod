import 'package:flutter/material.dart';
import 'package:yaru/constants.dart';

const kAppName = 'musicpod';

const kLinuxDBusName = 'org.mpris.MediaPlayer2.musicpod';

const kAndroidChannelId = 'org.feichtmeier.musicpod.channel.audio';

const kRepoUrl = 'http://github.com/ubuntu-flutter-community/musicpod';

const kSnapDesktopEntry = '/var/lib/snapd/desktop/applications/musicpod';

const kFlatPakDesktopEntry = '';

const kDesktopEntry = kSnapDesktopEntry;

const kGitHubShortLink = 'ubuntu-flutter-community/musicpod';

const kAppTitle = 'MusicPod';

const kTinyButtonSize = 30.0;

const kTinyButtonIconSize = 13.0;

const kSearchBarWidth = 335.0;

const kSnackBarWidth = 500.0;

const fullHeightPlayerImageSize = 300.0;

const kMaxAudioPageHeaderHeight = 200.0;

const kMinAudioPageHeaderHeight = 0.0;

const kSnackBarDuration = Duration(seconds: 10);

const kClassicAudioTilePadding = EdgeInsets.symmetric(horizontal: 25);

const kModernAudioTilePadding = EdgeInsets.symmetric(horizontal: 20);

const kAudioTileTrackPadding = EdgeInsets.only(right: 20);

const kAudioTileSpacing = EdgeInsets.only(right: 10.0);

const kAudioTrackWidth = 40.0;

const kSideBarThreshHold = 1500.0;

const kSideBarPlayerWidth = 500.0;

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

const kAudioCardDimension = 130.0;

const kAudioCardBottomHeight = 30.0;

const kMasterDetailBreakPoint = 720.0;

const kMasterDetailSideBarWidth = 250.0;

const kAdaptivContainerBreakPoint = 1200.0;

const kAudioCardGridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: kAudioCardDimension + 40,
  mainAxisExtent: kAudioCardDimension + kAudioCardBottomHeight + 8,
  mainAxisSpacing: 0,
  crossAxisSpacing: 10,
);

const kMobileAudioCardGridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: kAudioCardDimension,
  mainAxisExtent: kAudioCardDimension + kAudioCardBottomHeight + 5,
  mainAxisSpacing: 0,
  crossAxisSpacing: 10,
);

const kDiskGridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: kAudioCardDimension + 10,
  mainAxisSpacing: 10,
  crossAxisSpacing: 10,
);

const kAudioControlPanelPadding = EdgeInsets.only(
  top: kYaruPagePadding / 2,
  left: kYaruPagePadding,
  right: kYaruPagePadding,
  bottom: kYaruPagePadding / 2,
);

const kAudioQueueThreshHold = 100;

const kMainPageIconPadding = EdgeInsets.only(right: 4.0);

const kLikedAudiosFileName = 'likedAudios.json';
const kRadioTagFavsFileName = 'tagFavs.json';
const kCountryFavsFileName = 'countryfavs.json';
const kFavLanguageCodesFileName = 'languagefavs.json';
const kLastRadioTag = 'lastFav';
const kPlaylistsFileName = 'playlists.json';
const kPinnedAlbumsFileName = 'finallyFixedPinnedAlbums.json';
const kPodcastsFileName = 'podcasts.json';
const kPodcastsUpdates = 'podcastsupdates.json';
const kStarredStationsFileName = 'betterStarredStations.json';
const kSettingsFileName = 'settings.json';
const kLastPositionsFileName = 'lastPositions.json';
const kPlayerStateFileName = 'playerstate.json';
const kAppStateFileName = 'appstate.json';
const kRadioHistoryFileName = 'radiohistory.json';
const kDownloads = 'downloads.json';
const kFeedsWithDownloads = 'feedswithdownloads.json';
const kCoverStore = 'coverStore.json';
const kDirectoryProperty = 'directory';
const kRadioUrl = 'de1.api.radio-browser.info';
const kRadioBrowserBaseUrl = 'all.api.radio-browser.info';
const kLastAudio = 'lastAudio';
const kLastPositionAsString = 'lastPositionAsString';
const kLastDurationAsString = 'lastDurationAsString';
const kLocalAudioIndex = 'localAudioIndex';
const kSelectedPageId = 'selectedPageId';
const kRadioIndex = 'radioIndex';
const kPodcastIndex = 'podcastIndex';
const kNeverShowImportFails = 'neverShowImportFails';
const kLastCountryCode = 'lastCountryCode';
const kLastLanguageCode = 'lastLanguageCode';
const kSearchResult = 'searchResult';
const kLocalAudioPageId = 'localAudio';
const kPodcastsPageId = 'podcasts';
const kRadioPageId = 'radio';
const kNewPlaylistPageId = 'newPlaylist';
const kLikedAudiosPageId = 'likedAudios';
const kUsePodcastIndex = 'usePodcastIndex';
const kThemeIndex = 'themeIndex';
const kPodcastIndexApiKey = 'podcastIndexApiKey';
const kPodcastIndexApiSecret = 'podcastIndexApiSecret';
const kUseArtistGridView = 'useArtistGridView';
const kSearchPageId = 'searchPageId';
const kFavRadioTags = 'favRadioTags';
const kFavCountryCodes = 'favCountryCodes';
const kFavLanguageCodes = 'favLanguageCodes';
const kAscendingFeeds = 'ascendingfeed:::';
const kPatchNotesDisposed = 'kPatchNotesDisposed';

const shops = <String, String>{
  'https://us.7digital.com/': '7digital',
  'https://www.hdtracks.com/': 'hdtracks',
  'https://www.qobuz.com': 'qobuz',
  'https://www.amazon.com/music/player': 'Amazon Music',
  'https://bandcamp.com/tag/buy': 'Bandcamp',
};

const kSponsorLink = 'https://github.com/sponsors/Feichtmeier';

const kAlbumArtHeaders = {
  'Accept': 'application/json',
  'User-Agent': '$kAppTitle ($kRepoUrl)',
};

const kAudioHeaderDescriptionWidth = 400.0;

const kShowLeadingThreshold = 3000;
