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
}
