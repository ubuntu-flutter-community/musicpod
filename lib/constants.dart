// app names, IDs and links
const kAppName = 'musicpod';
const kAppTitle = 'MusicPod';
const kAppId = 'org.feichtmeier.Musicpod';
const kAndroidAppId = 'org.feichtmeier.apps.musicpod';
const kDiscordApplicationId = '1235321910221602837';
const kLinuxDBusName = 'org.mpris.MediaPlayer2.musicpod';
const kAndroidChannelId = 'org.feichtmeier.apps.musicpod.channel.audio';
const kRepoUrl = 'http://github.com/ubuntu-flutter-community/musicpod';
const kSponsorLink = 'https://github.com/sponsors/Feichtmeier';
const kGitHubShortLink = 'ubuntu-flutter-community/musicpod';
const kFallbackThumbnailUrl =
    'https://raw.githubusercontent.com/ubuntu-flutter-community/musicpod/main/snap/gui/musicpod.png';

// HTTP headers
const kMusicBrainzHeaders = {
  'Accept': 'application/json',
  'User-Agent': '$kAppTitle ($kRepoUrl)',
};

const kInternetArchiveHeaders = {
  'User-Agent': '$kAppTitle ($kRepoUrl)',
};

// persistence and library IDs and filenames
const kLikedAudiosFileName = 'likedAudios.json';
const kRadioTagFavsFileName = 'tagFavs.json';
const kCountryFavsFileName = 'countryfavs.json';
const kFavLanguageCodesFileName = 'languagefavs.json';
const kLastRadioTag = 'lastFav';
const kPlaylistsFileName = 'playlists.json';
const kPinnedAlbumsFileName = 'finallyFixedPinnedAlbums.json';
const kPodcastsFileName = 'podcasts.json';
const kPodcastsUpdates = 'podcastsupdates.json';
const kStarredStationsFileName = 'uuidStarredStations.json';
const kSettingsFileName = 'settings.json';
const kLastPositionsFileName = 'lastPositions.json';
const kPlayerStateFileName = 'playerstate.json';
const kAppStateFileName = 'appstate.json';
const kRadioHistoryFileName = 'radiohistory.json';
const kDownloads = 'downloads.json';
const kFeedsWithDownloads = 'feedswithdownloads.json';
const kCoverStore = 'coverStore.json';
const kDirectoryProperty = 'directory';
const kDownloadsCustomDir = 'downloadsCustomDir';
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
const kEnableDiscordRPC = 'enableDiscordRPC';
const kEnableLastFmScrobbling = 'enableLastFmScrobbling';
const kLastFmApiKey = 'lastFmApiKey';
const klastFmSecret = 'lastFmSecret';
const kLastFmSessionKey = 'lastFmSessionKey';
const kLastFmUsername = 'lastFmUsername';
const kEnableListenBrainzScrobbling = 'enableListenBrainzScrobbling';
const kListenBrainzApiKey = 'listenBrainzApiKey';
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
const kCloseBtnAction = 'closeBtnAction';
const kUseMoreAnimations = 'useMoreAnimations';
const kShowPositionDuration = 'showPositionDuration';
const kSettingsPageId = 'settings';
const kHomePageId = 'homePage';
const kPlaybackRate = 'playbackRate';
