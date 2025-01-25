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

const kDirectoryProperty = 'directory';
const kDownloadsCustomDir = 'downloadsCustomDir';
const kLocalAudioIndex = 'localAudioIndex';

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

const kUsePodcastIndex = 'usePodcastIndex';
const kThemeIndex = 'themeIndex';
const kPodcastIndexApiKey = 'podcastIndexApiKey';
const kPodcastIndexApiSecret = 'podcastIndexApiSecret';
const kUseArtistGridView = 'useArtistGridView';

const kFavRadioTags = 'favRadioTags';
const kFavCountryCodes = 'favCountryCodes';
const kFavLanguageCodes = 'favLanguageCodes';
const kAscendingFeeds = 'ascendingfeed:::';
const kPatchNotesDisposed = 'kPatchNotesDisposed';
const kCloseBtnAction = 'closeBtnAction';
const kUseMoreAnimations = 'useMoreAnimations';
const kShowPositionDuration = 'showPositionDuration';

const kPlaybackRate = 'playbackRate';
const kNotifyDataSafeMode = 'notifyDataSafeMode';
