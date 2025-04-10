import 'package:shared_preferences/shared_preferences.dart';

extension SPKeys on SharedPreferences {
  static const directory = 'directory';
  static const downloads = 'downloadsCustomDir';
  static const localAudioIndex = 'localAudioIndex';
  static const neverShowImportFails = 'neverShowImportFails';
  static const enableDiscord = 'enableDiscordRPC';
  static const enableLastFm = 'enableLastFmScrobbling';
  static const lastFmApiKey = 'lastFmApiKey';
  static const lastFmSecret = 'lastFmSecret';
  static const lastFmSessionKey = 'lastFmSessionKey';
  static const lastFmUsername = 'lastFmUsername';
  static const enableListenBrainz = 'enableListenBrainzScrobbling';
  static const listenBrainzApiKey = 'listenBrainzApiKey';
  static const lastCountryCode = 'lastCountryCode';
  static const lastLanguageCode = 'lastLanguageCode';
  static const usePodcastIndex = 'usePodcastIndex';
  static const themeIndex = 'themeIndex';
  static const podcastIndexApiKey = 'podcastIndexApiKey';
  static const podcastIndexApiSecret = 'podcastIndexApiSecret';
  static const favRadioTags = 'favRadioTags';
  static const favCountryCodes = 'favCountryCodes';
  static const favLanguageCodes = 'favLanguageCodes';
  static const ascendingFeeds = 'ascendingfeed:::';
  static const patchNotesDisposed = 'kPatchNotesDisposed';
  static const closeBtnAction = 'closeBtnAction';
  static const useMoreAnimations = 'useMoreAnimations';
  static const showPositionDuration = 'showPositionDuration';
  static const notifyDataSafeMode = 'notifyDataSafeMode';
  static const windowHeight = 'windowHeight';
  static const windowWidth = 'windowWidth';
  static const windowMaximized = 'windowMaximized';
  static const windowFullscreen = 'windowFullscreen';
  static const forcedUpdateVersionThreshold = 'forcedUpdateVersionThreshold';
  static const backupSaved = 'backupSaved_';
  // TODO: #1201 chore: migrate pinned albums to shared preferences
  static const pinnedMusicpodAlbumPrefix = 'pinnedMusicpodAlbumPrefix___';
  static const externalPlaylists = 'externalPlaylists';
}
